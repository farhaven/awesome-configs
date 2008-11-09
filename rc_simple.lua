require('awful')
require('invaders')

-- {{{ misc
border_width 	= 1
border_normal 	= "#333333"
border_focus	= "#909090"
fg_normal	= "#FFFFFF"
bg_normal	= "#333333"
-- }}}
-- {{{ Variable definitions
modkey = "Mod3"
layout_path = "/usr/local/share/awesome/icons/layouts/"

layouts =
{	"tile",
    	"tileleft",
    	"tilebottom",
    	"tiletop",
    	"floating"
}
-- }}}
-- {{{ Tags
tags = {}
for s = 1, screen.count() do
    	tags[s] = {}
    	tags[s][1] = tag({ name = " WWW ", layout = layouts[3], mwfact = 0.7, nmaster = 1 }) 
    	tags[s][2] = tag({ name = " Term ", layout = layouts[3] }) 
    	tags[s][3] = tag({ name = " Misc ", layout = layouts[3] })
    	tags[s][4] = tag({ name = " Chat ", layout = layouts[1], mwfact = 0.7, nmaster = 1 })
    	tags[s][5] = tag({ name = " Mail ", layout = layouts[3] })
    	tags[s][6] = tag({ name = " Float ", layout = layouts[5] })

    	for tagnumber = 1, #tags[s] do
        	tags[s][tagnumber].screen = s
    	end
    	tags[s][1].selected = true
end
-- }}}
-- {{{ Widgets
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
-- {{{ layout box
lb_layout = {}
for s = 1, screen.count() do
    	lb_layout[s] = widget({ type = "imagebox", name = "lb_layout", align = "left" })
	lb_layout[s]:buttons({
		button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		button({ }, 3, function () awful.layout.inc(layouts, -1) end)
	})
	lb_layout[s].image = image(layout_path .. "tilew.png")
end
-- }}}
-- {{{ widget box
wi_widgets = {}
for s = 1, screen.count() do
	wi_widgets[s] = wibox({ position = "top", name = "wi_widgets" .. s, fg = fg_normal, bg = bg_normal})
    	wi_widgets[s].widgets = {
		tl_taglist[s],
        lb_layout[s],
		tb_prompt,
		tl_tasklist,
  		tb_clock
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
keybinding({ modkey, "Mod1" }, "i", function () invaders.run({ }) end):add()
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
keybinding({ modkey }, "XF86Back", function () 
						awful.screen.focus(1)
						local coords = mouse.coords()
						coords['x'] = coords['x'] + 1
						coords['y'] = coords['y'] + 2
						mouse.coords(coords)
					end):add()
keybinding({ modkey }, "XF86Forward", function () 
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
        c.border_color = border_focus
end)
-- }}}
-- {{{ unfocus
awful.hooks.unfocus.register(function (c)
        c.border_color = border_normal
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
    	c.border_width = border_width
    	c.border_color = border_normal
    	client.focus = c

	c.honorsizehints = true
end)
-- }}}
-- {{{ arrange
awful.hooks.arrange.register(function (screen)
    	lb_layout[screen].image = image(layout_path .. awful.layout.get(screen) .. "w.png")
    	if not client.focus then
        	local c = awful.client.focus.history.get(screen, 0)
        	if c then client.focus = c end
    	end
end)
-- }}}
-- }}}
