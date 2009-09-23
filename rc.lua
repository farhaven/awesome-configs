require('strict') -- strict checking for unassigned variables, like perl's use strict;
require('awful')
require('awful.autofocus')
require('beautiful')
require('naughty') -- Naughtyfications
require('obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git

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
-- }}}
-- {{{ Settings
config = { }
-- {{{ Global settings
config.global = {
    ["opacity_f" ] = 1,
    ["opacity_u" ] = 0.65,
    -- ["theme"]      = awful.util.getdir("config") .. "/themes/foo/foo.lua",
    ["theme"]      = awful.util.getdir("config") .. "/themes/zenburn/theme.lua",
    ["terminal"]   = "urxvtc",
    ["editor"]     = "gvim",
    ["modkey"]     = "Mod3",
}
beautiful.init(config.global.theme)
-- }}}
-- {{{ Layouts
config.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.spiral,
}
config.layout_icons = {
    ["tile"] = "[]=",
    ["tileleft"] = "=[]",
    ["tilebottom"] = "[v]",
    ["tiletop"] = "[^]",
    ["floating"] = "><>",
    ["spiral"] = "[@]",
}
-- }}}
-- {{{ Tags
config.tags = {
    { name = "1:term", layout = config.layouts[3] },
    { name = "2:www", layout = config.layouts[1], mwfact = 0.8 },
    { name = "3:misc", layout = config.layouts[3] },
    { name = "4:text", layout = config.layouts[1] },
    { name = "5:irc", layout = config.layouts[1], mwfact = 0.28 },
    { name = "6:mail", layout = config.layouts[6] },
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
    { match = { "nitrogen", "zsnes", "xmessage" },      float = true },
    { match = { "pinentry" },                           float = true },
    { match = { "sauerbraten engine" },                 float = true },
    { match = { "mplayer", "Open File"},                float = true },
    -- }}}
    -- {{{ apptags
    { match = { "urxvt" },                tag = 1 },
    { match = { "firefox", "dillo" },     tag = 2 },
    { match = { "vimpression", "uzbl" },  tag = 2 },
    { match = { "urxvt.cmus", "wicd" },   tag = 3 },
    { match = { "xpdf", "virtualbox" },   tag = 3 },
    { match = { config.global.editor },   tag = 4 },
    { match = { "urxvt.irssi" },          tag = 5 },
    { match = { "urxvt.mutt" },           tag = 6 },
    -- }}}
    -- {{{ opacity
    { match = { "xterm", "urxvt" },         opacity_f = 0.85 },
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
-- }}}
-- {{{ Obvious
obvious.popup_run_prompt.set_slide(false)
obvious.clock.set_editor(config.global.editor)
obvious.clock.set_shortformat(function ()
    local week = tonumber(os.date("%W")) + 1
    return "%H%M ("..week..") "
end)
obvious.clock.set_longformat(function ()
    local week = tonumber(os.date("%W")) + 1
    return "%d%m ("..week..") "
end)
-- }}}
-- }}}
-- {{{ Widgets
-- {{{ tag list
tl_taglist = { }
for s = 1, screen.count() do
    tl_taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, 
                                             awful.util.table.join(
                                                awful.button({ }, 1, awful.tag.viewonly),
                                                awful.button({ }, 4, awful.tag.viewnext),
                                                awful.button({ }, 5, awful.tag.viewprev) ))
end
-- }}}
-- {{{ task list
tl_tasklist = { }
for s = 1, screen.count() do
    tl_tasklist[s] = awful.widget.tasklist.new(function (c) return awful.widget.tasklist.label.currenttags(c, s) end, 
                                               awful.util.table.join(
                                                    awful.button({ }, 1, function (c)
                                                        if not c:isvisible() then
                                                            awful.tag.viewonly(c:tags()[1])
                                                        end
                                                        client.focus = c
                                                        c:raise()
                                                    end),
                                                    awful.button({ }, 3, function ()
                                                        if instance then
                                                            instance:hide()
                                                            instance = nil
                                                        else
                                                            instance = awful.menu.clients({ width=250 })
                                                        end
                                                    end),
                                                    awful.button({ }, 4, function ()
                                                        awful.client.focus.byidx(1)
                                                        if client.focus then
                                                            client.focus:raise()
                                                        end
                                                    end),
                                                    awful.button({ }, 5, function ()
                                                        awful.client.focus.byidx(-1)
                                                        if client.focus then
                                                            client.focus:raise()
                                                        end
                                                    end)
                                                ))
end
-- }}}
-- {{{ layout box
lb_layout = { }
for s = 1, screen.count() do
    lb_layout[s] = widget({ type  = "textbox" })
    lb_layout[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(config.layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(config.layouts, -1) end)
    ))
    lb_layout[s].text = getlayouticon(s)
    lb_layout[s].bg = beautiful.bg_normal
end
-- }}}
-- {{{ systray
st_systray = widget({ type  = "systray" })
-- }}}
-- {{{ widget box
wi_widgets = {}

for s = 1, screen.count() do
    wi_widgets[s] = awful.wibox({ position = "top",
                                  fg = beautiful.fg_normal,
                                  bg = beautiful.bg_normal,
                                  screen = s,
                                  height = 16
                                })

    wi_widgets[s].widgets = {
                                tl_taglist[s],
                                lb_layout[s],
                                {
                                    obvious.clock(),
                                    s == screen.count() and st_systray,
                                    textbox(" "),
                                    obvious.battery(),
                                    textbox(" "),
                                    obvious.volume_alsa():set_layout(awful.widget.layout.horizontal.rightleft),
                                    textbox(" "),
                                    ["layout"] = awful.widget.layout.horizontal.rightleft,
                                },
                                {
                                    tl_tasklist[s],
                                    ["layout"] = awful.widget.layout.horizontal.flex
                                },
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            }
end
-- }}}
-- }}}
-- {{{ stats wibox
local statsbox = wibox({
                            border_color = beautiful.fg_normal,
                            border_width = 1
})
statsbox.visible = false
statsbox.ontop = true
statsbox.opacity = 0.9
statsbox.widgets = {
                        {
                            {
                                textbox("Misc:")
                            },
                            {
                                textbox("  load:"),
                                obvious.cpu():set_width(32),
                                obvious.cpu():set_type("textbox"):set_format(" (%03d%%)"),
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            },
                            ["layout"] = awful.widget.layout.vertical.flex
                        },
                        {
                            {
                                textbox("Network:")
                            },
                            {
                                textbox(" wlan0: in:"),
                                obvious.net.recv("wlan0"):set_width(32),
                                textbox(" out:"),
                                obvious.net.send("wlan0"):set_width(32),
                                textbox(" signal:"),
                                obvious.wlan():set_type("graph"):set_width(32),
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            },
                            {
                                textbox("  tun0: in:"),
                                obvious.net.recv("tun0"):set_width(32),
                                textbox(" out:"),
                                obvious.net.send("tun0"):set_width(32),
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            },
                            ["layout"] = awful.widget.layout.vertical.flex
                        },
                        {
                            {
                                textbox("Storage:")
                            },
                            {
                                textbox("   sda:"),
                                obvious.io():set_type("graph"):set_width(32),
                                obvious.fs_usage():set_type("textbox"):set_format("         /:%03d%%"),
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            },
                            {
                                textbox("   sdb:"),
                                obvious.io("sdb"):set_type("graph"):set_width(32),
                                obvious.fs_usage("/mnt/sdb2"):set_type("textbox"):set_format(" /mnt/sdb2:%03d%%"),
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            },
                            ["layout"] = awful.widget.layout.vertical.flex
                        },
                        ["layout"] = awful.widget.layout.vertical.flex
                    }
statsbox:geometry({ width = 300, height = 112 })
statsbox.screen = 1

function show_statsbox(scr)
    scr = scr or mouse.screen
    statsbox.screen = scr
    statsbox:geometry({ x = screen[scr].workarea.x + 4, y = screen[scr].workarea.y + 4 })
    statsbox.visible = true
end

function hide_statsbox()
    statsbox.visible = false
end

function toggle_statsbox(scr)
    if statsbox.visible then
        hide_statsbox()
    else
        show_statsbox(scr)
    end
end
-- }}}
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- {{{ Tags
    awful.key({ }, "XF86Back",
        function ()
            awful.tag.viewprev()
        end),
    awful.key({ }, "XF86Forward",
        function ()
            awful.tag.viewnext()
        end),
    awful.key({ config.global.modkey }, "r", awful.tag.history.restore),
    -- }}}
    -- {{{ Misc
    awful.key({ config.global.modkey }, "Home", function () awful.util.spawn("sudo su -c \"echo up > /proc/acpi/ibm/brightness\"", false) end),
    awful.key({ config.global.modkey }, "End", function () awful.util.spawn("sudo su -c \"echo down > /proc/acpi/ibm/brightness\"", false) end),
    awful.key({ config.global.modkey, "Mod1" }, "l", nil, function () awful.util.spawn("xtrlock", false) end),
    awful.key({ config.global.modkey, "Mod1" }, "r", awesome.restart),

    -- hide / unhide current screens wibox
    awful.key({ config.global.modkey, "Mod1" }, "w", function ()
        local w = wi_widgets[mouse.screen]
        if w.visible then
            w.visible = false
        else
            w.visible = true
        end
    end),

    awful.key({ config.global.modkey }, "s", toggle_statsbox),
-- }}}
-- {{{ Prompts
    -- {{{ Run prompt
    awful.key({ config.global.modkey }, "Return", function () awful.util.spawn("xrun") end),
    -- }}}
    -- {{{ Lua prompt
    awful.key({ config.global.modkey, "Mod1" }, "Return", function () awful.util.spawn("xrun awesome-client -v") end),
    -- }}}
    -- {{{ Program read prompt
    awful.key({ config.global.modkey, "Mod4" }, "Return", function() awful.util.spawn("xrun -v") end),
    -- }}}
    -- {{{ URL prompt
    awful.key({ config.global.modkey }, "numbersign", function () awful.util.spawn("xrun 'while read u; do uzbl -u $u; done'") end),
    -- }}}
-- }}}
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
    awful.key({ config.global.modkey }, "XF86Back", function ()
        awful.screen.focus_relative(1)
        local x = mouse.coords().x + 1
        local y = mouse.coords().y + 1
        mouse.coords({ x = x, y = y })
    end),
    awful.key({ config.global.modkey }, "XF86Forward", function ()
        awful.screen.focus_relative(-1)
        local x = mouse.coords().x + 1
        local y = mouse.coords().y + 1
        mouse.coords({ x = x, y = y })
    end),
