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
-- }}}
-- {{{ Variable definitions
-- {{{ theme setup
theme_path = os.getenv("HOME") .. "/.config/awesome/themes/foo.theme"
alarmfile = os.getenv("HOME") .. "/.config/awesome/alarms"
-- }}}
-- {{{ misc
terminal = "urxvtc"
editor = "gvim"

-- Default modkey.
-- I remapped Caps Lock to Mod3 using the following commands for xmodmap:
-- xmodmap -e "clear lock"
-- xmodmap -e "add mod3 = Caps_Lock"
-- finally this utterly useless key found a new and good use :)
modkey = "Mod3"
-- }}} 
-- {{{ layouts
layouts =
{   "tile",
    "tileleft",
    "tilebottom",
    "tiletop",
    "fairh",
    "floating"
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
    local icon
    icon = "<bg color='" .. beautiful.bg_focus.."'/><span color='" .. beautiful.fg_focus .. "'>"
    icon = icon .. layout_icons[awful.layout.get(s)]
    icon = icon .. "</span>"
    return icon
end
-- }}} 
-- {{{ floatings
floatings =
{   ["mplayer"] = true,
    ["gimp"]    = true,
    ["xcalc"]   = true,
    ["xdialog"] = true,
    ["nitrogen"]= true,
    ["zsnes"]   = true,
    ["xine"]    = true,
    ["xmessage"]= true,
    ["xnest"]   = true,
    ["netzwerkprotokoll"] = true
}
-- }}}
-- {{{ apptags
apptags =
{   ["urxvt.weechat"]   = {tag = 4},
    ["urxvt.cmus"]      = {tag = 3},
    ["claws-mail"]      = {tag = 5},
    ["urxvt"]           = {tag = 2},
    ["firefox"]         = {tag = 1},
    ["gvim"]            = {tag = 3}
}
-- }}}
-- }}}
-- {{{ Initialization
beautiful.init(theme_path)
awful.beautiful.register(beautiful)
-- }}}
-- {{{ Naughty setup
naughty.config.bg           = beautiful.bg_normal
naughty.config.fg           = beautiful.fg_normal
naughty.config.screen       = 1
naughty.config.border_width = 2
naughty.config.border_color = beautiful.fg_normal
-- }}}
-- {{{ Tags
tags = {}
for s = 1, screen.count() do
        tags[s] = {}
        tags[s][1] = tag({ name = "WWW",   layout = layouts[3], mwfact = 0.7, nmaster = 1 }) 
        tags[s][2] = tag({ name = "Term",  layout = layouts[5] }) 
        tags[s][3] = tag({ name = "Misc",  layout = layouts[5] })
        tags[s][4] = tag({ name = "Chat",  layout = layouts[1], mwfact = 0.7, nmaster = 1 })
        tags[s][5] = tag({ name = "Mail",  layout = layouts[3] })
        tags[s][6] = tag({ name = "Float", layout = layouts[6] })

        for tagnumber = 1, #tags[s] do
            tags[s][tagnumber].screen = s
        end
        tags[s][1].selected = true
end
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
                                               { button({ }, 1, function (object, c) client.focus = c; c:raise() end) })
end
-- }}}
-- {{{ prompt
tb_prompt = widget({ type = "textbox", name = "tb_prompt", align = "left" })
-- }}}
-- {{{ battery
tb_battery = widget({ type = "textbox", name = "tb_battery", align = "right" })
function battmon()
    battery_status = ""
    if file_is_readable("/sys/devices/platform/smapi/BAT0/remaining_percent") then
        for line in io.lines("/sys/devices/platform/smapi/BAT0/remaining_percent") do
            battery_status = battery_status .. line .. "% "
        end
    end
    if file_is_readable("/sys/devices/platform/smapi/BAT0/state") then
        for line in io.lines("/sys/devices/platform/smapi/BAT0/state") do
            if not string.find(line, "discharging", 1, true) then
                battery_status = battery_status .. line
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
    tb_battery.text = battery_status .. "|"
end
awful.hooks.timer.register(60, battmon)
battmon()
-- }}}
-- {{{ wlan
pb_wlan                 = widget({ type = "progressbar", name = "pb_wlan", align = "right" })
pb_wlan.width           = 8
pb_wlan.height          = 0.80
pb_wlan.border_padding  = 1
pb_wlan.tick_count      = 0
pb_wlan.vertical        = true
pb_wlan:bar_properties_set("wlan", 
                          { ["bg"] = beautiful.bg_normal,
                            ["fg"] = "#FF0000",
                            ["fg_center"] = "#FFFF00",
                            ["fg_end"] = "#00FF00",
                            ["fg_off"] = "#000000",
                            ["border_color"] = beautiful.border_focus })
function wireless()
    local device = "wlan0"
    if file_is_readable("/proc/net/wireless") then
        link = io.popen("grep -e \"" .. device .. "\" /proc/net/wireless | awk '{print $3}'"):read()
        link = string.gsub(link, "[.]", "")
        link = string.format("% 3d", link)

        pb_wlan:bar_data_add("wlan", link)
    end
end
wireless()
awful.hooks.timer.register(30, wireless)
-- }}}
-- {{{ volume
pb_volume = widget({ type = "progressbar", name = "pb_volume", align = "right" })
pb_volume:buttons({
    button({ }, 4, function () volume("up", pb_volume) end),
    button({ }, 5, function () volume("down", pb_volume) end),
    button({ }, 1, function () volume("mute", pb_volume) end)
})
pb_volume.width          = 8
pb_volume.height         = 0.80
pb_volume.border_padding = 1
pb_volume.ticks_count    = 0
pb_volume.vertical       = true

pb_volume:bar_properties_set("vol", 
    {   ["bg"] = beautiful.bg_normal,
        ["fg"] = "#FF0000",
        ["fg_center"] = "#FFFF00",
        ["fg_end"] = "#00FF00",
        ["fg_off"] = "#000000",
        ["border_color"] = beautiful.border_focus
     })
function volume (mode)
    local cardid  = 0
    local channel = "Master"
    if mode == "update" then
        local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")
        
        local volume = string.match(status, "(%d?%d?%d)%%")
        volume = string.format("% 3d", volume)

        status = string.match(status, "%[(o[^%]]*)%]")

        if string.find(status, "on", 1, true) then
            pb_volume:bar_properties_set("vol", {["bg"] = "#000000"})
        else
            pb_volume:bar_properties_set("vol", {["bg"] = beautiful.bg_focus})
        end
        pb_volume:bar_data_add("vol", volume)
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
clock = { }
clock.widget = widget({ type = "textbox", name = "clock", align = "right" })
clock.widget.text = os.date("%H:%M:%S") .. " (X) "
clock.widget:buttons({
    button({ }, 3, function () awful.menu.new({ id="clock", items= {{ "edit todo", editor.." ~/todo" },
                                                                    { "edit alarms", editor.." "..alarmfile}} } ) 
                   end ) })

clock.fulldate = false
function clock.update ()
    local date
    if not clock.fulldate then
        date = os.date("%H:%M:%S")
    else
        date = os.date()
    end
    date = date .. " ("
    if (os.date("%W") % 2) == 0 then
        date = date .. "U) "
    else
        date = date .. "G) "
    end
    
    clock.widget.text = date
    if os.date("%S") == "00" then
        for line in io.lines(alarmfile) do
            if string.find(line, os.date("%H:%M"), 1, true) then
                naughty.notify({ text = line })
            end
        end
    end
end
awful.hooks.timer.register(1, clock.update)

function clock.widget.mouse_enter() clock.fulldate = true  end
function clock.widget.mouse_leave() clock.fulldate = false end
-- }}}
-- {{{ layout box
lb_layout = {}
for s = 1, screen.count() do
    lb_layout[s] = widget({ type = "textbox", name = "lb_layout", align = "left" })
    lb_layout[s]:buttons({
        button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        button({ }, 3, function () awful.layout.inc(layouts, -1) end)
    })
    lb_layout[s].text = getlayouticon(s)
end
-- }}}
-- {{{ widget box
wi_widgets = {}
for s = 1, screen.count() do
    wi_widgets[s] = wibox({ position = "top", 
                            name = "wi_widgets" .. s, 
                            fg = beautiful.fg_normal, 
                            bg = beautiful.bg_normal })
    wi_widgets[s].widgets = {   tl_taglist[s],
                                lb_layout[s],
                                tb_prompt,
                                tl_tasklist[s],
                                tb_spacer,
                                pb_wlan,
                                tb_spacer,
                                pb_volume,
                                tb_spacer,
                                tb_battery,
                                tb_spacer,
                                clock.widget
                            }
    wi_widgets[s].screen = s
end
-- }}}
-- }}}
-- {{{ Key bindings
-- {{{ Tags
keynumber = 0
for s = 1, screen.count() do
       keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    keybinding({ modkey }, i,
        function ()
            local screen = mouse.screen
            if tags[screen][i] then
                   awful.tag.viewonly(tags[screen][i])
            end
        end):add()

    keybinding({ modkey, "Mod1" }, i,
           function ()
               if client.focus then
                   if tags[client.focus.screen][i] then
                       awful.client.movetotag(tags[client.focus.screen][i])
                   end
            end
        end):add()
end

keybinding({ }, "XF86Back", awful.tag.viewprev):add()
keybinding({ }, "XF86Forward", awful.tag.viewnext):add()
-- }}}
-- {{{ Misc
keybinding({ modkey, "Mod1" }, "i", invaders.run):add()
keybinding({ modkey, "Mod1" }, "l", function () os.execute("xscreensaver-command -lock") end):add()
keybinding({ modkey, "Mod1" }, "r", awesome.restart):add()
keybinding({ modkey }, "Return", function () 
            awful.prompt.run({ prompt = " $ " }, tb_prompt, awful.util.spawn, awful.completion.bash, os.getenv("HOME") .. "/.cache/awesome/history") 
            end):add()
keybinding({ modkey, "Mod1" }, "Return", function ()
            awful.prompt.run({ prompt = " ? " }, tb_prompt, awful.util.eval, awful.prompt.bash, os.getenv("HOME") .. "/.cache/awesome/history_eval") 
            end):add()
-- }}}
-- {{{ Client / Focus manipulation
keybinding({ modkey, "Mod1" }, "c", function () client.focus:kill() end):add()

keybinding({ modkey }, "Up", function () awful.client.focus.byidx(-1); client.focus:raise() end):add()
keybinding({ modkey }, "Down", function () awful.client.focus.byidx(1);  client.focus:raise() end):add()
keybinding({ modkey }, "Left", function () awful.client.swap(1) end):add()
keybinding({ modkey }, "Right", function () awful.client.movetoscreen() end):add()
keybinding({ modkey }, "XF86Back",  function () 
                                        awful.screen.focus(1)
                                        local coords = mouse.coords()
                                        coords['x'] = coords['x'] + 1
                                        coords['y'] = coords['y'] + 2
                                        mouse.coords(coords)
                                    end):add()
keybinding({ modkey }, "XF86Forward",   function () 
                                            awful.screen.focus(-1) 
                                            local coords = mouse.coords()
                                            coords['x'] = coords['x'] + 1
                                            coords['y'] = coords['y'] + 2
                                            mouse.coords(coords)
                                        end):add()
-- }}}
-- {{{ Layout manipulation
keybinding({ modkey, "Mod1" }, "Down", function () awful.tag.incmwfact(0.01) end):add()
keybinding({ modkey, "Mod1" }, "Up", function () awful.tag.incmwfact(-0.01) end):add()
keybinding({ modkey }, " ", function () awful.layout.inc(layouts, 1) end):add()
-- }}}
-- {{{ Audio
-- Control cmus
keybinding({ }, "XF86AudioPrev", function () awful.util.spawn("cmus-remote -r") end):add()
keybinding({ }, "XF86AudioPlay", function () awful.util.spawn("cmus-remote -u") end):add()
keybinding({ }, "XF86AudioNext", function () awful.util.spawn("cmus-remote -n") end):add()
keybinding({ }, "XF86AudioStop", function () awful.util.spawn("cmus-remote -s") end):add()

-- Audio control
keybinding({ }, "XF86AudioRaiseVolume", function () volume("up", pb_volume) end):add()
keybinding({ }, "XF86AudioLowerVolume", function () volume("down", pb_volume) end):add()
keybinding({ }, "XF86AudioMute", function () volume("mute", pb_volume) end):add()
-- }}}
-- }}}
-- {{{ Hooks
-- {{{ focus
awful.hooks.focus.register(function (c)
    c.border_color = beautiful.border_focus
end)
-- }}}
-- {{{ unfocus
awful.hooks.unfocus.register(function (c)
    c.border_color = beautiful.border_normal
end)
-- }}}
-- {{{ mouse_enter
awful.hooks.mouse_enter.register(function (c)
    client.focus = c
end)
-- }}}
-- {{{ manage
awful.hooks.manage.register(function (c)
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, function (c) c:mouse_move() end),
        button({ modkey }, 3, function (c) c:mouse_resize() end)
    })

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal
    client.focus = c

    local cls  = c.class:lower()
    local inst = c.instance:lower()
    local name = c.name:lower()
    
    if floatings[cls] then
        c.floating = floatings[cls]
    elseif floatings[inst] then
        c.floating = floatings[inst]
    elseif floatings[name] then
        c.floating = floatings[name]
    end

    local target
    if apptags[inst] then
           target = apptags[inst]
    elseif apptags[cls] then
        target = apptags[cls]
    elseif apptags[name] then
        target = apptags[inst]
    end

    if target then
        awful.client.movetotag(tags[c.screen][target.tag], c)
    end

    c.honorsizehints = true
    awful.client.setslave(c)
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
-- }}}
