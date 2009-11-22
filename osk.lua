-- On Screen Keyboard for the awesome window manager
--   * Original by farhaven

-- {{{ Grab the environment
local dbg      = require("dbg")
local wibox    = require("awful.wibox")
local layout   = require("awful.widget.layout")
local button   = require("awful.button")
local util     = require("awful.util")
local ipairs   = ipairs
local tostring = tostring
local table    = table
local unpack   = unpack
local math     = {
    abs        = math.abs
}
local capi     = {
    widget     = widget,
    fake_input = root.fake_input
}
-- }}}

-- On Screen Keyboard for the awesome window manager
module("osk")

-- {{{ settings
local font = "Fixed 16"

local keymaps = {
    letters = {
        { "q", "w", "e", "r", "t", "z", "u", "i", "o" },
        { "a", "s", "d", "f", "g", "h", "j", "l", "p" },
        { "y", "x", "c", "v", "b", "n", "m", "k", "⏎" },
    }
}
local active_keymap = "letters"

local keycodes = {
    q=24,     w=25, e=26, r=27, t=28, z=52, u=30, i=31, o=32, p=33, ["⏎"]=36,
    a=38,     s=39, d=40, f=41, g=42, h=43, j=44, k=45, l=46,
    ["<"]=94, y=29, x=53, c=54, v=55, b=56, n=57, m=58, [","]=59, ["."]=60, ["/"]=61,
}
local pressed_key = ""
-- }}}
-- {{{ local function distance(k1, k2, map)
local function distance(k1, k2, map)
    local p1 = { }
    local p2 = { }
    if k1 == k2 then return { x = 0, y = 0 } end
    for y, row in ipairs(map) do
        for x, sym in ipairs(row) do
            if k1 == sym then
                p1 = { x = x, y = y }
            end
            if k2 == sym then
                p2 = { x = x, y = y }
            end
            if p1.x and p2.x then break end
        end
        if p1.y and p2.y then break end
    end
    return { x = p1.x - p2.x, y = p1.y - p2.y }
end
-- }}}
-- {{{ local function fake_key(keycode)
local function fake_key(keycode)
    capi.fake_input("key_press", keycode)
    capi.fake_input("key_release", keycode)
end
-- }}}
-- {{{ local function keypress(keysym)
local function keypress(keysym)
    pressed_key = keysym
end
-- }}}
-- {{{ local function keyrelease(keysym)
local function keyrelease(keysym)
    local d = distance(keysym, pressed_key, keymaps[active_keymap])
    dbg.dump(d)
    if d.x < -1 then -- "BackSpace"
        fake_key(22)
    elseif d.x > 1 then -- "Space"
        fake_key(65)
    elseif d.y > 1 then -- "Return"
        fake_key(36)
    else
        fake_key(keycodes[keysym])
    end
    pressed_key = ""
end
-- }}}
-- {{{ local function create_button_row(keys)
local function create_button_row(keys)
    local widgets = { layout = layout.horizontal.flex }

    for k, v in ipairs(keys) do
        local w = capi.widget({ type = "textbox" })
        w:margin({ top = 10, left = 10, right = 10, bottom = 10 })
        w.border_width = 2
        w.border_color = "#1E2320"
        w.bg           = "#4F4F4F"
        w.text_align   = "center"
        w.text = "<span font_desc=\"" .. font .. "\">" .. util.escape(tostring(v)) .. "</span>"
        w:buttons(util.table.join(
            button({ }, 1,
                function () keypress(v) end,
                function () keyrelease(v) end)
        ))

        table.insert(widgets, w)
    end

    return widgets
end
-- }}}
-- {{{ local function create_keymap(map)
local function create_keymap(map)
    local w = { layout = layout.vertical.flex }
    for _, row in ipairs(map) do
        table.insert(w, create_button_row(row))
    end
    return w
end
-- }}}
-- {{{ initial wibox setup
local w = wibox({
    height   = 160,
    position = "bottom",
    widgets  = { create_keymap(keymaps[active_keymap]), layout = layout.horizontal.leftright }
})
w.visible = false
-- }}}
-- {{{ function show
function show()
    w.visible = true
end
-- }}}
-- {{{ function hide
function hide()
    w.visible = false
end
-- }}}
-- {{{ function visible
function visible()
    return w.visible
end
-- }}}
-- {{{ function widget
function widget()
    local w_toggle = capi.widget({ type = "textbox" })
    w_toggle.text = "<span color=\"#FF0000\">⌨</span>"
    w_toggle:margin({ left = 20, right = 20 })
    w_toggle:buttons(util.table.join(
        button({ }, 1, function ()
            if visible() then
                hide()
                w_toggle.text = "<span color=\"#FF0000\">⌨</span>"
            else
                show()
                w_toggle.text = "<span color=\"#00FF00\">⌨</span>"
            end
        end)
    ))
    return w_toggle
end
-- }}}
