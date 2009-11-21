-- On Screen Keyboard for the awesome window manager
--   * Original by farhaven

-- Grab the environment
local wibox    = require("awful.wibox")
local layout   = require("awful.widget.layout")
local button   = require("awful.button")
local util     = require("awful.util")
local ipairs   = ipairs
local tostring = tostring
local table    = table
local capi     = {
    widget     = widget,
    fake_input = root.fake_input
}


-- On Screen Keyboard for the awesome window manager
module("osk")


local keycodes = {
    q=24,     w=25, e=26, r=27, t=28, z=52, u=30, i=31, o=32, p=33, Ret=36,
    a=38,     s=39, d=40, f=41, g=42, h=43, j=44, k=45, l=46,
    ["<"]=94, y=29, x=53, c=54, v=55, b=56, n=57, m=58, [","]=59, ["."]=60, ["/"]=61,
}

local function create_button_row(...)
    local widgets = { layout = layout.horizontal.flex }

    for k, v in ipairs(arg) do
        local w = capi.widget({ type = "textbox" })
        w:margin({ top = 10, left = 10, right = 10, bottom = 10 })
        w.border_width = 1
        w.border_color = "#1E2320"
        w.bg           = "#4F4F4F"
        w.text_align   = "center"
        w.text = util.escape(tostring(v))
        w:buttons(util.table.join(
            button({ }, 1, nil, function ()
                capi.fake_input("key_press", keycodes[v])
                capi.fake_input("key_release", keycodes[v])
            end)
        ))

        table.insert(widgets, w)
    end

    return widgets
end

local w = wibox({
    height   = 100,
    position = "bottom",
    widgets  = {
        { create_button_row("q", "w", "e", "r", "t", "z", "u", "i", "o", "p", "Ret") },
        { create_button_row("a", "s", "d", "f", "g", "h", "j", "k", "l") },
        { create_button_row("<", "y", "x", "c", "v", "b", "n", "m", ",", ".", "/") },
        layout = layout.vertical.flex
    }
})
