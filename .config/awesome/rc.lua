-- vim:set sw=4 et:

local awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar
pcall(function() menubar = require('menubar') end)

-- {{{ Utilities

local function add_signal(object, signal, callback)
    if object.connect_signal then
        object.connect_signal(signal, callback)
    else
        object.add_signal(signal, callback)
    end
end

-- }}}

-- Debugging {{{

-- Where does stdout go?
function print (...)
    local output = ""
    for i, v in ipairs(arg) do
        output = output .. tostring(v) .. "\t"
    end
    io.stderr:write(output:sub(1,-2), "\n")
end

function inspect (object)
    if type(object) == 'string' then
        return string.format("%q", object)
    elseif type(object) == 'table' then
        if next(object) == nil then
            return "{}"
        end
        local output = "{"
        for k, v in pairs(object) do
            output = output .. tostring(k) .. '=' .. inspect(v) .. ', '
        end
        return output:sub(1, -3) .. "}"
    else
        return tostring(object)
    end
end

function p (object)
    print(inspect(object))
end

-- }}}

-- {{{ XDG

xdg = {}

function xdg.parse_file(filename)
    local contents = {}
    local section = ''
    local file, err = io.open(filename)
    if not file then return nil, err end
    for line in file:lines() do
        section = line:match("^%[(.*)%]$") or section
        for key, value in line:gmatch("([%w-]+)=(.+)") do
            contents[section] = contents[section] or {}
            contents[section][key] = value
        end
    end
    file:close()
    return contents
end

function xdg.command_line(program, terminal)
    if not program then return end
    local entry = program['Desktop Entry'] or program
    if entry.Exec then
        local cmdline = entry.Exec:gsub('%%c', entry.Name)
        cmdline = cmdline:gsub('%%[fmuFMU]', '')
        cmdline = cmdline:gsub('%%k', program.filename or '')
        if entry.Icon then
            cmdline = cmdline:gsub('%%i', '--icon ' .. entry.Icon)
        else
            cmdline = cmdline:gsub('%%i', '')
        end
        if terminal and entry.Terminal == "true" then
            cmdline = terminal .. ' -e ' .. cmdline
        end
        return cmdline
    end
end

function xdg.startup_notify(entry)
  return entry.StartupNotify == "true" or entry.Terminal == "true"
end

function xdg.show(entry, session_name)
    if not entry then
        return false
    end
    entry = entry['Desktop Entry'] or entry
    session_name = session_name or os.getenv('XDG_SESSION_DESKTOP') or os.getenv('SESSION_DESKTOP') or os.getenv('GDMSESSION') or 'Old'
    show = true
    if entry.NoDisplay == "true" or entry.OnlyShowIn ~= nil then
        show = false
    end
    for session in (entry.OnlyShowIn or ''):gmatch("[^;]+") do
        if session == session_name then
            show = true
        end
    end
    for session in (entry.NotShowIn or ''):gmatch("[^;]+") do
        if session == session_name then
            show = false
        end
    end
    return show
end

xdg.data_home = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share"

function xdg.parse_all_applications()
    local applications, list, app, basename = {}, {}
    for _, dir in ipairs({
        "/usr/share",
        "/usr/local/share",
        xdg.data_home
    }) do
        dir = dir .. "/applications"
        local f = io.popen('find "' .. dir .. '" -name "*.desktop" 2>/dev/null')
        for line in f:lines() do
            app = xdg.parse_file(line) or {}
            basename = line:sub(dir:len() + 2)
            if app['Desktop Entry'] and app['Desktop Entry'].Hidden ~= "true" then
                app.filename = line
                app.basename = basename
                app.dirname = dir
                applications[basename] = app
            else
                applications[basename] = nil
            end
        end
        f:close()
    end
    for _, app in pairs(applications) do
        table.insert(list, app)
    end
    table.sort(list, function(a, b)
        return (a['Desktop Entry'].Name or ""):lower() < (b['Desktop Entry'].Name or ""):lower()
    end)
    return list
end

function xdg.applications_by_category(applications)
    local categorized = {}
    for _, app in ipairs(applications) do
        entry = app['Desktop Entry']
        for category in (entry.Categories or 'Other'):gmatch('[^;]+') do
            if not categorized[category] then
                categorized[category] = {}
            end
            table.insert(categorized[category], app)
        end
    end
    return categorized
end

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    add_signal(awesome, "debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         timeout = 20,
                         text = err })
        in_error = false
    end)
end

-- }}}

