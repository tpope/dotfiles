local theme = dofile('/usr/share/awesome/themes/default/theme.lua')
theme.wallpaper = nil
theme.wallpaper_cmd = { 'xsetroot -solid "#111111"' }
theme.menu_border_color = theme.border_normal
theme.border_normal = '#444444'
theme.border_focus = '#73bdff'
theme.titlebar_bg_normal = theme.border_normal
theme.titlebar_bg_focus = theme.border_focus
theme.titlebar_fg_normal = '#777777'
theme.titlebar_fg_focus = '#000000'
theme.font = 'sans 12'
theme.menu_width = 320
theme.menu_height = 32
return theme
