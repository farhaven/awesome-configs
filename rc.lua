local have_strict, strict = pcall(require, 'strict') -- strict checking for unassigned variables, like perl's use strict;
require('awful')
require('awful.autofocus')
require('beautiful')
require('naughty') -- Naughtyfications
local have_obvious, obvious = pcall(require, 'obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git
local have_tagger, tagger = pcall(require, 'tagger')  -- Dynamic Tagging

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
-- {{{ getclientbyprop(prop, value)
function getclientbyprop(prop, value)
    local c = client.get()
    for i, v in ipairs(c) do
        if v[prop] == value then
            return v
        end
    end
    return nil
end
-- }}}
-- }}}
-- {{{ Settings
config = { }
-- {{{ Global settings
config.global = {
    ["opacity_f" ] = 1,
    ["opacity_u" ] = 0.65,
    -- ["theme"]      = awful.util.getdir("config") .. "/themes/zenburn/theme.lua",
    ["theme"]      = awful.util.getdir("config") .. "/themes/foo/foo.lua",
    ["terminal"]   = "urxvtc",
    ["editor"]     = "gvim",
    ["modkey"]     = "Mod3",
    ["hostname"]   = awful.util.pread("hostname"):gsub("\n", ""),
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
    { name = "term", layout = config.layouts[3] },
    { name = "www",  layout = config.layouts[1], mwfact = 0.8 },
    { name = "misc", layout = config.layouts[3] },
    { name = "text", layout = config.layouts[1], mwfact = 0.57 },
    { name = "irc",  layout = config.layouts[1], mwfact = 0.28 },
    { name = "mail", layout = config.layouts[6] },
}
for s = 1, screen.count() do
    if have_tagger then
        tagger.add(s, awful.util.table.join(config.tags[1], { switch = true }))
    else
        for i, v in ipairs(config.tags) do
            local t = tag({ name = v.name })
            t.screen = s
            awful.tag.setproperty(t, "layout", v.layout)
            awful.tag.setproperty(t, "mwfact", v.mwfact)
            awful.tag.setproperty(t, "nmaster", v.nmaster)
            awful.tag.setproperty(t, "ncols", v.ncols)
            awful.tag.setproperty(t, "icon", v.icon)
        end
    end
    awful.tag.viewonly(screen[s]:tags()[1])
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
    { match = { "urxvt" },                 tag = "term" },
    { match = { "firefox", "dillo" },      tag = "www" },
    { match = { "uzbl", "chrome" },        tag = "www" },
    { match = { "urxvt.cmus", "mplayer" }, tag = "media" },
    { match = { "gqview", "gimp" },        tag = "media" },
    { match = { "^win$" },                 tag = "media" },
    { match = { "virtualbox" },            tag = "emulation" },
    { match = { "yadex" },                 tag = "misc" },
    { match = { config.global.editor },    tag = "text" },
    { match = { "urxvt.irssi" },           tag = "irc" },
    { match = { "urxvt.mutt" },            tag = "mail" },
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
-- }}}
-- {{{ Obvious
if have_obvious then
    obvious.clock.set_editor(config.global.editor)
    obvious.clock.set_shortformat(function ()
        local week = tonumber(os.date("%W")) + 1
        return "%H%M ("..week..") "
    end)
    obvious.clock.set_longformat(function ()
        local week = tonumber(os.date("%W")) + 1
        return "%d%m ("..week..") "
    end)
end
-- }}}
-- }}}
-- {{{ Spit out warning messages if some libs are not found
if not have_obvious then
    naughty.notify({ text = "Obvious could not be loaded by 'require()':\n" .. obvious, title = "Obvious missing", timeout = 0 })
end
if not have_tagger then
    naughty.notify({ text = "Tagger could not be loaded by 'require()':\n" .. tagger, title = "Tagger missing", timeout = 0 })
end
if not have_strict then
    naughty.notify({ text = "strict could not be loaded by 'require()', some checks for code quality won't work:\n" .. strict, title = "strict missing", timeout = 0 })
end
-- }}}
-- {{{ Widgets
-- {{{ tag list
tl_taglist = { }
for s = 1, screen.count() do
    tl_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all,
                                             awful.util.table.join(
                                                awful.button({ }, 1, awful.tag.viewonly),
                                                awful.button({ }, 4, awful.tag.viewnext),
                                                awful.button({ }, 5, awful.tag.viewprev) ))
end
-- }}}
-- {{{ task list
tl_tasklist = { }
for s = 1, screen.count() do
    tl_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, { })
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
                                have_obvious and {
                                    textbox(" "),
                                    obvious.volume_alsa(),
                                    textbox(" "),
                                    obvious.battery(),
                                    s == screen.count() and st_systray,
                                    textbox(" "),
                                    obvious.clock(),
                                    ["layout"] = awful.widget.layout.horizontal.rightleft,
                                },
                                {
                                    tl_tasklist[s],
                                    ["layout"] = awful.widget.layout.horizontal.flex
                                },
                                ["layout"] = awful.widget.layout.horizontal.leftright,
                                ["height"] = wi_widgets[s].height
                            }
end
-- }}}
-- }}}
-- {{{ Key bindings
-- {{{ System specific keybindings (decided upon based on hostname)
systemkeys = { }
if config.global.hostname == "hydrogen" then
    systemkeys = awful.util.table.join(
        -- {{{ Tags
        awful.key({ }, "XF86Back", awful.tag.viewprev),
        awful.key({ }, "XF86Forward", awful.tag.viewnext),
        -- }}}
        -- {{{ Screen focus
        awful.key({ config.global.modkey }, "XF86Back", function () screenfocus(1) end),
        awful.key({ config.global.modkey }, "XF86Forward", function () screenfocus(-1) end),
        -- }}}
        -- {{{ CMUS control
        awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("cmus-remote -r", false) end),
        awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("cmus-remote -u", false) end),
        awful.key({ }, "XF86AudioNext", function () awful.util.spawn("cmus-remote -n", false) end),
        awful.key({ }, "XF86AudioStop", function () awful.util.spawn("cmus-remote -s", false) end)
        -- }}}
    )
elseif config.global.hostname == "beryllium" then
    systemkeys = awful.util.table.join(
        -- {{{ Tags
        awful.key({ config.global.modkey }, "Page_Up", awful.tag.viewprev),
        awful.key({ config.global.modkey }, "Page_Down", awful.tag.viewnext),
        -- }}}
        -- {{{ Screen focus
        awful.key({ config.global.modkey, "Mod1" }, "Page_Up", function () screenfocus(1) end),
        awful.key({ config.global.modkey, "Mod1" }, "Page_Down", function () screenfocus(-1) end),
        -- }}}
        -- {{{ CMUS control
        awful.key({ "Mod4" }, "Left", function () awful.util.spawn("cmus-remote -r", false) end),
        awful.key({ "Mod4" }, "Down", function () awful.util.spawn("cmus-remote -u", false) end),
        awful.key({ "Mod4" }, "Right", function () awful.util.spawn("cmus-remote -n", false) end),
        awful.key({ "Mod4" }, "Up", function () awful.util.spawn("cmus-remote -s", false) end)
        -- }}}
    )
end
-- }}}
globalkeys = awful.util.table.join(
    systemkeys,
    -- {{{ Tags
    awful.key({ config.global.modkey }, "r", awful.tag.history.restore),
    have_tagger and awful.key({ config.global.modkey }, "q", function () tagger.add(mouse.screen, { switch = true }) end),
    have_tagger and awful.key({ config.global.modkey }, "w", tagger.remove),
    have_tagger and awful.key({ config.global.modkey }, "e", tagger.rename),
    have_tagger and awful.key({ config.global.modkey, "Mod4" }, "Left", tagger.moveleft),
    have_tagger and awful.key({ config.global.modkey, "Mod4" }, "Right", tagger.moveright),
    have_tagger and awful.key({ config.global.modkey, "Mod4" }, "XF86Back", tagger.movescreenleft),
    have_tagger and awful.key({ config.global.modkey, "Mod4" }, "XF86Forward", tagger.movescreenright),
    -- }}}
    -- {{{ Misc
    awful.key({ config.global.modkey }, "l", nil, function () awful.util.spawn("xtrlock", false) end),
    awful.key({ config.global.modkey, "Mod1" }, "r", awesome.restart),

    -- hide / unhide current screens wibox
    awful.key({ config.global.modkey, "Mod1" }, "w", function ()
        local w = wi_widgets[mouse.screen]
        w.visible = not w.visible
    end),
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
    have_obvious and awful.key({ }, "XF86AudioRaiseVolume", function () obvious.volume_alsa.raise(0, "Master") end),
    have_obvious and awful.key({ }, "XF86AudioLowerVolume", function () obvious.volume_alsa.lower(0, "Master") end),
    have_obvious and awful.key({ }, "XF86AudioMute", function () obvious.volume_alsa.mute(0, "Master") end)
-- }}}
)
-- {{{ Tags
for i = 1, 9 do
    table.foreach(awful.key({ config.global.modkey }, i,
            function ()
                awful.tag.viewonly(screen[mouse.screen]:tags()[i])
            end), function(_, k) table.insert(globalkeys, k) end)

    table.foreach(awful.key({ config.global.modkey, "Mod1" }, i,
            function ()
                if client.focus then
                    awful.client.movetotag(screen[mouse.screen]:tags()[i])
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
opacities_focus   = { }
opacities_unfocus = { }
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

    local properties = { }
    for k, v in pairs(config.apps) do
        for j, m in pairs(v.match) do
            if name:match(m) or instance:match(m) or class:match(m) then
                for l, n in pairs(v) do
                    properties[l] = n
                end
            end
        end
    end

    if properties.float ~= nil then
        awful.client.floating.set(c, properties.float)
        c:raise()
    end
    if properties.tag then
        if have_tagger then
            awful.client.movetotag(tagger.apptag(properties.tag, {}, c), c)
        else
            local t = screen[c.screen]:tags()
            for k, v in pairs(t) do
                if v.name == properties.tag then
                    awful.client.movetotag(v)
                    break
                end
            end
        end
    end
    if properties.opacity_u then
        opacities_unfocus[c] = properties.opacity_u
    end
    if properties.opacity_f then
        opacities_focus[c] = properties.opacity_f
    end

    if not startup and awful.client.floating.get(c) then
        awful.placement.centered(c, c.transient_for)
        awful.placement.no_offscreen(c)
    end

    c:keys(clientkeys)

    if startup then
        local ch = awful.client.focus.history.get()
        if ch then
            client.focus = ch
        end
    else
        client.focus = c
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
        if awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
end)
-- }}}
-- }}}