-- {{{ Variable definitions

local hostname = awful.util.pread('tpope host name'):sub(1, -2)
local modkey = "Mod4"
local standalone = not os.getenv('XDG_MENU_PREFIX')
local terminal = os.getenv('TERMINAL') or 'tpope terminal'

local layouts =
{
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen
    -- awful.layout.suit.magnifier
}

beautiful.init(awful.util.getdir("config") .. "/theme.lua")
if standalone and awful.util.file_readable(os.getenv('HOME') .. '/.fehbg') then
    os.execute('"$HOME/.fehbg"')
end

-- }}}

-- {{{ Icons

local icon_suffixes = {'.png', '.xpm'}

if not awesome.version:match('v3.[0-4]') then
    table.insert(icon_suffixes, '.svg')
end

local function icon_path(opts)
    opts = opts or {}
    local contexts = opts.contexts or {'apps', 'actions', 'devices', 'places', 'categories', 'status'}
    local size = opts.size or 48
    local icon_path = {}
    local xsize = string.format('%dx%d', size, size)
    for _, root in ipairs({os.getenv('HOME') .. '/.local/share/icons' , '/usr/share/icons'}) do
        local dir
        for _, theme in ipairs({
            'hicolor/' .. xsize .. '/%s',
            'hicolor/scalable/%s',
            'hicolor/64x64/%s',
            'hicolor/48x48/%s',
            'hicolor/128x128/%s',
            'hicolor/256x256/%s',
            'hicolor/512x512/%s',
            'hicolor/48x48/%s',
            'gnome/' .. xsize .. '/%s',
            'gnome/48x48/%s'}) do
            for _, context in ipairs(contexts) do
                dir = root .. '/' .. theme:format(context)
                if awful.util.file_readable(dir) then
                    table.insert(icon_path, dir)
                end
            end
        end
    end
    table.insert(icon_path, '/usr/share/pixmaps')
    table.insert(icon_path, '/usr/share/icons')
    return icon_path
end

local fallback_icon = '/usr/share/icons/HighContrast/%dx%d/status/dialog-question.png'

local function lookup_icon(name, opts)
    if not name or name:find('/') then
        return name
    else
        local suffixes = icon_suffixes
        for _, suffix in ipairs(suffixes) do
            if name:match('%' .. suffix .. '$') then
                suffixes = {''}
                break
            end
        end
        local path = icon_path(opts)
        for _, suffix in ipairs(suffixes) do
            for _, dir in ipairs(path) do
                local path = dir .. '/' .. name .. suffix
                if awful.util.file_readable(path) then
                    return path
                end
            end
        end
        local fallback = fallback_icon:gsub('%%d', (opts and opts.size or 48))
        if awful.util.file_readable(fallback) then
            return fallback
        end
    end
end

naughty.config.notify_callback = function(args)
    if args.appname == 'Spotify' then
        -- Seems to cause awesome to crash
        args.icon = nil
    elseif type(args.icon) == "string" and not args.icon:find('/') then
        local svg = '/usr/share/notify-osd/icons/Humanity/scalable/status/' .. args.icon .. '.svg'
        if not awesome.version:match('v3.[0-4]') and awful.util.file_readable(svg) then
            args.icon = svg
        else
            args.icon = lookup_icon(args.icon)
        end
    end
    return args
end

-- }}}

