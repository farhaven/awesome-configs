require('strict') -- strict checking for unassigned variables, like perl's use strict;
require('awful')
require('awful.autofocus')
require('beautiful')
require('naughty') -- Naughtyfications
require('obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git
require('osk')     -- on screen keyboard

-- {{{ Functions
-- {{{ textbox(content)
textboxes = { }
function textbox(content)
    for k, v in ipairs(textboxes) do
        if v.text == content then
            return v
        end
    end
    local w = widget({ type = "textbox" })
    w.text = content
    table.insert(textboxes, w)
    return w
end
-- }}}
-- }}}
-- {{{ Settings
config = { }
-- {{{ Global settings
config.global = {
    ["opacity_f" ] = 1,
    ["opacity_u" ] = 0.65,
    ["theme"]      = awful.util.getdir("config") .. "/themes/foo/foo.lua",
    ["terminal"]   = "urxvt",
    ["editor"]     = "gvim",
    ["modkey"]     = "Mod3",
    ["hostname"]   = awful.util.pread("hostname"):gsub("\n", ""),
}
beautiful.init(config.global.theme)
-- }}}
-- {{{ Layouts
config.layouts = {
    awful.layout.suit.max
}
config.layout_icons = {
    ["max"] = "[M]"
}
-- }}}
-- {{{ Tags
config.tags = {
    { name = " 1 ", layout = config.layouts[1] },
    { name = " 2 ", layout = awful.layout.suit.magnifier }
}
tags = { }
for i, v in ipairs(config.tags) do
    tags[i] = tag({ name = v.name })
    tags[i].screen = 1
    awful.tag.setproperty(tags[i], "layout", v.layout)
    awful.tag.setproperty(tags[i], "mwfact", v.mwfact)
    awful.tag.setproperty(tags[i], "nmaster", v.nmaster)
    awful.tag.setproperty(tags[i], "ncols", v.ncols)
    awful.tag.setproperty(tags[i], "icon", v.icon)
end
tags[1].selected = true
-- }}}
-- {{{ Clients
config.apps = { }
-- }}}
-- {{{ Naughty
naughty.config.bg           = beautiful.bg_normal
naughty.config.fg           = beautiful.fg_normal
naughty.config.border_width = 2
naughty.config.presets.normal.border_color  = beautiful.fg_normal
naughty.config.presets.normal.hover_timeout = 0.3
naughty.config.presets.normal.opacity       = 0.8
naughty.config.presets.normal.font = "Fixed 8"
-- }}}
-- {{{ Obvious
obvious.clock.set_editor(config.global.editor)
obvious.clock.set_shortformat(function ()
    local week = tonumber(os.date("%W")) + 1
    return "%H%M ("..week..")"
end)
obvious.clock.set_longformat(function ()
    local week = tonumber(os.date("%W")) + 1
    return "%d%m ("..week..")"
end)
-- }}}
-- }}}
-- {{{ Widgets
-- {{{ systray
st_systray = widget({ type  = "systray" })
-- }}}
-- {{{ Terminal and kill buttons
tb_terminal = widget({ type = "textbox" })
tb_terminal.text = "☻ "
tb_terminal:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn(config.global.terminal) end )
))
tb_kill = widget({ type = "textbox" })
tb_kill.text = " ☠"
tb_kill:buttons(awful.util.table.join(
    awful.button({ }, 1, function () client.focus:kill() end)
))
-- }}}
-- {{{ client focus buttons
tb_client_next = widget({ type = "textbox" })
tb_client_next.text = "☛"
tb_client_next:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.client.focus.byidx(-1) end)
))
tb_client_prev = widget({ type = "textbox" })
tb_client_prev.text = "  ☚ "
tb_client_prev:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.client.focus.byidx(1) end)
))
-- }}}
tb_desktop = widget({ type = "textbox" })
tb_desktop.text = " |D|"
tb_desktop:buttons(awful.util.table.join(
    awful.button({ }, 1, function ()
        tags[1].selected = not tags[1].selected
        tags[2].selected = not tags[2].selected
    end)
))
-- {{{ widget box
wi_widgets = {}

for s = 1, screen.count() do
    wi_widgets[s] = awful.wibox({ position = "top",
                                  fg = beautiful.fg_normal,
                                  bg = beautiful.bg_normal,
                                  screen = s,
                                  height = 48
                                })

    wi_widgets[s].widgets = {
                                {
                                    osk.widget(),
                                    tb_terminal,
                                    tb_kill,
                                    tb_client_prev,
                                    tb_client_next,
                                    tb_desktop,
                                    layout = awful.widget.layout.horizontal.leftright
                                },
                                textbox(" "),
                                obvious.clock(),
                                textbox(" "),
                                obvious.battery(),
                                ["layout"] = awful.widget.layout.horizontal.rightleft,
                            }
end
-- }}}
-- }}}
-- {{{ Signals
-- {{{ focus
client.add_signal("focus", function (c)
    c.border_color = beautiful.border_focus
    c:raise()
end)
-- }}}
-- {{{ unfocus
client.add_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
end)
-- }}}
-- {{{ manage
client.add_signal("manage", function (c, startup)
    if not startup and awful.client.focus.filter(c) then
        c.maximized_horizontal = false
        c.maximized_vertical = false
    end

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    c.size_hints_honor = true

    local instance = c.instance and c.instance:lower() or ""
    local class = c.class and c.class:lower() or ""
    local name = c.name and c.name:lower() or ""

    for k, v in pairs(config.apps) do
        for j, m in pairs(v.match) do
            if name:match(m) or instance:match(m) or class:match(m) then
                if v.float ~= nil then
                    awful.client.floating.set(c, v.float)
                    c:raise()
                end
                if v.tag then
                    awful.client.movetotag(tags[c.screen][v.tag], c)
                end
            end
        end
    end

    if not startup and awful.client.floating.get(c) then
        awful.placement.centered(c, c.transient_for)
        awful.placement.no_offscreen(c)
    end

    client.focus = c
end)
-- }}}
-- {{{ mouse enter
client.add_signal("new", function (c)
    c:add_signal("mouse::enter", function (c)
        if awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
end)
-- }}}
-- }}}
