require('awful')
require('beautiful')
require('invaders') -- Space Invaders for Awesome
require('naughty') -- Naughtyfications

-- {{{ Misc functions
-- {{{ file_is_readable(fname) checks whether file `fname' is readable
function file_is_readable(fname)
    local fh = io.open(fname)
    local rv = false
    if fh then
        rv = true
        fh:close()
    end
    return rv
end
-- }}}
-- {{{ dump_table(t, depth)
function dump_table(t, depth)
    print("")
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
end
-- }}}
-- }}}
-- {{{ Variable definitions
-- {{{ theme setup
theme_path = os.getenv("HOME") .. "/.config/awesome/themes/foo.theme"
-- }}}
-- {{{ misc
terminal = "urxvtc"
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
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.floating,
}
layout_icons =
{   ["tile"] = "[]=",
    ["tileleft"] = "=[]",
    ["tilebottom"] = "[v]",
    ["tiletop"] = "[^]",
    ["fairv"] = "[|]",
    ["fairh"] = "[-]",
    ["floating"] = "o_O"
}
function getlayouticon(s)
    if not awful.layout.get(s) then return "   " end
    return layout_icons[awful.layout.getname(awful.layout.get(s))]
end
-- }}} 
-- }}}
-- {{{ Initialization
beautiful.init(theme_path)
-- }}}
-- {{{ Naughty setup
naughty.config.bg           = beautiful.bg_normal
naughty.config.fg           = beautiful.fg_normal
naughty.config.screen       = 1
naughty.config.border_width = 2
naughty.config.presets.normal.border_color = beautiful.fg_normal
naughty.config.presets.normal.hover_timeout = 0.3
-- }}}
-- {{{ Tags & Clients
-- {{{ Tags
config = { }
config.tags = {
    { name = "Term", layout = layouts[4], ncols = 2 },
    { name = "WWW",  layout = layouts[3], mwfact = 0.7, nmaster = 1 },
    { name = "Misc", layout = layouts[4] },
    { name = "Text", layout = layouts[4] },
    { name = "Chat", layout = layouts[1], mwfact = 0.7, nmaster = 1 },
    { name = "Mail", layout = layouts[1] },
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
    end
    tags[s][1].selected = true
end
-- }}}
-- {{{ Clients
config.apps = {
    -- {{{ floating setup
    { match = { "mplayer", "gimp", "xcalc", "xdialog" }, float = true },
    { match = { "nitrogen", "zsnes", "xine", "xmessage" }, float = true },
    { match = { "xnest", "netzwerkprotokoll", "event tester" }, float = true },
    { match = { "pinentry", "virtualbox", "wicd%-client%.py" }, float = true },
    --}}}
    -- {{{ apptags
    { match = { "urxvt" }, tag = 1 },
    { match = { "urxvt.irssi" }, tag = 5 },
    { match = { "pidgin" }, tag = 5 },
    { match = { "urxvt.cmus" }, tag = 3 },
    { match = { "claws%-mail" }, tag = 6 },
    { match = { "firefox", "dillo" }, tag = 2 },
    { match = { "gvim" }, tag = 4 },
    { match = { "xpdf" }, tag = 3 },
    -- }}}
}
-- }}}
-- }}}
-- {{{ Widgets
-- {{{ spacer
tb_spacer       = widget({ type = "textbox", name = "tb_spacer", align = "right" })
tb_spacer.width = 3
-- }}}
-- {{{ tag list
tl_taglist = { }
for s = 1, screen.count() do
    tl_taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, 
                                             { button({ }, 4, awful.tag.viewnext),
                                               button({ }, 5, awful.tag.viewprev) })
end
-- }}}
-- {{{ task list
tl_tasklist = { }
for s = 1, screen.count() do
    tl_tasklist[s] = awful.widget.tasklist.new(function (c) return awful.widget.tasklist.label.currenttags(c, s) end, 
                                               { button({ }, 1, function (object, c) client.focus = c; c:raise() end),
                                                 button({ }, 3, function () awful.menu.clients({ width = 250 }) end),
                                               })
end
-- }}}
-- {{{ prompt
tb_prompt = widget({ type = "textbox", name = "tb_prompt", align = "left" })
-- }}}
-- {{{ battery
battmon = { }
battmon.widget = widget({ type = "textbox", name = "tb_battery", align = "right" })
-- {{{ update                                              
function battmon.update()
    local battery_status = ""
    if file_is_readable("/sys/devices/platform/smapi/BAT0/remaining_percent") then
        for line in io.lines("/sys/devices/platform/smapi/BAT0/remaining_percent") do
            line = tonumber(line)
            local color = "#FF0000"
            if line > 35 and line < 60 then
                color = "#FFFF00"
            elseif line >= 40 then
                color = "#00FF00"
            end
            battery_status = "<span color=\"" .. color .. "\">" .. line .. "%</span>"
        end
    end
    if file_is_readable("/sys/devices/platform/smapi/BAT0/state") then
        for line in io.lines("/sys/devices/platform/smapi/BAT0/state") do
            if not string.find(line, "discharging", 1, true) then
                battery_status = battery_status .. " " .. line
            end
        end
    end
    if file_is_readable("/sys/devices/platform/smapi/BAT0/remaining_running_time") then
        for line in io.lines("/sys/devices/platform/smapi/BAT0/remaining_running_time") do
            if not string.find(line, "not", 1, true) then
                minutes = line % 60
                hours = math.floor(line / 60)
                battery_status = battery_status .. " " .. hours .. ":" 
                if minutes < 10 then
                    battery_status = battery_status .. "0"
                end
                battery_status = battery_status    .. minutes 
            end
        end
    end
    if battery_status == "" then
        battery_status = "tp_smapi not loaded"
    end
    battmon.widget.text = battery_status .. "|"
end
-- }}}
-- {{{ detailed info
function battmon.detail ()
    local fd = io.popen("acpitool")
    local d = fd:read("*all")
    fd:close()
    naughty.notify({ text = d })
end
-- }}}
battmon.widget:buttons({ button({ }, 1, battmon.detail)}) 
awful.hooks.timer.register(60, battmon.update)
battmon.update()
-- }}}
-- {{{ volume
tb_volume = widget({ type = "textbox", name = "tb_volume", align = "right" })
tb_volume:buttons({
    button({ }, 4, function () volume("up", pb_volume) end),
    button({ }, 5, function () volume("down", pb_volume) end),
    button({ }, 1, function () volume("mute", pb_volume) end)
})

function volume (mode)
    local cardid  = 0
    local channel = "Master"
    if mode == "update" then
        local fd = io.popen("amixer -c " .. cardid .. " -- sget " .. channel)
        local status = fd:read("*all")
        fd:close()
        
        local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))

        status = string.match(status, "%[(o[^%]]*)%]")

        local color = "#FF0000"
        if string.find(status, "on", 1, true) then
             color = "#00FF00"
        end
        status = ""
        for i = 1, math.floor(volume / 10) do
            status = status .. "|"
        end
        for i = math.floor(volume / 10) + 1, 10 do
            status = status .. "-"
        end
        status = "-[" ..status .. "]+"
        tb_volume.text = "<span color=\"" .. color .. "\">" .. status .. "</span>|"
    elseif mode == "up" then
        awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+")
        volume("update")
    elseif mode == "down" then
        awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-")
        volume("update")
    else
        awful.util.spawn("amixer -c " .. cardid .. " sset " .. channel .. " toggle")
        volume("update")
    end
end
volume("update")
awful.hooks.timer.register(10, function () volume("update") end)
-- }}}
-- {{{ clock
-- This widget has an alarmfile, which contains stuff to remember like this:
-- 14:30 get pizza from oven
-- These alarms (one per line) are shown with naughty. If one alarm is shown,
-- the clock will change its colors to indicate that. If you then click on
-- it, all alarms since the last click are shown.

clock = { }
clock.alarmfile = os.getenv("HOME") .. "/.config/awesome/alarms"
clock.widget = widget({ type = "textbox", name = "clock", align = "right" })
clock.menu = awful.menu.new({ id = "clock", items = {{ "edit todo", editor.." ~/todo" },
                                                     { "edit alarms", editor.." "..clock.alarmfile }} } ) 
clock.widget:buttons({
    button({ }, 3, function () clock.menu:toggle() end ), 
    button({ }, 1, function ()
                        for k, v in pairs(clock.alarms) do
                            naughty.notify({ text = v })
                        end
                        clock.alarms = { } 
                        clock.widget.bg = beautiful.bg_normal
                   end ) })

clock.fulldate = false
clock.alarms = { }

-- {{{ update
function clock.update ()
    local date
    if not clock.fulldate then
        date = os.date("%H:%M (") .. (tonumber(os.date("%W")) + 1)..") "
    else
        date = os.date()
    end
    
    if #clock.alarms > 0 then
        date = "<span color='" .. beautiful.fg_focus .. "'>"..date.."</span>"
        clock.widget.bg = beautiful.bg_focus
    else
        clock.widget.bg = beautiful.bg_normal
    end
    
    clock.widget.text = date
    
    for line in io.lines(clock.alarmfile) do
        if string.match(line, "^"..os.date("%H:%M")) then
            naughty.notify({ text = line })
            local add = true
            for _, v in pairs(clock.alarms) do
                if v == line then
                    add = false
                    break
                end
            end
            if add then table.insert(clock.alarms, line) end
        end
    end
end
-- }}}
clock.update()
awful.hooks.timer.register(60, clock.update)

function clock.widget.mouse_enter() clock.fulldate = true ; clock.update() end
function clock.widget.mouse_leave() clock.fulldate = false; clock.update() end
-- }}}
-- {{{ layout box
lb_layout = { }
for s = 1, screen.count() do
    lb_layout[s] = widget({ type = "textbox", name = "lb_layout", align = "left" })
    lb_layout[s]:buttons({
        button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        button({ }, 3, function () awful.layout.inc(layouts, -1) end)
    })
    lb_layout[s].text = getlayouticon(s)
    lb_layout[s].bg = beautiful.bg_focus
end
-- }}}
-- {{{ systray
st_systray = widget({ type = "systray", align = "right" })
-- }}}
-- {{{ widget box
wi_widgets = {}
for s = 1, screen.count() do
    wi_widgets[s] = wibox({ position = "top", 
                            name = "wi_widgets" .. s, 
                            fg = beautiful.fg_normal, 
                            bg = beautiful.bg_normal
                          })
    wi_widgets[s].widgets = {   tl_taglist[s],
                                lb_layout[s],
                                tb_prompt,
                                tl_tasklist[s],
                                tb_spacer,
                                tb_spacer,
                                tb_volume,
                                tb_spacer,
                                battmon.widget,
                                tb_spacer,
                                s == 1 and st_systray or nil, 
                                clock.widget
                            }
    wi_widgets[s].screen = s
    wi_widgets[s]:buttons({
        button({ modkey }, 1, awful.mouse.wibox.move)
    })
end
-- }}}
-- }}}
-- {{{ Key bindings
-- {{{ Tags
for i = 1, 9 do
    key({ modkey }, i,
        function ()
            awful.tag.viewonly(tags[mouse.screen][i])
        end):add()

    key({ modkey, "Mod1" }, i, 
        function ()
            if client.focus then
                awful.client.movetotag(tags[mouse.screen][i])
            end
        end):add()
end

key({ }, "XF86Back", awful.tag.viewprev):add()
key({ }, "XF86Forward", awful.tag.viewnext):add()
-- }}}
-- {{{ Misc
key({ modkey, "Mod1" }, "i", invaders.run):add()
key({ modkey, "Mod1" }, "l", function () os.execute("xscreensaver-command -lock") end):add()
key({ modkey, "Mod1" }, "r", awesome.restart):add()

-- hide / unhide current screens wibox
key({ modkey, "Mod1" }, "w", function ()
                                        local w = wi_widgets[mouse.screen]
                                        if w.screen then
                                            w.screen = nil
                                        else
                                            w.screen = mouse.screen
                                        end
                                    end):add()
-- }}}
-- {{{ Prompts
key({ modkey }, "Return", function () 
            awful.prompt.run({ prompt = " $ " }, tb_prompt, awful.util.spawn, awful.completion.bash, os.getenv("HOME") .. "/.cache/awesome/history") 
            end):add()
key({ modkey, "Mod1" }, "Return", function ()
            awful.prompt.run({ prompt = " ? " }, tb_prompt, awful.util.eval, awful.prompt.bash, os.getenv("HOME") .. "/.cache/awesome/history_eval") 
            end):add()
-- }}}
-- {{{ Client / Focus manipulation
key({ modkey, "Mod1" }, "c", function () client.focus:kill() end):add()

key({ modkey }, "Up", function () awful.client.focus.byidx(-1); client.focus:raise() end):add()
key({ modkey }, "Down", function () awful.client.focus.byidx(1);  client.focus:raise() end):add()
key({ modkey }, "Left", function () awful.client.swap.byidx(1) end):add()
key({ modkey }, "Right", function () awful.client.movetoscreen() end):add()
key({ modkey }, "XF86Back",  function () 
                                        awful.screen.focus(1)
                                        local coords = mouse.coords()
                                        coords['x'] = coords['x'] + 1
                                        coords['y'] = coords['y'] + 2
                                        mouse.coords(coords)
                                    end):add()
key({ modkey }, "XF86Forward",   function () 
                                            awful.screen.focus(-1) 
                                            local coords = mouse.coords()
                                            coords['x'] = coords['x'] + 1
                                            coords['y'] = coords['y'] + 2
                                            mouse.coords(coords)
                                        end):add()
-- }}}
-- {{{ Layout manipulation
key({ modkey, "Mod1" }, "Down", function () awful.tag.incmwfact(0.01) end):add()
key({ modkey, "Mod1" }, "Up", function () awful.tag.incmwfact(-0.01) end):add()
key({ modkey }, " ", function () awful.layout.inc(layouts, 1) end):add()
-- }}}
-- {{{ Audio
-- Control cmus
key({ }, "XF86AudioPrev", function () awful.util.spawn("cmus-remote -r") end):add()
key({ }, "XF86AudioPlay", function () awful.util.spawn("cmus-remote -u") end):add()
key({ }, "XF86AudioNext", function () awful.util.spawn("cmus-remote -n") end):add()
key({ }, "XF86AudioStop", function () awful.util.spawn("cmus-remote -s") end):add()

-- Audio control
key({ }, "XF86AudioRaiseVolume", function () volume("up", pb_volume) end):add()
key({ }, "XF86AudioLowerVolume", function () volume("down", pb_volume) end):add()
key({ }, "XF86AudioMute", function () volume("mute", pb_volume) end):add()
-- }}}
-- }}}
-- {{{ Hooks
-- {{{ focus
awful.hooks.focus.register(function (c)
    c.border_color = beautiful.border_focus
    c.opacity = 1
end)
-- }}}
-- {{{ unfocus
awful.hooks.unfocus.register(function (c)
    c.border_color = beautiful.border_normal
    c.opacity = 0.6
end)
-- }}}
-- {{{ manage
awful.hooks.manage.register(function (c)
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey, "Mod1" }, 1, awful.mouse.client.dragtotag.border),
        button({ modkey }, 3, awful.mouse.client.resize)
    })

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    client.focus = c
    c.honorsizehints = true

    local instance = c.instance:lower()
    local class = c.class:lower()
    local name = c.name:lower()

    for k, v in pairs(config.apps) do
        for j, m in pairs(v.match) do
            if instance:match(m) or class:match(m) or name:match(m) then
                if v.float then
                    awful.client.floating.set(c, true)
                end
                if v.tag then
                    awful.client.movetotag(tags[c.screen][v.tag], c)
                end
                break
            end
        end
    end
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
    if awful.client.focus.filter(c) then
        client.focus = c
    end
end)
-- }}}
-- }}}