-- Activation {{{

local startup_time = os.time()
local function activate(c, trigger)
    local runtime = os.difftime(os.time(), startup_time)
    local t = c:tags()[1]
    if not c:isvisible() and t and runtime > 8 then
        awful.tag.viewonly(t)
    end

    client.focus = c
    c:raise()
    return c
end

if awful.ewmh then
    client.disconnect_signal("request::activate", awful.ewmh.activate)
    client.connect_signal("request::activate", activate)
end

--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
local function run_or_raise(cmd, properties)
    local clients = client.get()
    local focused = awful.client.next(0)
    local findex = 0
    local matched_clients = {}
    local n = 0
    for i, c in pairs(clients) do
        --make an array of matched clients
        if awful.rules.match_any(c, properties) then
            n = n + 1
            matched_clients[n] = c
            if c == focused then
                findex = n
            end
        end
    end
    if n > 0 then
        local c = matched_clients[1]
        -- if the focused window matched switch focus to next in list
        if 0 < findex and findex < n then
            c = matched_clients[findex+1]
        end
        activate(c, 'run_or_raise')
        return c
    end
    if cmd then
        awesome.spawn(cmd, true)
    end
end

function awful.util.spawn(cmd, sn)
    if type(cmd) ~= 'string' or cmd == "" then
        return false
    elseif cmd:match("^ .*# %%%S") then
        local class = cmd:match("# %%(%S+)")
        return run_or_raise(cmd, {class = {class}, instance = {class}})
    else
        if sn == nil then sn = true end
        return awesome.spawn(cmd, sn)
    end
end

local function browser()
    return run_or_raise('tpope browser', {class = {"^Uzbl-tabbed$"}, role = {'^browser$'}})
end

-- }}}

-- Editor {{{

local editor_cmd = 'tpope edit'

local function complete_file(text, cur_pos, ncomp)
    text, cur_pos, ncomp = awful.completion.shell("gvim " .. text, 5 + cur_pos, ncomp)
    return text:sub(6), cur_pos - 5, ncomp
end

local function prompt_file(callback)
    awful.prompt.run({prompt = "File: "},
    mypromptbox[mouse.screen].widget,
    callback,
    complete_file
    )
end

local function edit(file)
    if file then
        awful.util.spawn(editor_cmd .. ' "' .. file .. '"', false)
    end
    run_or_raise(nil, { class = {'[Vv]im$'} })
end

-- }}}

-- Terminal {{{

local function raise_host(host)
    run_or_raise(nil, {instance = {'@' .. host}})
end

local function mux_host(host)
    if host:find(' ') then
        awful.util.spawn('ssh -X ' .. host)
    else
        local cmd = terminal .. ' -e tpope host mux -d ' .. host
        local labels = {'mux@' .. host, 'tpope@' .. host, hostname .. '@' .. host}
        run_or_raise(cmd, {instance = labels, role = labels})
    end
end

local function shell_host(arg)
    local host = arg:match('%S+')
    local cmd = arg:match(' %S+')
    if cmd then
        cmd = cmd:sub(2)
    else
        cmd = 'shell'
    end
    local exec = ''
    if host ~= 'localhost' then
        exec = ' -e tpope host shell ' .. arg:gsub(' ', ' -t ', 1)
    elseif arg:find(' ') then
        exec = ' -e' .. arg:match(' .*')
    end
    local cmd = terminal .. exec
    awful.util.spawn(cmd)
end

local function pick_host(callback)
    keygrabber.run(
    function(modifier, key, event)
        if event ~= "press" then return true end
        local mod4
        for k, v in ipairs(modifier) do
            if v == "Mod4" then mod4 = true end
        end
        keygrabber.stop()
        if key:find('^%u$') or mod4 then
            host = awful.util.pread("tpope host name " .. key:upper()):sub(1, -2)
            callback(host)
        else
            prompt_host({text = key:match('^.$')}, callback)
        end
        return true
    end)
end

local function prompt_host(options, callback)
    options.prompt = "host: "
    awful.prompt.run(options,
    mypromptbox[mouse.screen].widget,
    callback,
    function(t, c, n)
        if(t:len() == 1) then
            local host = awful.util.pread("tpope host name " .. t):sub(1, -2)
            if host ~= "localhost" then
                return host, host:len() + 1
            end
        end
        hosts = {}
        local i = io.popen("tpope host list")
        for host in i:lines() do
            table.insert(hosts, host)
        end
        i:close()
        return awful.completion.generic(t, c, n, hosts)
    end
    )
end


local function chat()
    run_or_raise(terminal .. ' -name Chat -T Chat -e tpope chat', { instance = {'Chat'} })
end

-- }}}

