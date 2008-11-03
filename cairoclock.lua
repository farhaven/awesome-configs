-- {{{ environment
local cairo     = require("oocairo")
local awful     = require("awful")
local beautiful = require("awful.beautiful")
local math      = math
local image     = image
local wibox     = wibox
local widget    = widget
local os        = os
local tonumber  = tonumber

module("cairoclock")
-- }}}
-- {{{ locals
local w         = 40
local h         = 40
local center    = { math.floor(w/2), math.floor(h/2) }
local PI        = 2 * math.asin(1)
local time      = nil
local cs        = nil
local cr        = nil
-- }}}
-- {{{ hexcolor_decimal
function hexcolor_decimal (hexcolor)
    local red = hexcolor:sub(2, 3)
    local green = hexcolor:sub(4, 5)
    local blue = hexcolor:sub(6, 7)
    local alpha = hexcolor:sub(8, 9)

    local hexdata = { ['a'] = 10, ['b'] = 11, ['c'] = 12, ['d'] = 13, ['e'] = 14, ['f'] = 15 }

    function hextodec (hex)
        local decimal
        local s = hex:sub(1, 1)
        if not tonumber(s) then
            decimal = hexdata[s:lower()]
        else
            decimal = tonumber(s)
        end
        s = hex:sub(2, 2)
        decimal = decimal * 16
        if not tonumber(s) then
            decimal = decimal + hexdata[s:lower()]
        else
            decimal = decimal + tonumber(s)
        end

        return decimal
    end

    local dcolor = { }
    dcolor[1] = hextodec(red) / 255
    dcolor[2] = hextodec(green) / 255
    dcolor[3] = hextodec(blue) / 255
    if alpha and alpha ~= "" then
        dcolor[4] = hextodec(alpha) / 255
    end
    return dcolor
end
-- }}}
-- {{{ circle
--- Draw a circle
-- \@param c the drawing context
-- \@param p a table containing the center point of the circle
-- \@param r the circle's radius
-- \@param color table containing the color to draw
-- \@param w the linewidth, leave nil for filled circle
function circle (c, p, r, color, w)
    c:new_sub_path()
    c:arc(p[1], p[2], r, 0, 2 * PI)
    c:close_path()
    c:set_source_rgb(color[1], color[2], color[3])
    if w then
        c:set_line_width(w)
        c:stroke()
    else
        c:fill()
    end
end
-- }}}
-- {{{ line
--- Draw a line
-- \@param c the drawing context
-- \@param from a table for the starting point
-- \@param to see above for the ending point
-- \@param color table containing
-- \@param w the line width
function line (c, f, t, color, w)
    c:new_sub_path()
    c:move_to(f[1], f[2])
    c:line_to(t[1], t[2])
    c:set_source_rgb(color[1], color[2], color[3])
    c:set_line_width(w)
    c:stroke()
end
-- }}}
-- {{{ update time
function update_time (box)
    time = os.date("%I:%M:%S")
    local second = tonumber(time:match(".*(%d%d)$"))
    local minute = tonumber(time:match(".*:(%d%d):.*"))
    local hour   = tonumber(time:match("^(%d%d).*"))
    local angle
    local x
    local y
    -- {{{ clear drawing context
    cb = beautiful.get().bg_normal or "#303030"
    cb = hexcolor_decimal(cb)

    cr:new_sub_path()
    cr:move_to(0, 0)
    cr:line_to(w, 0)
    cr:line_to(w, h)
    cr:line_to(0, h)
    cr:close_path()
    cr:set_source_rgb(cb[1], cb[2], cb[3])
    cr:fill()
    -- }}}
    circle(cr, center, math.floor(math.min(w, h) / 2) - 2, { 0, 0, 0 }, 2)
    -- {{{ hour handle
    angle = ((12 - hour) * 30 + 180) * 0.01745
    x = math.floor(math.sin(angle) * ((math.min(w, h) / 2) - 2))
    y = math.floor(math.cos(angle) * ((math.min(w, h) / 2) - 2))
    line(cr, center, { center[1] + x, center[2] + y }, { 0, 0, 1 }, 2)
    -- }}}
    -- {{{ minute handle
    angle = ((60 - minute) * 6 + 180) * 0.01745
    x = math.floor(math.sin(angle) * ((math.min(w, h) / 2) - 3))
    y = math.floor(math.cos(angle) * ((math.min(w, h) / 2) - 3))
    line(cr, center, { center[1] + x, center[2] + y }, { 0, 1, 0 }, 2)
    -- }}}
    -- {{{ seconds handle
    angle = ((60 - second) * 6 + 180) * 0.01745
    x = math.floor(math.sin(angle) * ((math.min(w, h) / 2) - 4))
    y = math.floor(math.cos(angle) * ((math.min(w, h) / 2) - 4))
    line(cr, center, { center[1] + x, center[2] + y }, { 1, 0, 0 }, 2)
    -- }}}
    box.image = image.argb32(w,h,cs:get_data())
end
-- }}}
-- {{{ start
function start(box)
    cs = cairo.image_surface_create("argb32", w, h)
    cr = cairo.context_create(cs)
    
    cb = beautiful.get().bg_normal or "#303030"
    cb = hexcolor_decimal(cb)
    cr:set_source_rgb(cb[1], cb[2], cb[3])
    cr:paint()

    awful.hooks.timer.register(1, function () update_time(box) end)
    update_time(box)
end
-- }}}
