local width = 32
local height = 16
local xcells = 32
local ycells = 16
local timer = 0.5
local bg = beautiful.get().bg_normal
local fg = beautiful.get().fg_focus
local bwidth = math.floor(width / xcells)
local bheight = math.floor(height / ycells)

local wb = wibox({ position = "floating" })
local ib = widget({ type = "imagebox" })
local img = image(nil, width, height)

local field = { }

function init()
    for x = 0, xcells do
        field[x] = { }
        for y = 0, ycells do
            if math.random(10) > 8 then
                field[x][y] = true
            end
        end
    end
end

function neighbors(x, y)
    local n = 0
    if field[x > 0 and x-1 or xcells][y > 0 and y-1 or ycells] then n = n + 1 end
    if field[x > 0 and x-1 or xcells][y  ] then n = n + 1 end
    if field[x > 0 and x-1 or xcells][y < ycells and y+1 or 0] then n = n + 1 end
    
    if field[x ][y > 0 and y-1 or ycells] then n = n + 1 end
    if field[x ][y < ycells and y+1 or 0] then n = n + 1 end

    if field[x < xcells and x+1 or 0][y > 0 and y-1 or ycells] then n = n + 1 end
    if field[x < xcells and x+1 or 0][y  ] then n = n + 1 end
    if field[x < xcells and x+1 or 0][y < ycells and y+1 or 0] then n = n + 1 end

    return n
end

function step()
    local nfield = { }
    local ncells = 0
    for x = 0, xcells do
        nfield[x] = { }
        for y = 0, ycells do
            local n = neighbors(x, y)
            if not field[x][y] and n == 3 then
                nfield[x][y] = true
            elseif field[x][y] then
                if n == 2 or n == 3 then
                    nfield[x][y] = true
                end
            end
            local color = bg
            if nfield[x][y] then
                ncells = ncells + 1
                color = fg
            end
            img:draw_rectangle(x * bwidth, y * bheight, bwidth, bheight, true, color)
        end
    end
    ib.image = img
    field = nfield
    if ncells <= 10 then
        init()
    end
end

function erase()
    ib = nil
    wb.screen = nil
    wb = nil
    img = nil
    awful.hooks.timer.unregister(step)
end

wb.ontop = true
wb:buttons({ button({ }, 1, awful.mouse.wibox.move),
             button({ }, 3, erase)
           })
wb.widgets = { ib, ["layout"] = awful.widget.layout.horizontal.leftright }
wb.screen = mouse.screen 
wb:geometry({ width = width, height = height })

img:draw_rectangle(0,0,width,height,true,bg)
ib.image = img

init()
step()
awful.hooks.timer.register(timer, step)