-- {{{ Tags

local tags = {}
local mwfact = 1 - (802 + 4 * beautiful.border_width)/1920
for s = 1, screen.count() do
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    awful.tag.setmwfact(mwfact, tags[s][1])
end

local function toggle_layout (l)
    if awful.layout.get() == l then
        awful.layout.set(awful.layout.suit.tile)
    else
        awful.layout.set(l)
    end
end

-- }}}

-- {{{ Menu

awful.menu.menu_keys = {
    up = { "Up", "k" },
    down = { "Down", "j" },
    exec = { "Return", "Right", "l" },
    enter = { "Right", "l" },
    back = { "Left", "h" },
    close = { "Escape", "[", "Tab" }
}

local function restart()
    awful.util.restart()
end

local menu_categories = {
    { "&Accessories", "Utility", 'applications-accessories' },
    { "&Development", "Development", 'applications-development' },
    { "&Education", "Education", 'applications-science' },
    { "&Games", "Game", 'applications-games' },
    { "G&raphics", "Graphics", 'applications-graphics' },
    { "I&nternet", "Network", 'applications-internet' },
    { "M&ultimedia", "AudioVideo", 'applications-multimedia' },
    { "O&ffice", "Office", 'applications-office' },
    { "&Other", "Other", 'applications-other' },
    { "&Settings", "Settings", 'applications-utilities' },
    { "S&ystem Tools", "System", 'applications-system' },
}

local applications = xdg.parse_all_applications()
local applications_by_category = xdg.applications_by_category(applications)

local function lazy_menu_icon(item, theme)
    local size = theme and theme.height or beautiful.menu_height
    local icon = item[3]
    table.remove(item, 3)
    if icon then
        setmetatable(item, {__index = function(t, k)
            if k == 3 then
                t[k] = lookup_icon(icon, {size = size}) or false
                return t[k]
            end
        end})
    end
    return item
end

local menutheme = {height = math.min(beautiful.menu_height * 2, 48), width = beautiful.menu_width * 3 / 4}
local menusubtheme = {height = beautiful.menu_height, width = beautiful.menu_width}
local menuitems = {}

local function menu_insert(item)
    table.insert(menuitems, lazy_menu_icon(item, menutheme))
end

menu_insert({"&Terminal", function () shell_host('localhost') end, 'utilities-terminal'})
menu_insert({"&Multiplexor", function () mux_host('localhost') end, 'utilities-system-monitor'})
menu_insert({"&Browser", browser, 'web-browser'})

for _, category in ipairs(menu_categories) do
    local subitems = {theme = menusubtheme, category = category[2]}
    if awesome.version:match('v3.[0-4]') then
        subitems = {}
    end
    for _, app in ipairs(applications_by_category[category[2]] or {}) do
        local entry = app['Desktop Entry']
        local cmdline = xdg.command_line(entry, terminal)
        if cmdline and xdg.show(entry, session_name) then
            local class = entry.StartupWMClass or (entry.TryExec or entry.Exec or ""):gsub('^%S+/', '')
            local cmdmeta = " " .. cmdline .. " # %" ..class .. " " .. (entry.GenericName or "") .. ";" .. (entry.Keywords or "")
            local actions = {
                {entry.Comment or entry.GenericName or entry.Name, cmdmeta, theme = {font = beautiful.font:gsub('(.*) ', '%1 Bold ', 1)}},
                cmd = function () awful.util.spawn(cmdmeta, true) end
            }
            for action in (entry.Actions or ''):gmatch('[^;]+') do
                local a = app['Desktop Action ' .. action]
                if a then
                    table.insert(actions, lazy_menu_icon({a.Name or '?', xdg.command_line(a), a.Icon}))
                end
            end
            table.insert(actions, {"Open Desktop Entry", "xdg-open " .. app.filename})
            table.insert(actions, {"Edit Desktop Entry", function () return edit(app.filename) end})
            local mine = xdg.data_home .. '/applications/' .. app.basename
            if mine ~= app.filename then
                table.insert(actions, {"Override Desktop Entry", function()
                    if not awful.util.file_readable(mine) then
                        local source = io.open(app.filename, "r")
                        local dest = io.open(mine, "w")
                        dest:write(source:read("*a"))
                        dest:close()
                        source:close()
                    end
                    edit(mine)
                end})
            end
            table.insert(subitems, lazy_menu_icon({
                entry.Name or '?',
                awesome.version:match('v3.[0-4]') and actions.cmd or actions,
                entry.Icon,
                theme = {submenu = ""},
                entry = entry,
                cmdline = cmdmeta
            }))
        end
    end
    if table.getn(subitems) > 0 then
        menu_insert({category[1], subitems, category[3], category = category[2]})
    end
end

local exitmenu = {
    { "&Restart", restart },
    { "Restart with global &config", function() awesome.exec("awesome -c /etc/xdg/awesome/rc.lua") end },
    { "&Quit", awesome.quit },
}
if not awesome.version:match('v3.[0-4]') then exitmenu.theme = menusubtheme end
for _, app in pairs(applications) do
    if app and app['Desktop Entry']['X-GNOME-Provides'] == 'windowmanager' then
        table.insert(exitmenu, {
            app['Desktop Entry'].Name,
            function() awesome.exec(app['Desktop Entry'].Exec) end
        })
    end
end

menu_insert({"E&xit", exitmenu, 'system-log-out'})

local mymainmenu = awful.menu({ items = menuitems, theme = menutheme})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                           menu = mymainmenu})

local function client_menu_launcher(c, coords)
    if client_menu and client_menu.wibox.visible then
        cm = client_menu
        client_menu = nil
        return cm:hide()
    end
    local active, id, desc, icon
    local checked = lookup_icon('emblem-default', {size = beautiful.menu_height, contexts = {'emblems'}})
    local machine_arg = c.machine or '""'
    local outputs = {}
    local f = io.popen('tpope media sink list ' .. c.pid .. ' ' .. machine_arg)
    for line in f:lines() do
        active, id, desc = string.match(line, "(%S+)\t(%S+)\t(.+)")
        if active == "1" then
            icon = checked
        else
            icon = nil
        end
        if id then
            table.insert(outputs, {
                desc,
                function() awful.util.spawn('tpope media sink ' .. id .. ' '  .. c.pid .. ' ' .. machine_arg, false) end,
                icon
            })
        end
    end
    f:close()
    local inputs = {}
    local f = io.popen('tpope media source list ' .. c.pid .. ' ' .. machine_arg)
    for line in f:lines() do
        active, id, desc = string.match(line, "(%S+)\t(%S+)\t(.+)")
        if active == "1" then
            icon = checked
        else
            icon = nil
        end
        if id then
            table.insert(inputs, {
                desc,
                function() awful.util.spawn('tpope media source ' .. id .. ' '  .. c.pid .. ' ' .. machine_arg, false) end,
                icon
            })
        end
    end
    f:close()
    toggles = {}
    moves = {}
    for _, t in ipairs(tags[mouse.screen]) do
        icon = nil
        for _, t2 in ipairs(c:tags()) do
            if t == t2 then
                icon = checked
            end
        end
        table.insert(toggles, {t.name, function() awful.client.toggletag(t, c) end, icon })
        table.insert(moves, {t.name, function() awful.client.movetotag(t, c) end, icon })
    end
    items = {
        { "Fo&cus", function() client.focus = c; c:raise() end },
        { "&Kill", function() c:kill() end },
        { c.minimized and "R&estore" or "Minimiz&e", function() c.minimized = not c.minimized end },
        { c.float and "Un&float" or "&Float", function() awful.client.floating.toggle(c) end },
        { c.ontop and "Not On &Top" or "On &Top", function() c.ontop = not c.ontop end },
        { c.sticky and "Un&stick" or "&Stick", function() c.sticky = not c.sticky end },
        { "&Move To Tag", moves },
        { "To&ggle Tag", toggles },
    }
    if next(outputs) then
        table.insert(items, {"Audio &Out", outputs})
    end
    if next(inputs) then
        table.insert(items, {"Audio &In", inputs})
    end
    client_menu = awful.menu({ items = items })
    client_menu:show({keygrabber = true, coords = coords})
end

if menubar then
    menubar.menu_gen.generate = function()
        local apps = {}, category
        for _, cat in ipairs(menuitems) do
            if cat.category then
                category = 'other'
                for k, v in pairs(menubar.menu_gen.all_categories) do
                    if cat.category == v.app_type then
                        category = k
                    end
                end
                for _, item in ipairs(cat[2]) do
                    if item.entry and item.cmdline then
                        table.insert(apps, {
                            category = category,
                            cmdline = " " .. item.cmdline .. " # %" ..(item.entry.StartupWMClass or item.entry.TryExec or "") .. " " .. (item.entry.GenericName or "") .. ";" .. (item.entry.Keywords or ""),
                            name = item[1],
                            icon = item[3],
                        })
                    end
                end
            end
        end
        return apps
    end
end

-- }}}

