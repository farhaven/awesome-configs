require('strict') -- strict checking for unassigned variables, like perl's use strict;
require('awful')
require('awful.autofocus')
require('beautiful')
require('naughty') -- Naughtyfications
require('obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git
require('osk')     -- on screen keyboard

-- {{{ Functions
-- {{{ getlayouticon(layout)
function getlayouticon(s)
    if type(s) == "string" then
        return " " .. awful.util.escape(config.layout_icons[s]) .. " "
    end
    if not awful.layout.get(s) then return "     " end
    return " " .. awful.util.escape(config.layout_icons[awful.layout.getname(awful.layout.get(s))]) .. " "
end
-- }}}
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
-- {{{ screenfocus(idx)
function screenfocus(idx)
    awful.screen.focus_relative(idx)
    local x = mouse.coords().x + 1
    local y = mouse.coords().y + 1
    mouse.coords({ x = x, y = y })
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
}
tags = { }
for s = 1, screen.count() do
    tags[s] = { }
    for i, v in ipairs(config.tags) do
        tags[s][i] = tag({ name = v.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
        awful.tag.setproperty(tags[s][i], "nmaster", v.nmaster)
        awful.tag.setproperty(tags[s][i], "ncols", v.ncols)
        awful.tag.setproperty(tags[s][i], "icon", v.icon)
    end
    tags[s][1].selected = true
end
-- }}}
-- {{{ Clients
config.apps = {
    -- {{{ floating setup
    { match = { "xcalc", "xdialog", "event tester" },   float = true },
    { match = { "zsnes", "xmessage", "pinentry" },      float = true },
    { match = { "sauerbraten engine", "gnuplot" },      float = true },
    { match = { "mplayer", "Open File", "dclock" },     float = true },
    -- }}}
    -- {{{ apptags
    { match = { "urxvt" },              tag = 1 },
    { match = { "firefox", "dillo" },   tag = 2 },
    { match = { "uzbl" },               tag = 2 },
    { match = { "urxvt.cmus", "wicd" }, tag = 3 },
    { match = { "xpdf", "virtualbox" }, tag = 3 },
    { match = { config.global.editor }, tag = 5 },
    { match = { "urxvt.irssi" },        tag = 6 },
    { match = { "urxvt.mutt" },         tag = 7 },
    -- }}}
    -- {{{ opacity
    { match = { "xterm", "urxvt" },         opacity_f = 0.9 },
    { match = { "gimp", "^xv", "mplayer" }, opacity_u = 1 },
    -- }}}
}
-- }}}
-- {{{ Naughty
naughty.config.bg           = beautiful.bg_normal
naughty.config.fg           = beautiful.fg_normal
naughty.config.screen       = screen.count()
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
                                -- textbox(" "),
                                -- obvious.volume_alsa(),
                                {
                                    osk.widget(),
                                    tb_terminal,
                                    tb_kill,
                                    tb_client_prev,
                                    tb_client_next,
                                    layout = awful.widget.layout.horizontal.leftright
                                },
                                textbox(" "),
                                obvious.clock(),
                                textbox(" "),
                                obvious.battery(),
                                -- s == screen.count() and st_systray,
                                ["layout"] = awful.widget.layout.horizontal.rightleft,
                            }
end
-- }}}
-- }}}
-- {{{ Key bindings
globalkeys = awful.util.table.join(
-- {{{ Client / Focus manipulation
    awful.key({ config.global.modkey, "Mod1" }, "c", function () if client.focus then client.focus:kill() end end),

    awful.key({ config.global.modkey }, "Up", function () awful.client.focus.byidx(-1) end),
    awful.key({ config.global.modkey }, "Down", function () awful.client.focus.byidx(1) end),
    awful.key({ config.global.modkey }, "Left", function ()
        if not client.focus then return end
        client.focus:swap(awful.client.getmaster(client.focus.screen))
    end),
    awful.key({ config.global.modkey, "Mod4" }, "Up", function () awful.client.swap.byidx(-1) end),
    awful.key({ config.global.modkey, "Mod4" }, "Down", function () awful.client.swap.byidx(1) end),
    awful.key({ config.global.modkey }, "Right", function () awful.client.movetoscreen() end),
-- }}}
-- {{{ Layout manipulation
    awful.key({ config.global.modkey, "Mod1" }, "Down", function () awful.tag.incmwfact(0.01) end),
    awful.key({ config.global.modkey, "Mod1" }, "Up", function () awful.tag.incmwfact(-0.01) end),
    awful.key({ config.global.modkey }, " ", function () awful.layout.inc(config.layouts, 1) end),

    awful.key({ config.global.modkey, "Mod1" }, "Left", function () awful.client.incwfact(0.05) end),
    awful.key({ config.global.modkey, "Mod1" }, "Right", function () awful.client.incwfact(-0.05) end),
-- }}}
-- {{{ Audio
-- Volume control
    awful.key({ }, "XF86AudioRaiseVolume", function () obvious.volume_alsa.raise(0, "Master") end),
    awful.key({ }, "XF86AudioLowerVolume", function () obvious.volume_alsa.lower(0, "Master") end),
    awful.key({ }, "XF86AudioMute", function () obvious.volume_alsa.mute(0, "Master") end)
-- }}}
)
-- {{{ Tags
for i = 1, 9 do
    table.foreach(awful.key({ config.global.modkey }, i,
            function ()
                awful.tag.viewonly(tags[mouse.screen][i])
            end), function(_, k) table.insert(globalkeys, k) end)

    table.foreach(awful.key({ config.global.modkey, "Mod1" }, i,
            function ()
                if client.focus then
                    awful.client.movetotag(tags[mouse.screen][i])
                end
            end), function(_, k) table.insert(globalkeys, k) end)
end
-- }}}
clientkeys = awful.util.table.join(
    awful.key({ config.global.modkey, "Mod1" }, "c",  function (c) c:kill() end),
    awful.key({ config.global.modkey }, "f",  awful.client.floating.toggle),

    awful.key({ config.global.modkey }, "a", function (c) c.sticky = not c.sticky end),
    awful.key({ config.global.modkey }, "j", function (c) c:lower() end),
    awful.key({ config.global.modkey }, "k", function (c) c:raise() end)
)
root.keys(globalkeys)
-- }}}
-- {{{ Signals
local opacities_focus   = { }
local opacities_unfocus = { }
-- {{{ focus
client.add_signal("focus", function (c)
    c.border_color = beautiful.border_focus
    c.opacity = opacities_focus[c]
    c:raise()
end)
-- }}}
-- {{{ unfocus
client.add_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
    c.opacity = opacities_unfocus[c]
end)
-- }}}
-- {{{ manage
client.add_signal("manage", function (c, startup)
    if not startup and awful.client.focus.filter(c) then
        c.maximized_horizontal = false
        c.maximized_vertical = false
    end

    c:buttons(awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c end),
        awful.button({ config.global.modkey }, 1, awful.mouse.client.move),
        awful.button({ config.global.modkey }, 3, awful.mouse.client.resize)
    ))

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    c.size_hints_honor = true

    local instance = c.instance and c.instance:lower() or ""
    local class = c.class and c.class:lower() or ""
    local name = c.name and c.name:lower() or ""

    opacities_unfocus[c] = config.global.opacity_u or 1
    opacities_focus[c] = config.global.opacity_f or 1

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
                if v.opacity_u then
                    opacities_unfocus[c] = v.opacity_u
                end
                if v.opacity_f then
                    opacities_focus[c] = v.opacity_f
                end
            end
        end
    end

    if not startup and awful.client.floating.get(c) then
        awful.placement.centered(c, c.transient_for)
        awful.placement.no_offscreen(c)
    end

    c:keys(clientkeys)

    client.focus = c
end)
-- }}}
-- {{{ layout
function layout_update(t)
    lb_layout[t.screen].text = getlayouticon(awful.layout.getname(awful.layout.get(t.screen)))
end

for s = 1, screen.count() do
    awful.tag.attached_add_signal(s, "property::layout", layout_update)
    awful.tag.attached_add_signal(s, "property::selected", layout_update)
end
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
