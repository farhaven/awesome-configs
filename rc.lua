require('awful')
require('beautiful')
require('naughty') -- Naughtyfications
require('obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git
require('freedesktop.menu')

-- {{{ Misc functions
-- {{{ dump_table(t, depth)
function dump_table(t, depth)
    if not depth then depth = 0 end
    local prefix = ""
    for i = 1, depth do
        prefix = prefix .. " "
    end
    for k, v in pairs(t) do
        if type(v) == "table" then
            dump_table(v, depth + 1)
        else
            print(prefix..k.." "..tostring(v))
        end
    end
    print("")
end
-- }}}
-- {{{ dump_client(c)
function dump_client(c)
    local msg = "Name: "..(c.name or "").."\n"
    msg = msg.. "Transient for: "..(tostring(c.transient_for or "")).."\n"

    naughty.notify({ text = msg })
end
-- }}}
-- {{{ getlayouticon(layout)
function getlayouticon(s)
    if not awful.layout.get(s) then return "   " end
    return "<span color='"..beautiful.fg_focus.."'>" .. layout_icons[awful.layout.getname(awful.layout.get(s))] .. "</span>"
end
-- }}}
-- }}}
-- {{{ Variable definitions
-- {{{ theme setup
theme_path = os.getenv("HOME") .. "/.config/awesome/themes/foo/foo.theme"
beautiful.init(theme_path)
-- }}}
-- {{{ misc
terminal = "urxvt"
editor = "gvim"

-- Default modkey.
-- I remapped Caps Lock to Mod3 using the following commands for xmodmap:
-- xmodmap -e "clear lock"
-- xmodmap -e "add mod3 = Caps_Lock"
modkey = "Mod3"
-- }}} 
-- {{{ layouts
layouts =
{   awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.magnifier,
}
layout_icons =
{   ["tile"] = "[]=",
    ["tileleft"] = "=[]",
    ["tilebottom"] = "[v]",
    ["tiletop"] = "[^]",
    ["fairv"] = "[|]",
    ["fairh"] = "[-]",
    ["floating"] = "o_O",
    ["magnifier"] = "[o]",
}
-- }}} 
-- }}}
-- {{{ Naughty setup
naughty.config.bg           = beautiful.bg_normal
naughty.config.fg           = beautiful.fg_normal
naughty.config.screen       = screen.count() == 2 and 2 or 1
naughty.config.border_width = 2
naughty.config.presets.normal.border_color = beautiful.fg_normal
naughty.config.presets.normal.hover_timeout = 0.3
-- }}}
-- {{{ Misc settings
-- {{{ Tags
config = { }
config.tags = {
    { name = "α", layout = layouts[1], icon = image("/usr/share/icons/gnome/32x32/apps/terminal.png") },
    { name = "β", layout = layouts[1], icon = image("/usr/share/icons/gnome/32x32/categories/applications-internet.png") },
    { name = "γ", layout = layouts[1], icon = image("/usr/share/icons/gnome/32x32/categories/applications-other.png") },
    { name = "δ", layout = layouts[1], icon = image("/usr/share/icons/gnome/32x32/apps/text-editor.png") },
    { name = "ε", layout = layouts[1], icon = image("/usr/share/icons/gnome/32x32/emotes/face-smile.png") },
    { name = "ζ", layout = layouts[6], icon = image("/usr/share/icons/gnome/32x32/actions/contact-new.png") },
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
    { match = { "gnome%-mplayer" }, float = true },
    -- }}}
    -- {{{ apptags
    { match = { "urxvt" }, tag = 1 },
    { match = { "urxvt.irssi" }, tag = 5 },
    { match = { "urxvt.cmus" }, tag = 3 },
    { match = { "claws%-mail" }, tag = 6 },
    { match = { "firefox", "dillo" }, tag = 2 },
    { match = { "gvim" }, tag = 4 },
    { match = { "xpdf" }, tag = 3 },
    -- }}}
    -- {{{ opacity
    { match = { "xterm", "urxvt" }, opacity_f = 0.85 },
    { match = { "gimp", "^xv", "mplayer" }, opacity_u = 1 },
    -- }}}
}
-- }}}
-- {{{ global settings
config.global = {
    ["opacity_f" ] = 1,
    ["opacity_u" ] = 0.5
}
-- }}}
-- }}}
-- {{{ Widgets
-- {{{ spacer
tb_spacer = widget({
    type = "textbox",
    name = "tb_spacer",
})
tb_spacer.width = 3
-- }}}
-- {{{ tag list
tl_taglist = { }
for s = 1, screen.count() do
    tl_taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, 
                                             { button({ }, 1, awful.tag.viewonly),
                                               button({ }, 4, awful.tag.viewnext),
                                               button({ }, 5, awful.tag.viewprev) })
end
-- }}}
-- {{{ task list
tl_tasklist = { }
for s = 1, screen.count() do
    tl_tasklist[s] = awful.widget.tasklist.new(function (c) return awful.widget.tasklist.label.currenttags(c, s) end, 
                                               {
                                                    button({ }, 1, function (c)
                                                        if not c:isvisible() then
                                                            awful.tag.viewonly(c:tags()[1])
                                                        end
                                                        client.focus = c
                                                        c:raise()
                                                    end),
                                                    button({ }, 3, function ()
                                                        if instance then
                                                            instance:hide()
                                                            instance = nil
                                                        else
                                                            instance = awful.menu.clients({ width=250 })
                                                        end
                                                    end),
                                                    button({ }, 4, function ()
                                                        awful.client.focus.byidx(1)
                                                        if client.focus then
                                                            client.focus:raise()
                                                        end
                                                    end),
                                                    button({ }, 5, function ()
                                                        awful.client.focus.byidx(-1)
                                                        if client.focus then
                                                            client.focus:raise()
                                                        end
                                                    end)
                                                })
end
-- }}}
-- {{{ prompt
tb_prompt = widget({ type = "textbox",
                     name = "tb_prompt",
                   })
-- }}}
-- {{{ layout box
lb_layout = { }
for s = 1, screen.count() do
    lb_layout[s] = widget({ type  = "textbox",
                            name  = "lb_layout",
                          })
    lb_layout[s]:buttons({
        button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        button({ }, 3, function () awful.layout.inc(layouts, -1) end)
    })
    lb_layout[s].text = getlayouticon(s)
    lb_layout[s].bg = beautiful.bg_focus
end
-- }}}
-- {{{ systray
st_systray = widget({ type  = "systray" })
-- }}}
-- {{{ Freedesktop.org Menu
tb_freedesktop = widget({ type = "textbox" })
tb_freedesktop.text = " MENU "
me_freedesktop = freedesktop.menu.new()
table.insert(me_freedesktop, {
    "Awesome", {
        { "Restart", awesome.restart },
        { "Quit", awesome.quit }
    }
})
me_freedesktop = awful.menu.new({
    id = "freedesktop",
    items = me_freedesktop,
    width = 120,
    keys = {
        exec = "Right"
    }
})
tb_freedesktop:buttons({
    button({ }, 1, function () me_freedesktop:toggle(true) end)
})
-- }}}
-- {{{ widget box
local systrayscreen = 1
if screen.count() > 1 then
    systrayscreen = 2
end

wi_widgets = {}

obvious.clock.set_editor("gvim")
obvious.wlan.set_device("wlan0")

for s = 1, screen.count() do
    wi_widgets[s] = wibox({ position = "top", 
                            name = "wi_widgets" .. s, 
                            fg = beautiful.fg_normal, 
                            bg = beautiful.bg_normal
                          })

    wi_widgets[s].widgets = {
                                {
                                    tb_freedesktop,
                                    tl_taglist[s],
                                    lb_layout[s],
                                    tb_prompt,
                                    ["layout"] = awful.widget.layout.horizontal.leftright
                                },
                                {
                                    obvious.wlan(),
                                    tb_spacer,
                                    obvious.volume_alsa(),
                                    tb_spacer,
                                    obvious.battery(),
                                    tb_spacer,
                                    s == screen.count() and st_systray,
                                    s == screen.count() and tb_spacer,
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
    wi_widgets[s].opacity = 0.85
    wi_widgets[s]:buttons({
        button({ modkey }, 1, awful.mouse.wibox.move)
    })
    wi_widgets[s].ontop = false
end
-- }}}
-- }}}
-- {{{ Key bindings
globalkeys = {
    -- {{{ Tags
    key({ }, "XF86Back", awful.tag.viewprev),
    key({ }, "XF86Forward", awful.tag.viewnext),
    -- }}}
    -- {{{ Misc
    key({ modkey }, "Home", function () awful.util.spawn("sudo su -c \"echo up > /proc/acpi/ibm/brightness\"") end),
    key({ modkey }, "End", function () awful.util.spawn("sudo su -c \"echo down > /proc/acpi/ibm/brightness\"") end),
    key({ modkey, "Mod1" }, "l", nil, function () awful.util.spawn("xtrlock") end),
    key({ modkey, "Mod1" }, "r", awesome.restart),
    key({ modkey }, "m", function ()
        mouse.coords(screen[mouse.screen].workarea)
        me_freedesktop:toggle(true)
    end),

-- hide / unhide current screens wibox
    key({ modkey, "Mod1" }, "w", function ()
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
    key({ modkey }, "Return", function ()
        awful.prompt.run({ prompt = " $ " },
            tb_prompt,
            awful.util.spawn,
            awful.completion.shell,
            os.getenv("HOME") .. "/.cache/awesome/history"
        )
    end),
    -- }}}
    -- {{{ Lua prompt
    key({ modkey, "Mod1" }, "Return", function ()
        awful.prompt.run({ prompt = " ? " },
            tb_prompt,
            awful.util.eval,
            awful.prompt.bash,
            os.getenv("HOME") .. "/.cache/awesome/history_eval"
        )
    end),
    -- }}}
    -- {{{ Program read prompt
    key({ modkey, "Mod4" }, "Return", function()
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
    key({ modkey, "Mod1" }, "c", function () if client.focus then client.focus:kill() end end),
    key({ modkey }, "d", awful.client.floating.toggle),

    key({ modkey }, "Up", function () awful.client.focus.byidx(-1) end),
    key({ modkey }, "Down", function () awful.client.focus.byidx(1) end),
    key({ modkey }, "Left", function () awful.client.swap.byidx(1) end),
    key({ modkey }, "Right", function () awful.client.movetoscreen() end),
    key({ modkey }, "XF86Back", function ()
        awful.screen.focus(1)
        local coords = mouse.coords()
        coords['x'] = coords['x'] + 1
        coords['y'] = coords['y'] + 2
        mouse.coords(coords)
    end),
    key({ modkey }, "XF86Forward", function ()
        awful.screen.focus(-1)
        local coords = mouse.coords()
        coords['x'] = coords['x'] + 1
        coords['y'] = coords['y'] + 2
        mouse.coords(coords)
    end),
-- }}}
-- {{{ Layout manipulation
    key({ modkey, "Mod1" }, "Down", function () awful.tag.incmwfact(0.01) end),
    key({ modkey, "Mod1" }, "Up", function () awful.tag.incmwfact(-0.01) end),
    key({ modkey }, " ", function () awful.layout.inc(layouts, 1) end),

    key({ modkey, "Mod1" }, "Left", function () awful.client.incwfact(0.05) end),
    key({ modkey, "Mod1" }, "Right", function () awful.client.incwfact(-0.05) end),
-- }}}
-- {{{ Audio
-- Control cmus
    key({ }, "XF86AudioPrev", function () awful.util.spawn("cmus-remote -r") end),
    key({ }, "XF86AudioPlay", function () awful.util.spawn("cmus-remote -u") end),
    key({ }, "XF86AudioNext", function () awful.util.spawn("cmus-remote -n") end),
    key({ }, "XF86AudioStop", function () awful.util.spawn("cmus-remote -s") end),

-- Audio control
    key({ }, "XF86AudioRaiseVolume", function () obvious.volume_alsa.raise() end),
    key({ }, "XF86AudioLowerVolume", function () obvious.volume_alsa.lower() end),
    key({ }, "XF86AudioMute", function () obvious.volume_alsa.mute() end),
-- }}}
}
-- {{{ Tags
for i = 1, 9 do
    table.insert(globalkeys,
        key({ modkey }, i,
            function ()
                awful.tag.viewonly(tags[mouse.screen][i])
            end))

    table.insert(globalkeys,
        key({ modkey, "Mod1" }, i,
            function ()
                if client.focus then
                    awful.client.movetotag(tags[mouse.screen][i])
                end
            end))
end
-- }}}
clientkeys = {
    key({ modkey, "Mod1" }, "c",  function (c) c:kill() end),
    key({ modkey }, "f",  awful.client.floating.toggle),

    key({ modkey }, "a", function (c) c.sticky = not c.sticky end),
    key({ modkey }, "j", function (c) c:lower() end),
    key({ modkey }, "k", function (c) c:raise() end),
}
root.keys(globalkeys)
-- }}}
-- {{{ Hooks
local opacities_focus   = otable()
local opacities_unfocus = otable()
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

    c:buttons({
        button({ }, 1, function (c) client.focus = c end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey, "Mod1" }, 1, awful.mouse.client.dragtotag.widget),
        button({ modkey }, 3, awful.mouse.client.resize)
    })

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

    awful.placement.centered(c, c.transient_for)
    awful.placement.no_offscreen(c)

    c:keys(clientkeys)
end)
-- }}}
-- {{{ arrange
awful.hooks.arrange.register(function (screen)
    lb_layout[screen].text = getlayouticon(screen)
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
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
-- {{{ property
cmus_current = ""
awful.hooks.property.register(function (c, prop)
    if prop == "name" and c.instance == "urxvt.cmus" and not c.name:match("cmus") and cmus_current ~= c.name then
        local name = c.name:match("^(.*) %(.*%)$")
        if name then
            naughty.notify({ text = awful.util.escape(name), width = 350, timeout = 5, screen = mouse.screen})
            cmus_current = c.name
        end
    end
end)
-- }}}
-- }}}