-- {{{ Wibox

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
    if c == client.focus then
        c.minimized = true
    else
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end),
awful.button({ }, 3, function (c)
    if instance then
        instance:hide()
        instance = nil
    else
        instance = client_menu_launcher(c)
    end
end),
awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end))

local function battery_markup ()
    local out = awful.util.pread("acpi 2>/dev/null | grep -v unavailable | head -1")
    local percent = tonumber(out:match("(%d?%d?%d)%%"))
    local color
    if out:match('Discharging') then
        color = (percent <= 20 and "#ff0000" or "#aaaa00")
    elseif out:match('Charging') then
        color = '#00aa00'
    else
        color = '#808080'
    end
    return '<span color="' .. color .. '">↯</span>' .. percent .. '%'
end

for s = 1, standalone and screen.count() or 0 do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, (awful.widget.taglist.label or awful.widget.taglist.filter).all, mytaglist.buttons)

    -- Create a tasklist widget
    if awful.widget.tasklist.label then
       mytasklist[s] = awful.widget.tasklist(function(c)
          return awful.widget.tasklist.label.currenttags(c, s)
       end, mytasklist.buttons)
    else
       mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    end

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = os.getenv("AWESOME_BAR_POSITION") or "bottom", screen = s, height = 24 })

    if wibox.layout then
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(mylauncher)
        left_layout:add(mytaglist[s])
        left_layout:add(mypromptbox[s])
        local layout = wibox.layout.align.horizontal()
        local right_layout = wibox.layout.fixed.horizontal()
        if s == 1 then
            local battery_widget = battery_markup()
            if battery_widget then
                battery_widget = wibox.widget.textbox(battery_widget)
                local battery_widget_timer = timer({ timeout = 10 })
                battery_widget_timer:connect_signal("timeout", function()
                    battery_widget:set_markup(battery_markup() or '')
                end)
                battery_widget_timer:start()
                right_layout:add(battery_widget)
            end
            right_layout:add(wibox.widget.systray())
        end
        right_layout:add(awful.widget.textclock(nil, 5))
        right_layout:add(mylayoutbox[s])
        layout:set_left(left_layout)
        layout:set_middle(mytasklist[s])
        layout:set_right(right_layout)
        mywibox[s]:set_widget(layout)
    else
        -- Add widgets to the wibox - order matters
        mywibox[s].widgets = {
            {
                mylauncher,
                mytaglist[s],
                mypromptbox[s],
                layout = awful.widget.layout.horizontal.leftright
            },
            mylayoutbox[s],
            awful.widget.textclock({ align = "right" }, nil, 5),
            s == 1 and widget({ type = "systray" }) or nil,
            mytasklist[s],
            layout = awful.widget.layout.horizontal.rightleft
        }
    end

 end
 -- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