-- }}}
-- {{{ Layout manipulation
    awful.key({ config.global.modkey, "Mod1" }, "Down", function () awful.tag.incmwfact(0.01) end),
    awful.key({ config.global.modkey, "Mod1" }, "Up", function () awful.tag.incmwfact(-0.01) end),
    awful.key({ config.global.modkey }, " ", function () awful.layout.inc(config.layouts, 1) end),

    awful.key({ config.global.modkey, "Mod1" }, "Left", function () awful.client.incwfact(0.05) end),
    awful.key({ config.global.modkey, "Mod1" }, "Right", function () awful.client.incwfact(-0.05) end),
-- }}}
-- {{{ Audio
-- Control cmus
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("cmus-remote -r", false) end),
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("cmus-remote -u", false) end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("cmus-remote -n", false) end),
    awful.key({ }, "XF86AudioStop", function () awful.util.spawn("cmus-remote -s", false) end),

-- Audio control
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
        c.screen = mouse.screen
        c.maximized_horizontal = false
        c.maximized_vertical = false
    end

    c:buttons(awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c end),
        awful.button({ config.global.modkey }, 1, awful.mouse.client.move),
        awful.button({ config.global.modkey, "Mod1" }, 1, awful.mouse.client.dragtotag.widget),
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
-- {{{ unmanage
client.add_signal("unmanage", function (c)
    if not client.focus or not client.focus:isvisible() then
        local c = awful.client.focus.history.get(c.screen, 0)
        if c then client.focus = c end
    end
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
        if awful.client.focus.filter(c) and (awful.layout.get(c.screen) ~= awful.layout.suit.magnifier or
            (client.focus.screen ~= c.screen and #(c:tags()[1]:clients()) == 1)) then
            client.focus = c
        elseif awful.client.focus.filter(c) and awful.layout.get(c.screen) == awful.layout.suit.magnifier then
            client.focus = awful.client.tiled(c.screen)[1]
        end
    end)
end)
-- }}}
-- }}}
