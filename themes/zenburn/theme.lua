-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme = {}
theme.wallpaper_cmd = { "awsetbg /usr/local/share/awesome/themes/zenburn/zenburn-background.png" }
-- }}}

-- {{{ Styles
-- theme.font      = "Droid Sans Mono 8"
theme.font      = "Terminus 8"

-- {{{ Colors
theme.fg_normal = "#DCDCCC"
theme.fg_focus  = "#F0DFAF"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#3F3F3F"
theme.bg_focus  = "#1E2320"
theme.bg_urgent = "#3F3F3F"
-- }}}

-- {{{ Borders
theme.border_width  = 2
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#1E2320"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = "15"
theme.menu_width  = "100"
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares       = "true"
theme.taglist_squares_sel   = "/home/gregor/.config/awesome/themes/zenburn/taglist/squarefz.png"
theme.taglist_squares_unsel = "/home/gregor/.config/awesome/themes/zenburn/taglist/squarez.png"
-- }}}

-- {{{ Misc
theme.awesome_icon           = "/usr/local/share/awesome/themes/zenburn/awesome-icon.png"
theme.menu_submenu_icon      = "/usr/local/share/awesome/themes/default/submenu.png"
theme.tasklist_floating_icon = "~/.config/awesome/themes/zenburn/floating.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = "/usr/local/share/awesome/themes/zenburn/layouts/tile.png"
theme.layout_tileleft   = "/usr/local/share/awesome/themes/zenburn/layouts/tileleft.png"
theme.layout_tilebottom = "/usr/local/share/awesome/themes/zenburn/layouts/tilebottom.png"
theme.layout_tiletop    = "/usr/local/share/awesome/themes/zenburn/layouts/tiletop.png"
theme.layout_fairv      = "/usr/local/share/awesome/themes/zenburn/layouts/fairv.png"
theme.layout_fairh      = "/usr/local/share/awesome/themes/zenburn/layouts/fairh.png"
theme.layout_spiral     = "/usr/local/share/awesome/themes/zenburn/layouts/spiral.png"
theme.layout_dwindle    = "/usr/local/share/awesome/themes/zenburn/layouts/dwindle.png"
theme.layout_max        = "/usr/local/share/awesome/themes/zenburn/layouts/max.png"
theme.layout_fullscreen = "/usr/local/share/awesome/themes/zenburn/layouts/fullscreen.png"
theme.layout_magnifier  = "/usr/local/share/awesome/themes/zenburn/layouts/magnifier.png"
theme.layout_floating   = "/usr/local/share/awesome/themes/zenburn/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = "/usr/local/share/awesome/themes/zenburn/titlebar/close_focus.png"
theme.titlebar_close_button_normal = "/usr/local/share/awesome/themes/zenburn/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = "/usr/local/share/awesome/themes/zenburn/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = "/usr/local/share/awesome/themes/zenburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/local/share/awesome/themes/zenburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = "/usr/local/share/awesome/themes/zenburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = "/usr/local/share/awesome/themes/zenburn/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = "/usr/local/share/awesome/themes/zenburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/local/share/awesome/themes/zenburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = "/usr/local/share/awesome/themes/zenburn/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = "/usr/local/share/awesome/themes/zenburn/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = "/usr/local/share/awesome/themes/zenburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/local/share/awesome/themes/zenburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = "/usr/local/share/awesome/themes/zenburn/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = "/usr/local/share/awesome/themes/zenburn/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = "/usr/local/share/awesome/themes/zenburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/local/share/awesome/themes/zenburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = "/usr/local/share/awesome/themes/zenburn/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
