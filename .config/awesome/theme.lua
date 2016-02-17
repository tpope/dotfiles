local theme = dofile('/usr/share/awesome/themes/default/theme.lua')

theme.wallpaper = nil
theme.wallpaper_cmd = { 'xsetroot -solid "#111111"' }

theme.menu_border_color = theme.border_normal
theme.border_normal = '#444444'
theme.border_focus = '#CC0000'
theme.titlebar_bg_normal = theme.border_normal
theme.titlebar_bg_focus = theme.border_focus
theme.titlebar_fg_normal = '#777777'
theme.titlebar_fg_focus = '#FFFFFF'

theme.font = 'Sans 14'
theme.border_width = 2
theme.menu_width = 384
theme.menu_height = 32

if not awesome.version:match('v3.[0-4]') then
  theme.menu_submenu_icon = nil
  theme.menu_submenu = "▶ "
end

return theme
