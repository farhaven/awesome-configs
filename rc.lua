-- local have_strict, strict = pcall(require, 'strict') -- strict checking for unassigned variables, like perl's use strict
require('awful')
require('awful.autofocus')
require('awful.util')
require('beautiful')
require('naughty') -- Naughtyfications
require('wibox')
local have_obvious, obvious = pcall(require, 'obvious') -- Obvious widget library, get it from git://git.mercenariesguild.net/obvious.git
local have_tagger, tagger = pcall(require, 'tagger')  -- Dynamic Tagging

-- {{{ Functions
-- {{{ getlayouticon(layout)
function getlayouticon(s)
	if type(s) == "string" then
		return " " .. config.layout_icons[s] .. " "
	end
	if not awful.layout.get(s) then return "	 " end
	return " " .. config.layout_icons[awful.layout.getname(awful.layout.get(s))] .. " "
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
	local w = wibox.widget.textbox()
	w:set_text(content)
	table.insert(textboxes, w)
	return w
end
-- }}}
-- {{{ screenfocus(idx)
function screenfocus(idx)
	awful.screen.focus_relative(idx)
	local x = mouse.coords().x + 3
	local y = mouse.coords().y + 3
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
	["opacity_f" ]	= 1,
	["opacity_u" ]	= 0.65,
	["theme"]		= awful.util.getdir("config") .. "/themes/plan9/plan9.lua",
	["editor"]		= "gvim",
	["modkey"]		= "Mod3",
	["hostname"]	= "hydrogen"
}
beautiful.init(config.global.theme)
-- }}}
-- {{{ Layouts
-- {{{ layout table
config.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.top,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.max,
	awful.layout.suit.spiral
}
-- }}}
-- {{{ layout icons
config.layout_icons = {
	["tile"]			= "[]=",
	["tileleft"]	= "=[]",
	["tilebottom"]	= "[v]",
	["tiletop"]		= "[^]",
	["floating"]	= "><>",
	["max"]			= "[M]",
	["fairh"]		= "|H|",
	["fairv"]		= "|V|",
	["spiral"]		= "|@|",
}
-- }}}
-- }}}
-- {{{ Tags
config.tags = {
	{ name = "term", nmaster	= 2 },
	{ name = "cssh", nmaster	= 2 },
	{ name = "www",  mwfact		= 0.81 },
	{ name = "misc", layout		= config.layouts[3] },
	{ name = "text", mwfact		= 0.57 },
	{ name = "chat", mwfact		= 0.17 },
	{ name = "mail", layout		= config.layouts[2] },
	{ name = "pdf",  layout		= config.layouts[5] },
	{ name = "todo", layout		= config.layouts[4], mwfact = 0.7 },
	{ name = "media", mwfact	= 0.15, nmaster = 2 }
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
			awful.tag.setproperty(t, "ncol", v.ncol)
			awful.tag.setproperty(t, "icon", v.icon)
		end
	end
	awful.tag.viewonly(screen[s]:tags()[1])
end
-- }}}
-- {{{ Clients
config.apps = {
	-- {{{ floating setup
	{ match = { "xcalc", "xdialog", "event tester" },	float = true },
	{ match = { "zsnes", "xmessage", "pinentry" },		float = true },
	{ match = { "sauerbraten engine", "gnuplot" },		float = true },
	{ match = { "Open File", "dclock", "qemu" },			float = true },
	{ match = { "xclock" },										float = true },
	-- }}}
	-- {{{ apptags
	{ match = { "term", "^st$", "urxvt" },	tag = "term" },
	{ match = { "firefox", "surf" },			tag = "www" },
	{ match = { "mplayer", "vlc" },			tag = "media" },
	{ match = { "geeqie", "gimp" },			tag = "media" },
	{ match = { "audacity" },					tag = "media" },
	{ match = { "evince", "xpdf" },			tag = "pdf" },
	{ match = { "yadex" },						tag = "misc" },
	{ match = { config.global.editor },		tag = "text" },
	{ match = { "irssi" },						tag = "chat" },
	{ match = { "mutt" },						tag = "mail" },
	{ match = { "cssh" },						tag = "cssh" },
	{ match = { "transmission" },				tag = "trnt" },
	{ match = { "ebook%-viewer" },			tag = "ebook" },
	-- }}}
	-- {{{ opacity
	{ match = { "urxvt", "^st$", "^xterm$" },			opacity_f = 0.9 },
	{ match = { "gimp", "^xv", "mplayer", "vlc" },	opacity_u = 1 },
	-- }}}
}
-- }}}
-- {{{ Naughty
naughty.config.bg					= beautiful.bg_normal
naughty.config.fg					= beautiful.fg_normal
naughty.config.border_width	= beautiful.border_width or 2
naughty.config.presets.normal.screen			= screen.count()
naughty.config.presets.normal.border_color	= beautiful.fg_normal
naughty.config.presets.normal.hover_timeout	= 0.3
naughty.config.presets.normal.opacity	= 0.8
-- }}}
-- {{{ Obvious
if have_obvious then
	obvious.clock.set_editor(config.global.editor)
	obvious.clock.set_shortformat(function ()
		local week = tonumber(os.date("%W"))
		return obvious.lib.markup.font(beautiful.get().font, obvious.lib.markup.fg.color("#009000", "⚙ ") .. "%H%M (" .. week .. ") ")
	end)
	obvious.clock.set_longformat(function ()
		local week = tonumber(os.date("%W"))
		return obvious.lib.markup.font(beautiful.get().font, obvious.lib.markup.fg.color("#009000", "⚙ ") .. "%d%m (" .. week .. ") ")
	end)
end
-- }}}
-- }}}
-- {{{ Spit out warning messages if some libs are not found
if not have_obvious then
	naughty.notify({ text = "Obvious could not be loaded by 'require()':\n" .. obvious,
							title = "Obvious missing", timeout = 0 })
end
if not have_tagger then
	naughty.notify({ text = "Tagger could not be loaded by 'require()':\n" .. tagger,
							title = "Tagger missing", timeout = 0 })
end
if not have_strict and strict ~= nil then
	naughty.notify({ text = "strict could not be loaded by 'require()', some checks for code quality won't work:\n" .. strict,
							title = "strict missing", timeout = 0 })
end
-- }}}
-- {{{ Widgets
-- {{{ tag list
tl_taglist = { }
for s = 1, screen.count() do
	tl_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all,
		awful.util.table.join(
			awful.button({ }, 1, awful.tag.viewonly),
			awful.button({ }, 5, awful.tag.viewnext),
			awful.button({ }, 4, awful.tag.viewprev) ))
end
-- }}}
-- {{{ task list
tl_tasklist = { }
for s = 1, screen.count() do
	tl_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.focused, { })
end
-- }}}
-- {{{ layout box
lb_layout = { }
for s = 1, screen.count() do
	local w = wibox.widget.textbox()
	lb_layout[s] = wibox.widget.base.make_widget(w)
	lb_layout[s].widget = w
	lb_layout[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(config.layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(config.layouts, -1) end)
	))
	lb_layout[s].widget:set_text(getlayouticon(s))
	lb_layout[s].bg = beautiful.bg_normal
end
-- }}}
-- {{{ systray
st_systray = wibox.widget.systray()
-- }}}
-- {{{ widget box
wi_widgets = {}

for s = 1, screen.count() do
	wi_widgets[s] = awful.wibox({ position = "top", screen = s })
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(tl_taglist[s])
	left_layout:add(lb_layout[s])

	local right_layout = wibox.layout.fixed.horizontal()
	if have_obvious then
		right_layout:add(textbox(" "))
		right_layout:add(obvious.wlan("wpi0"):set_format(obvious.wlan.format_decibel).widget)
		right_layout:add(textbox(" "))
		right_layout:add(obvious.clock())
	end

	if s == screen.count() then
		right_layout:add(st_systray)
	end

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(tl_tasklist[s])
	layout:set_right(right_layout)

	wi_widgets[s]:set_widget(layout)
end
-- }}}
-- }}}
-- {{{ Key bindings
-- {{{ System specific keybindings (decided upon based on hostname)
systemkeys = { }
if config.global.hostname:find("hydrogen") then
	systemkeys = awful.util.table.join(
		-- {{{ Tags
		awful.key({ }, "XF86Back", awful.tag.viewprev),
		awful.key({ }, "XF86Forward", awful.tag.viewnext),
		-- }}}
		-- {{{ Screen focus
		awful.key({ config.global.modkey }, "XF86Back", function () screenfocus(1) end),
		awful.key({ config.global.modkey }, "XF86Forward", function () screenfocus(-1) end),
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
	have_tagger and awful.key({ config.global.modkey }, "t", function () tagger.match_names(mouse.screen, lb_layout[mouse.screen].widget) end),
	have_tagger and awful.key({ config.global.modkey, "Mod4" }, "Left", tagger.moveleft),
	have_tagger and awful.key({ config.global.modkey, "Mod4" }, "Right", tagger.moveright),
	have_tagger and awful.key({ config.global.modkey, "Mod4" }, "XF86Back", tagger.movescreenleft),
	have_tagger and awful.key({ config.global.modkey, "Mod4" }, "XF86Forward", tagger.movescreenright),
	-- }}}
	-- {{{ Misc
	awful.key({ config.global.modkey }, "l", nil, function () awful.util.spawn("xscreensaver-command -lock", false) end),
	awful.key({ config.global.modkey, "Mod1" }, "r", awesome.restart),

	-- hide / unhide current screens wibox
	awful.key({ config.global.modkey, "Mod1" }, "w", function ()
		local w = wi_widgets[mouse.screen]
		w.visible = not w.visible
	end),
-- }}}
	-- {{{ Prompts
	-- {{{ Run prompt
	awful.key({ config.global.modkey }, "Return", function () awful.util.spawn("fdb") end),
	awful.key({ }, "XF86Launch0", function () awful.util.spawn("fdb") end),
	-- }}}
	-- {{{ Program read prompt
	awful.key({ config.global.modkey, "Mod1" }, "Return", function() awful.util.spawn("fdb -v") end),
	-- }}}
	-- }}}
	-- {{{ Client / Focus manipulation
	awful.key({ config.global.modkey }, "c", function () if client.focus then client.focus:kill() end end),

	awful.key({ config.global.modkey }, "Up", function ()
		awful.client.focus.byidx(-1)
		if awful.layout.getname(awful.layout.get(client.focus.screen)) == "max" then
			client.focus:raise()
		end
	end),
	awful.key({ config.global.modkey }, "Down", function ()
		awful.client.focus.byidx(1)
		if awful.layout.getname(awful.layout.get(client.focus.screen)) == "max" then
			client.focus:raise()
		end
	end),
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
	awful.key({ config.global.modkey, "Mod1" }, "Right", function () awful.client.incwfact(-0.05) end)
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
	awful.key({ config.global.modkey }, "f", awful.client.floating.toggle),
	awful.key({ config.global.modkey, "Shift" }, "f", function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	end),
	awful.key({ config.global.modkey }, "a", function (c) c.sticky = not c.sticky end),
	awful.key({ config.global.modkey }, "j", function (c) c:lower() end),
	awful.key({ config.global.modkey }, "k", function (c) c:raise() end)
)
root.keys(globalkeys)
-- }}}
-- {{{ Signals
cprops = { }
-- {{{ focus
client.connect_signal("focus", function (c)
	c.border_color = beautiful.border_focus
	if cprops[c] then
		c.opacity = cprops[c].opacity_f
	end
end)
-- }}}
-- {{{ unfocus
client.connect_signal("unfocus", function (c)
	c.border_color = beautiful.border_normal
	if cprops[c] then
		c.opacity = cprops[c].opacity_u
	end
end)
-- }}}
-- {{{ manage stuff on per-client base
client.connect_signal("manage", function (c, startup)
	cprops[c] = {
		border_width = beautiful.border_width,
		opacity_f = config.global.opacity_f or 1,
		opacity_u = config.global.opacity_u or 1
	}

	local instance = c.instance and c.instance:lower() or ""
	local class = c.class and c.class:lower() or ""
	local name = c.name and c.name:lower() or ""
	local role = c.role and c.role:lower() or ""

	for k, v in pairs(config.apps) do
		for j, m in pairs(v.match) do
			if name:match(m) or instance:match(m) or class:match(m) or role:match(m) then
				for l, n in pairs(v) do
					cprops[c][l] = n
				end
			end
		end
	end

	if cprops[c].slave == true then
		awful.client.setslave(c)
	end
	if cprops[c].float ~= nil then
		awful.client.floating.set(c, cprops[c].float)
		c:raise()
	end
	if cprops[c].tag then
		if have_tagger then
			local t = { }
			for _, v in pairs(config.tags) do
				if v.name == cprops[c].tag then
					t = v
					break
				end
			end
			awful.client.movetotag(tagger.apptag(cprops[c].tag, t, c), c)
		else
			local t = screen[c.screen]:tags()
			for k, v in pairs(t) do
				if v.name == cprops[c].tag then
					awful.client.movetotag(v)
					break
				end
			end
		end
	end
	if c.fullscreen then
		c.border_width = 0
	elseif cprops[c].border_width then
		c.border_width = cprops[c].border_width
	end
end)
-- }}}
-- {{{ manage generic stuff
client.connect_signal("manage", function (c, startup)
	c:buttons(awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c end),
		awful.button({ config.global.modkey }, 1, awful.mouse.client.move),
		awful.button({ config.global.modkey }, 3, awful.mouse.client.resize)
	))
	c:keys(clientkeys)

	c.border_color = beautiful.border_normal

	c.size_hints_honor = true

	if not startup and awful.client.floating.get(c) and not c.fullscreen then
		awful.placement.centered(c, c.transient_for)
		awful.placement.no_offscreen(c)
	end

	if startup then
		local ch = awful.client.focus.history.get()
		if ch then
			client.focus = ch
		end
	else
		client.focus = c
	end
	c:connect_signal("property::urgent", function (c, prop)
		if not c.urgent then
			return
		end
		naughty.notify({ text = c.name .. " on " .. c:tags()[1].name , title = "Alert" })
	end)
end)
-- }}}
-- {{{ layout
function layout_update(t)
	lb_layout[t.screen].widget:set_text(getlayouticon(awful.layout.getname(awful.layout.get(t.screen))))
end

for s = 1, screen.count() do
	awful.tag.attached_connect_signal(s, "property::layout", layout_update)
	awful.tag.attached_connect_signal(s, "property::selected", layout_update)
end
-- }}}
-- {{{ mouse enter
client.connect_signal("mouse::enter", function (c)
	if awful.client.focus.filter(c) then
		client.focus = c
	end
end)
-- }}}
-- }}}
