-- {{{ env
local math = math
local print = print
local wibox = wibox
local widget = widget
local image = image
local cairo = require("oocairo")
local capi = {
    keygrabber = keygrabber
}

module("raytrace")
-- }}}

-- {{{ helper functions
-- {{{ round
function round(x)
    if x - math.floor(x) > 0.5 then
        return math.ceil(x)
    else
        return math.floor(x)
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
-- {{{ pixel
function pixel(c, p, color)
    c:new_sub_path()
    c:rectangle(p[1], p[2], 2, 2)
    c:close_path()
    c:set_source_rgb(color[1], color[2], color[3])
    c:fill()
end
-- }}}
-- }}}

-- {{{ set up level
local level = { }
for i = 1, (100 * 100) do
    level[i] = 0
end
function level_xy(x, y, v)
    local index = y * 100 + x
    if not v then
        return level[index]
    end
    level[index] = v
end
level_xy(50, 30, 1)
level_xy(60, 40, 1)
level_xy(60, 60, 1)
-- }}}

-- {{{ set up player
local player = {50, 50, 200}
function trace(x, y, dir, dist)
    if not dist then dist = 0 end

    if (x <= 0) or (y <= 0) then
        return 0
    end
    if (x >= 100) or (y >= 100) then
        return 0
    end

    local r = level_xy(x, y)
    if r > 0 then
        return dist
    end
    
    local xx, yy
    xx = round(math.sin(math.rad(dir))) + x
    yy = round(math.cos(math.rad(dir))) + y
    return trace(xx, yy, dir, dist + 1)
end
-- }}}

-- {{{ set up content
local wb = wibox({ position = "floating" })
wb:geometry({ x = 100,
              y = 100,
              width = 100,
              height = 100
            })
wb.screen = 1
local wi = widget({ type = "imagebox" })
wb.widgets = { wi }

cs = cairo.image_surface_create("argb32", 100, 100)
cr = cairo.context_create(cs)
-- {{{ clear
function clear(c)
    c:new_sub_path()
    c:rectangle(0, 0, 100, 100)
    c:close_path()
    c:set_source_rgb(0.2, 0.2, 0.2)
    c:fill()
end
-- }}}
clear(cr)
-- }}}

-- {{{ trace
function update()
    clear(cr)
    for i = 1, 100, 0.5 do
        local dir = (player[3] + i - 50) % 360

        local value = trace(player[1], player[2], dir)
        if value  > 0 then
            local r = round((100 - value) / 2)
            local y1 = r
            local y2 = 100 - r
            line(cr, {i, y1},{i, y2},{1, 1, 1}, 1)
        end
    end
    wi.image = image.argb32(100, 100, cs:get_data())
end
update()
-- }}}

-- {{{ keygrabber
capi.keygrabber.run(function (mod, key)
    if key == "q" then
        return false
    elseif key == "Up" then
        local dir = (player[3] + 180) % 360
        player[1] = round(math.sin(dir * 0.01745)) + player[1]
        player[2] = round(math.cos(dir * 0.01745)) + player[2]
    elseif key == "Down" then
        local dir = player[3]
        player[1] = round(math.sin(dir * 0.01745)) + player[1]
        player[2] = round(math.cos(dir * 0.01745)) + player[2]
    elseif key == "Left" then
        player[3] = (player[3] - 10) % 360
    elseif key == "Right" then
        player[3] = (player[3] + 10) % 360
    end
    update()
    return true
end)
-- }}}
