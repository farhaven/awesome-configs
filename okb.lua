local ipairs   = ipairs
local tostring = tostring
local print    = print

local table    = table
local io       = io
local string   = string

local capi   = {
    widget     = widget,
    fake_input = root.fake_input
}
local wibox  = require("awful.wibox")
local layout = require("awful.widget.layout")
local button = require("awful.button")
local util   = require("awful.util")

local dbg    = require("dbg")
-- on screen keyboard for Awesome 3.3 + Widget layouts
module("okb")

local function stderr(...)
    io.stderr:write(string.format(...))
    io.stderr:flush()
end

local keycodes = {
    q = 24, a = 38, ["<"] = 94,
    w = 25, s = 39,     y = 52, 
    e = 26, d = 40,     x = 53,
    r = 27, f = 41,     c = 54,
    t = 28, g = 42,     v = 55,
    z = 29, h = 43,     b = 56,
    u = 30, j = 44,     n = 57,
    i = 31, k = 45,     m = 58,
    o = 32, l = 46, [","] = 59,
    p = 33,         ["."] = 60,
}

local function create_button_row(...)
    local widgets = {
        layout = layout.horizontal.flex
    }

    for k, v in ipairs(arg) do
        local w = capi.widget({ type = "textbox" })
        w:margin({ top = 10, left = 10, right = 10, bottom = 10 })
        w.border_width = 1
        w.border_color = "#000000"
        w.text_align = "center"
        w.text = util.escape(tostring(v))
        w:buttons(util.table.join(button({ }, 1, nil, function () capi.fake_input("key_press", keycodes[v]); capi.fake_input("key_release", keycodes[v]); dbg.stderr("%s -> %s\n", v, keycodes[v]) end)))
        table.insert(widgets, w)
    end

    return widgets
end

local w = wibox({ position = "bottom", height = 100 })
w.widgets = {
    {
        create_button_row("q", "w", "e", "r", "t", "z", "u", "i", "o", "p"),
    },
    {
        create_button_row("a", "s", "d", "f", "g", "h", "j", "k", "l"),
    },
    {
        create_button_row("<", "y", "x", "c", "v", "b", "n", "m", ",", "."),
    },
    layout = layout.vertical.topdown
}