function lua_eval ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen].widget,
    function(code)
        local result, err = loadstring("return " .. code)
        naughty.notify({
            title = code,
            text = err or inspect(result())
        })
    end
    , nil,
    awful.util.getdir("cache") .. "/history_eval")
end

local globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function ()
        local y = screen[mouse.screen].workarea.y
        mymainmenu:show({keygrabber=true, coords={x=0, y=y > 0 and 0 or 9999}})
    end),
    awful.key({ modkey, "Shift"   }, "f", function () toggle_layout(awful.layout.suit.floating) end),
    awful.key({ modkey, "Mod1"    }, "f", function () toggle_layout(awful.layout.suit.max) end),
    awful.key({ modkey,           }, "m", function () toggle_layout(awful.layout.suit.max) end),
    awful.key({ modkey, "Control" }, "f", function () toggle_layout(awful.layout.suit.max.fullscreen) end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "v", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, "Mod1"    }, "h",     function () awful.tag.setmwfact(0.5)      end),
    awful.key({ modkey, "Mod1"    }, "l",     function () awful.tag.setmwfact(mwfact)   end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () toggle_layout(awful.layout.suit.tile) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r", function () if menubar then menubar.show() else mypromptbox[mouse.screen]:run() end end),
    awful.key({ modkey },            "p", function () if menubar then menubar.show() else mypromptbox[mouse.screen]:run() end end),
    awful.key({ modkey, "Mod1" },    "r", function () awful.prompt.run(
        { prompt = "Run in terminal: " },
        mypromptbox[mouse.screen].widget,
        function (cmd) shell_host('localhost ' .. cmd) end,
        awful.completion.shell
    ) end),
    awful.key({ modkey, "Mod1"    }, "e", function () prompt_file(edit) end),
    awful.key({ modkey            }, "semicolon", function () edit() end),
    awful.key({ modkey            }, "period", function () edit() end),
    awful.key({ modkey, "Control" }, "d", chat),
    awful.key({ modkey, "Shift"   }, "x", function () local c = browser() if c then c:swap(awful.client.getmaster()) end end),
    awful.key({ modkey, "Mod1"    }, "s", function () pick_host(mux_host) end),
    awful.key({ modkey, "Control" }, "s", function () pick_host(shell_host) end),
    awful.key({ modkey            }, "s", function () pick_host(raise_host) end),
    awful.key({ modkey, "Shift"   }, "r", lua_eval),
    awful.key({ modkey, "Shift"   }, "e", lua_eval)
    )

