-- On Screen Keyboard for the awesome window manager
--   * Original by farhaven

-- {{{ Grab the environment
local dbg      = require("dbg")
local wibox    = require("awful.wibox")
local layout   = require("awful.widget.layout")
local button   = require("awful.button")
local util     = require("awful.util")
local naughty  = require("naughty")
local ipairs   = ipairs
local tostring = tostring
local table    = table
local pairs    = pairs
local type     = type
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
        { "a", "s", "d", "f", "g", "h", "j", "k", "l" },
        { "y", "x", "c", "v", "b", "n", "m", "p", "⏎" },
    },
    numbers = {
        { "1", "2", "3", "0", ":",  ";", "*", "?", "\"" },
        { "4", "5", "6", "-", "/",  "{", "}", "!", "'" },
        { "7", "8", "9", ".", "\\", "(", ")", "|", "@" }
    },
    control = {
        { "Shift", "Up", "Control" },
        { "Left", "Down", "Right" },
        { "Escape", "Alt" }
    }
}
local active_keymap = "letters"

local keycodes = {
    q=24,     w=25, e=26, r=27, t=28, z=52, u=30, i=31, o=32, p=33, ["⏎"]=36,
    a=38,     s=39, d=40, f=41, g=42, h=43, j=44, k=45, l=46,
    ["<"]=94, y=29, x=53, c=54, v=55, b=56, n=57, m=58, [","]=59, ["."]=60, ["/"]=61,
    ['1']=10, ['2']=11, ['3']=12, ['4']=13, ['5']=14,
    ['6']=15, ['7']=16, ['8']=17, ['9']=18, ['0']=19,
    ['-']=20, [";"]=47, [":"]={ 47, "shift" }, ["*"]={ 17, "shift" }, ["?"] = { 61, "shift" },
    ["\""]={ 48, "shift" }, ["/"]=61, ["{"]={ 34, "shift" }, ["}"] = { 35, "shift" },
    ["!"]={ 10, "shift" }, ["'"]=48, ["\\"]=51, ["("]={ 18, "shift" }, [")"]={ 19, "shift" },
    ["|"]={ 51, "shift" }, ["@"]={ 11, "shift" }, ["Left"]=100, ["Right"]=102,
    ["Up"]=98, ["Down"]=104, ["Shift"]=50, ["Control"]=37, ["Escape"]=9, ["Alt"]=64
}

local pressed_key = ""

local w = { }

local maps = { }
local modifiers = { }
for name, _ in pairs(keymaps) do table.insert(maps, name) end
table.sort(maps)
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
local function fake_key(keysym)
    dbg.stderr("keysym: %d\n", keysym)
    if keysym == "Shift" or keysym == "Control" or keysym == "Alt" then
        table.insert(modifiers, keysym)
        return
    end

    if type(keysym) == "number" then
        for _, m in pairs(modifiers) do
            capi.fake_input("key_press", keycodes[m])
        end
        capi.fake_input("key_press", keysym)
        capi.fake_input("key_release", keysym)
        for _, m in pairs(modifiers) do
            capi.fake_input("key_release", keycodes[m])
        end
        modifiers = { }
        return
    end

    if type(keycodes[keysym]) == "table" then
        if keycodes[keysym][2] == "shift" then
            capi.fake_input("key_press", 50)
        end
        capi.fake_input("key_press", keycodes[keysym][1])
        capi.fake_input("key_release", keycodes[keysym][1])
        if keycodes[keysym][2] == "shift" then
            capi.fake_input("key_release", 50)
        end
    else
        capi.fake_input("key_press", keycodes[keysym])
        capi.fake_input("key_release", keycodes[keysym])
    end
end
-- }}}
-- {{{ local function change_keymap(map)
local function change_keymap()
    local idx
    for i, v in ipairs(maps) do
        if v == active_keymap then
            idx = i
            break
        end
    end
    idx = util.cycle(#maps, idx + 1)
    w[active_keymap].visible = false
    active_keymap = maps[idx]
    w[active_keymap].visible = true
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
    if d.x < -1 then -- "BackSpace"
        fake_key(22)
    elseif d.x > 1 then -- "Space"
        fake_key(65)
    elseif d.y > 1 then -- "Return"
        fake_key(36)
    elseif d.y < -1 then -- Change layout
        change_keymap()
    else
        if not keycodes[keysym] then
            naughty.notify({ text = "No keycode for \"" .. keysym .. "\"" })
        else
            fake_key(keysym)
        end
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
for name, map in pairs(keymaps) do
    w[name] = wibox({
        height   = 160,
        position = "bottom",
        widgets  = { create_keymap(map), layout = layout.horizontal.leftright }
    })
    w[name].visible = false
end
-- }}}
-- {{{ function show
function show()
    w[active_keymap].visible = true
end
-- }}}
-- {{{ function hide
function hide()
    w[active_keymap].visible = false
end
-- }}}
-- {{{ function visible
function visible()
    return w[active_keymap].visible
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
