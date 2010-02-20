--------------------------------------------
-- high contrast color scheme for awesome --
--------------------------------------------

local util = require('awful.util')

return {
    font    = "Fixed 8",

    bg_normal = "#000000",
    bg_focus  = "#2e8b57",
    bg_urgent = "#a52a2a",

    fg_normal = "#00ffff",
    fg_focus  = "#000000",
    fg_urgent = "#000000",

    border_width  = 2,
    border_normal = "#000000",
    border_focus  = "#2e8b57",

    taglist_squares_sel         = util.getdir('config') .. "/themes/foo/tasklist_f.png",
    taglist_squares_unsel       = util.getdir('config') .. "/themes/foo/tasklist_u.png",
    tasklist_floating_icon      = util.getdir('config') .. "/themes/foo/floating.png",

    titlebar_close_button_normal = "/usr/local/share/awesome/themes/default/titlebar/close.png",
    titlebar_close_button_focus  = "/usr/local/share/awesome/themes/default/titlebar/closer.png",

    menu_submenu_icon = "/usr/local/share/awesome/themes/default/submenu.png",
    menu_height   = 15,
    menu_width    = 100,

    awesome_icon = "/usr/local/share/awesome/icons/awesome16.png"
}
