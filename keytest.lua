local capi = {
    keygrabber = keygrabber
}
local wibox = wibox
local widget = widget
local button = button
local print = print

module("keytest")
local text = ""

function grabber_setup(widget)
    capi.keygrabber.run(function (mod, key)
        print(key)
        if key:len() == 1 then
            text = text .. key
        elseif key == "BackSpace" and text:len() > 0 then
            text = text:sub(1, text:len() - 1)
        end
        widget.text = text
        return true
    end)
end

function run()
    local wb = wibox({ position = "floating" })
    local wi = widget({ type = "textbox", align = "flex" })
    wb.widgets = { wi }
    wb:geometry({ x = 100, y = 100, width = 200, height = 20 })
    wb.screen = 1
    wi.buttons = { button({ }, 1, function () capi.keygrabber.stop() end),
                   button({ }, 3, function () grabber_setup(wi) end)
                 }
    grabber_setup(wi)
end