clientkeys = awful.util.table.join(
    awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey,           }, "c", function (c) client_menu_launcher(c, c:geometry()) end),
    awful.key({ "Control", "Mod1" }, "Tab", function (c) client_menu_launcher(c) end),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  function (c)
        c.maximized_horizontal = false
        c.maximized_vertical = false
        awful.client.floating.toggle(c)
    end),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift"   }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "a",      function (c) client.focus = awful.client.getmaster() end),
    awful.key({ modkey, "Shift"   }, "a",      function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "e",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n", function (c)
        c.minimized = true
    end),
    awful.key({ modkey, "Shift"   }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
    keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 2, function (c)
        mousegrabber.run(function(m)
            client_menu_launcher(c)
            return false
        end, "fleur")
    end),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules

local function app_for_client(c)
    if not c then return end
    for _, app in pairs(applications) do
        local entry = app['Desktop Entry']
        if entry.StartupWMClass == c.instance or entry.StartupWMClass == c.class then
            return app
        end
    end
    local exec
    for _, app in pairs(applications) do
        exec = app['Desktop Entry'].TryExec or app['Desktop Entry'].Exec or ''
        exec = exec:gsub('^%S+/', ''):gsub(' %%[UuFf]$', '')
        if exec == c.class or exec == c.instance then
            return app
        end
    end
end

local function escape_rule(rule)
    return '^' .. rule:gsub('[[()?%.*+-]', '%%%0') .. '$'
