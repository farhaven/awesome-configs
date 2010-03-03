local wibox = wibox
local image = image
local button = button
local widget = widget
local screen = screen
local client = client
local awful = require("awful")
local beautiful = require("beautiful")

module("desktop")

icons = { }
icons.width = 80
icons.height = 80 + 32
icons.screen = 1
icons.offset = 32
icons.font = "fixed 16"

apps  = { { icon = '/usr/share/pixmaps/shr-dialer.png', exec = 'phoneui-dialer', name = 'dial' },
          { icon = '/usr/share/pixmaps/shr-messages.png', exec = 'phoneui-messages', name = 'sms' },
          { icon = '/usr/share/pixmaps/mokomaze.png', exec = 'fsoraw -r CPU,Display mokomaze_wrapper.sh', name = 'maze' },
          { icon = '/usr/share/pixmaps/geeqie.png', exec = 'geeqie', name = 'pics' },
          { icon = '/usr/share/pixmaps/FBReader.png', exec = 'FBReader', name = 'books' },
          { icon = '/usr/share/pixmaps/tangogps.png', exec = 'fsoraw -r Display tangogps', name = 'GPS' }
        }

local wb = nil
local waiting = 0
function spawn_notify (cmd)
    awful.util.spawn(cmd)
    waiting = waiting + 1
    wb.visible = true
end

client.add_signal("manage", function (c)
    if waiting == 0 then return end
    waiting = waiting - 1
    if waiting == 0 then
        wb.visible = false
    end
end)

function setup()
    wb = wibox({ bg = beautiful.bg_normal, fg = beautiful.fg_normal })
    wb.visible = false
    wb.ontop = true
    wb.border_color = beautiful.fg_normal
    wb.border_width = beautiful.border_width
    wb.screen = icons.screen
    wb:geometry({
        width = screen[icons.screen].workarea.width / 2,
        height = 38,
        x = screen[icons.screen].workarea.width / 4,
        y = (screen[icons.screen].workarea.height / 2) - 19
    })
    w = widget({ type = "textbox" })
    w.text = 'starting...'
    wb.widgets = {
        w,
        layout = awful.widget.layout.horizontal.center
    }

    icons.x = screen[icons.screen].workarea.x + icons.offset
    icons.y = screen[icons.screen].workarea.y + icons.offset
    for i = 1, #apps do
        icons[i] = { }
        icons[i].wibox = wibox({ bg = "#11111180" })
        icons[i].wibox.screen = 1
        icons[i].wibox:geometry({ x = icons.x, y = icons.y, width = icons.width, height = icons.height })
        icons[i].wibox:buttons(awful.util.table.join(
            awful.button({ }, 1, function () spawn_notify(apps[i].exec) end)
        ))

        icons[i].img = widget({ type = "imagebox" })
        icons[i].img.image = image(apps[i].icon)
        icons[i].img.resize = true

        icons[i].txt = widget({ type = "textbox" })
        icons[i].txt.text = '<span color="#888888" font_desc="' .. icons.font .. '">' .. apps[i].name .. '</span>'

        icons[i].wibox.widgets = {
            icons[i].img,
            {
                icons[i].txt,
                layout = awful.widget.layout.horizontal.center
            },
            layout = awful.widget.layout.vertical.topdown
        }

        if icons.y + icons.height + icons.offset > screen[icons.screen].workarea.height - screen[icons.screen].workarea.y then
            icons.y = screen[icons.screen].workarea.y + icons.offset
            icons.x = icons.x + icons.width + icons.offset
        else
            icons.y = icons.y + icons.height + icons.offset
        end
    end
end
