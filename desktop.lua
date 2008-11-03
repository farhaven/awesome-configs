local wibox = wibox
local image = image
local button = button
local widget = widget
local awful = require("awful")

module("desktop")

icons = { }
icons.x = 1440 + 16
icons.y = 32
icons.n = 10

apps  = { { icon = '/usr/share/pixmaps/firefox-icon.png', exec = 'firefox' },
          { icon = '/usr/share/pixmaps/gftp.png', exec = 'gftp' } }

function icons.setup()
    for i = 1, #apps do
        icons[i] = { }
        icons[i].wibox = wibox({ position = "floating", ontop = false, bg = "#12345600" })
        icons[i].wibox:geometry({ x = icons.x,
                                  y = icons.y,
                                  height = 32,
                                  width = 32 })
        icons[i].icon = image(apps[i].icon or nil)
        icons[i].widget = widget({ type = "imagebox", name = "desktop_icon_"..i, align = "flex" })
        icons[i].widget.image = icons[i].icon
        icons[i].widget:buttons({ button({ }, 1, function () awful.util.spawn(apps[i].exec or "") end) })
        icons[i].wibox.widgets = { icons[i].widget }
        icons[i].wibox.screen = 1
        if (i % 10) == 0 then
            icons.x = icons.x + 32 + 16
            icons.y = 32
        else
            icons.y = icons.y + 32 + 16
        end
    end
end
