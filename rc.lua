require('awful')
require('beautiful')
require('naughty') -- Naughtyfications
require('obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git

-- {{{ Functions
-- {{{ getlayouticon(layout)
function getlayouticon(s)
    if not awful.layout.get(s) then return "     " end
    return " " .. awful.util.escape(config.layout_icons[awful.layout.getname(awful.layout.get(s))]) .. " "
end
-- }}}
-- {{{ warptofocus()
function warptofocus()
    if awful.mouse.client_under_pointer() == client.focus or
        awful.layout.get(client.focus.screen) == awful.layout.suit.magnifier then
        return
    end
    local g = client.focus:geometry()
    g.x = g.x + 4
    g.y = g.y + 4
    mouse.coords(g)
end
-- }}}
-- }}}
-- {{{ Settings
config = { }
-- {{{ Global settings
config.global = {
    ["opacity_f" ] = 1,
    ["opacity_u" ] = 0.5,
    ["theme"]      = awful.util.getdir("config") .. "/themes/dwm/dwm.theme",
    ["terminal"]   = "urxvt",
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
    awful.layout.suit.magnifier,
}
config.layout_icons =
{   ["tile"] = "[]=",
    ["tileleft"] = "=[]",
    ["tilebottom"] = "[v]",
    ["tiletop"] = "[^]",
    ["floating"] = "><>",
    ["magnifier"] = "[o]",
}
-- }}}
-- {{{ Tags
config.tags = {
    { name = "α", layout = config.layouts[3] },
    { name = "β", layout = config.layouts[4], mwfact = 0.87 },
    { name = "γ", layout = config.layouts[3] },
    { name = "δ", layout = config.layouts[1] },
    { name = "ε", layout = config.layouts[3] },
    { name = "ζ", layout = config.layouts[6] },
}
tags = { }
for s = 1, screen.count() do
    tags[s] = { }
    for i, v in ipairs(config.tags) do
        tags[s][i] = tag(v.name)
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
    { match = { "xcalc", "xdialog" }, float = true },
    { match = { "nitrogen", "zsnes", "xine", "xmessage" }, float = true },
    { match = { "netzwerkprotokoll", "event tester" }, float = true },
    { match = { "pinentry", "virtualbox" }, float = true },
    { match = { "sauerbraten engine", "Open File" }, float = true },
    { match = { "mplayer" }, float = true },
    -- }}}
    -- {{{ apptags
    { match = { config.global.terminal }, tag = 1 },
    { match = { "firefox", "dillo" },     tag = 2 },
    { match = { "urxvt.cmus", "xpdf" },   tag = 3 },
    { match = { config.global.editor },   tag = 4 },
    { match = { "urxvt.irssi" },          tag = 5 },
    { match = { "claws%-mail" },          tag = 6 },
    -- }}}
    -- {{{ opacity
    { match = { "xterm", "urxvt" }, opacity_f = 0.85 },
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
-- }}}
-- {{{ Widgets
-- {{{ spacer
tb_spacer = widget({ type = "textbox" })
tb_spacer.text = " "
-- }}}
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
-- {{{ prompt
tb_prompt = widget({ type = "textbox" })
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

obvious.clock.set_editor(config.global.editor)

for s = 1, screen.count() do
    wi_widgets[s] = wibox({ position = "top", 
                            fg = beautiful.fg_normal, 
                            bg = beautiful.bg_normal
                          })

    wi_widgets[s].widgets = {
                                {
                                    tl_taglist[s],
                                    lb_layout[s],
                                    tb_prompt,
                                    ["layout"] = awful.widget.layout.horizontal.leftright
                                },
                                {
                                    tb_spacer,
                                    obvious.volume_alsa(),
                                    tb_spacer,
                                    obvious.battery(),
                                    tb_spacer,
                                    s == screen.count() and st_systray,
                                    obvious.clock(),
                                    ["layout"] = awful.widget.layout.horizontal.rightleft,
                                },
                                {
                                    tl_tasklist[s],
                                    ["layout"] = awful.widget.layout.horizontal.flex
                                },
                                ["layout"] = awful.widget.layout.horizontal.leftright
                            }
    wi_widgets[s].screen = s
    wi_widgets[s]:geometry({ height = 16 })
end
-- }}}
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
    -- }}}
    -- {{{ Misc
    awful.key({ config.global.modkey }, "Home", function () awful.util.spawn("sudo su -c \"echo up > /proc/acpi/ibm/brightness\"") end),
    awful.key({ config.global.modkey }, "End", function () awful.util.spawn("sudo su -c \"echo down > /proc/acpi/ibm/brightness\"") end),
    awful.key({ config.global.modkey, "Mod1" }, "l", nil, function () awful.util.spawn("xtrlock") end),
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
-- }}}
-- {{{ Prompts
    -- {{{ Run prompt
    awful.key({ config.global.modkey }, "Return", function ()
        awful.prompt.run({ prompt = " $ " },
            tb_prompt,
            awful.util.spawn,
            awful.completion.shell,
            os.getenv("HOME") .. "/.cache/awesome/history"
        )
    end),
    -- }}}
    -- {{{ Lua prompt
    awful.key({ config.global.modkey, "Mod1" }, "Return", function ()
        awful.prompt.run({ prompt = " ? " },
            tb_prompt,
            awful.util.eval,
            awful.prompt.bash,
            os.getenv("HOME") .. "/.cache/awesome/history_eval"
        )
    end),
    -- }}}
    -- {{{ Program read prompt
    awful.key({ config.global.modkey, "Mod4" }, "Return", function()
        awful.prompt.run({ prompt = " > " },
        tb_prompt,
        function (s)
            local txt = awful.util.escape(awful.util.pread(s.." 2>&1"))
            naughty.notify({ text = txt, timeout = 0, screen = mouse.screen })
        end,
        awful.completion.shell,
        os.getenv("HOME") .. "/.cache/awesome/history_commands"
        )
    end),
    -- }}}
-- }}}
-- {{{ Client / Focus manipulation
    awful.key({ config.global.modkey, "Mod1" }, "c", function () if client.focus then client.focus:kill() end end),

    awful.key({ config.global.modkey }, "Up", function ()
        awful.client.focus.byidx(-1)
        warptofocus()
    end),
    awful.key({ config.global.modkey }, "Down", function ()
        awful.client.focus.byidx(1)
        warptofocus()
    end),
    awful.key({ config.global.modkey }, "Left", function ()
        awful.client.swap.byidx(1)
        warptofocus()
    end),
    awful.key({ config.global.modkey }, "Right", function ()
        awful.client.movetoscreen()
        warptofocus()
    end),
    awful.key({ config.global.modkey }, "XF86Back", function () awful.screen.focus(1) end),
    awful.key({ config.global.modkey }, "XF86Forward", function () awful.screen.focus(-1) end),
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
    awful.key({ }, "XF86AudioRaiseVolume", function () obvious.volume_alsa.raise() end),
    awful.key({ }, "XF86AudioLowerVolume", function () obvious.volume_alsa.lower() end),
    awful.key({ }, "XF86AudioMute", function () obvious.volume_alsa.mute() end)
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
-- {{{ Hooks
local opacities_focus   = { }
local opacities_unfocus = { }
-- {{{ focus
awful.hooks.focus.register(function (c)
    c.border_color = beautiful.border_focus
    c.opacity = opacities_focus[c]
end)
-- }}}
-- {{{ unfocus
awful.hooks.unfocus.register(function (c)
    c.border_color = beautiful.border_normal
    c.opacity = opacities_unfocus[c]
end)
-- }}}
-- {{{ manage
awful.hooks.manage.register(function (c, startup)
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
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

    local instance = c.instance:lower() or ""
    local class = c.class:lower() or ""
    local name = c.name:lower() or ""

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
    client.focus = c

    if not startup then
        awful.placement.centered(c, c.transient_for)
        awful.placement.no_offscreen(c)
    end

    c:keys(clientkeys)
end)
-- }}}
-- {{{ arrange
awful.hooks.arrange.register(function (screen)
    lb_layout[screen].text = getlayouticon(screen)
    if not client.focus then
        local c = awful.mouse.client_under_pointer()
        if c then client.focus = c end
    end
end)
-- }}}
-- {{{ mouse_enter
awful.hooks.mouse_enter.register(function (c)
    if awful.client.focus.filter(c) and (awful.layout.get(c.screen) ~= awful.layout.suit.magnifier or
        (client.focus.screen ~= c.screen and #(c:tags()[1]:clients()) == 1)) then
        client.focus = c
    elseif awful.client.focus.filter(c) and awful.layout.get(c.screen) == awful.layout.suit.magnifier then
        client.focus = awful.client.tiled(c.screen)[1]
    end
end)
-- }}}
-- }}}