end

local function rule_any(rule)
    rule = rule or {}
    rule.class = rule.class or {}
    rule.instance = rule.instance or {}
    rule.name = rule.name or {}
    rule.icon_name = rule.icon_name or {}
    for _, category in ipairs(rule.category or {}) do
        for _, entry in ipairs(applications_by_category[category] or {}) do
            entry = entry['Desktop Entry'] or entry
            if entry.StartupWMClass then
                table.insert(rule.class, escape_rule(entry.StartupWMClass))
                table.insert(rule.instance, escape_rule(entry.StartupWMClass))
            elseif xdg.show(entry) then
                local exec = (entry.TryExec or entry.Exec or ' '):gsub(' %%[UuFf]', ''):gsub('^%S+/', '')
                if not exec:find(' ') then
                    table.insert(rule.instance, escape_rule(exec))
                end
                table.insert(rule.class, escape_rule(entry.Name))
                table.insert(rule.name, escape_rule(entry.Name))
                table.insert(rule.icon_name, escape_rule(entry.Name))
            end
        end
    end
    rule.category = nil
    return rule
end

awful.rules.match_any_original = awful.rules.match_any_original or awful.rules.match_any
awful.rules.match_any = function(c, p)
    return awful.rules.match_any_original(c, rule_any(p))
end

local function not_startup(c)
    return not awesome.startup
end

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     maximized_horizontal = false,
                     maximized_vertical = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { role = "^gnome" }, properties = { border_width = 0 }},
    { rule_any = { type = {"dock", "desktop"} },
      properties = { border_width = 0, focus = false } },
    { rule_any = {name = {"Event Tester", "XBindKey: Hit a key"} },
      properties = { floating = true, above = true, opacity = 0.5 }, callback = awful.placement.under_mouse },
    { rule_any = { class = { "Xmag", "Xcolorsel" }, icon_name = { "xzoom" }},
      properties = { floating = true, above = true }, callback = awful.placement.under_mouse },
    { rule_any = rule_any({category = { "Calculator" }, class = { "XCalc" }}),
      properties = { floating = true, above = true }, callback = awful.placement.under_mouse },
    { rule_any = { category = { "Settings" }, class = { "Pavucontrol", "Arandr" } },
      properties = { floating = true, above = true } },
    { rule_any = rule_any({category = { "P2P" }, class = { "Update-manager" } }),
      properties = { tag = tags[1][8] } },
    { rule_any = { class = {"pinentry", "Xmessage", "Gxmessage", "Update-notifier"}, role = {"bubble"} },
      properties = { floating = true, above = true } },
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
add_signal(client, "manage", function (c, startup)
    local client_signal = function(signal, callback)
        if client.connect_signal then
            c:connect_signal(signal, callback)
        else
            c:add_signal(signal, callback)
        end
    end

    local set_icon = function()
        local label = c.role or c.instance
        if label and label:find('@[%w-]*%*?$') then
            local host = label:match('@[%w-]*'):sub(2)
            if host == 'localhost' or host == '' then host = hostname end
            local cmd = label:match('^[^@]*')
            local color = awful.util.pread('tpope host color ' .. host):sub(1, -2)
            local icon
            if cmd == 'mux' or cmd == 'tpope' or cmd == hostname then
                icon = os.getenv('HOME') .. '/.pixmaps/mini/terminal/left-' .. color .. '.xpm'
            else
                icon = os.getenv('HOME') .. '/.pixmaps/mini/terminal/right-' .. color .. '.xpm'
            end
            if image then
                c.icon = image(icon)
            else
                c.icon = awesome.load_image(icon)
            end
        end
    end
    client_signal('property::instance', set_icon)
    client_signal('property::role', set_icon)
    set_icon()

    -- Enable sloppy focus
    client_signal('mouse::enter', function()
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

add_signal(client, "focus", function(c) c.border_color = beautiful.border_focus end)
add_signal(client, "unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}

local localrc = awful.util.getdir("config") .. "/local.lua"
if awful.util.file_readable(localrc) then
    require('local')
end
