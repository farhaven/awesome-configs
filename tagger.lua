local awful = require('awful')
local capi = {
    tag = tag,
    mouse = mouse,
    screen = screen,
    keygrabber = keygrabber,
    client = client
}
local ipairs = ipairs
local table = table


local dbg = require('dbg')

module('tagger')

function tag2idx(tag)
    if not tag then return nil end
    local tags = capi.screen[tag.screen]:tags()

    for i, t in ipairs(tags) do
        if t == tag then
            return i
        end
    end

    return nil
end

function name2idx(name, screen)
    screen = screen or capi.mouse.screen
    local tags = capi.screen[screen]:tags()
    for i, v in ipairs(tags) do
        if v.name == name then
            return i
        end
    end
    return nil
end

function apptag(name, props, client)
    local screen = client and client.screen or capi.mouse.screen
    local idx = name2idx(name, screen)
    if not idx then
        return add(screen, name, props)
    end
    return capi.screen[screen]:tags()[idx]
end

function add(scr, name, props)
    scr = scr or capi.mouse.screen
    name = name or '(none)'
    props = props or { }

    local t = capi.tag({ name = name })
    t.screen = scr

    awful.tag.setproperty(t, "layout", props.layout or awful.layout.suit.tile)
    awful.tag.setproperty(t, "mwfact", props.mwfact)
    awful.tag.setproperty(t, "nmaster", props.nmaster)
    awful.tag.setproperty(t, "ncols", props.ncols)
    awful.tag.setproperty(t, "icon", props.icon)

    if #(capi.screen[scr]:tags()) == 1 then
        t.selected = true
    end

    return t
end

function remove(scr, idx)
    scr = scr or capi.mouse.screen
    idx = idx or tag2idx(awful.tag.selected(scr))
    if not idx then return end

    local t = capi.screen[scr]:tags()
    if idx > #t then return end
    if #(t[idx]:clients()) ~= 0 then return end
    if t[idx].selected then awful.tag.viewnext() end
    local t2 = { }
    for i, tag in ipairs(t) do
        if idx ~= i then
            table.insert(t2, tag)
        end
    end
    capi.screen[scr]:tags(t2)
end

function rename(t)
    t = t or awful.tag.selected(capi.mouse.screen)

    local name = t.name
    t.name = t.name .. '_'
    capi.keygrabber.run(function(mod, key, action)
        if action ~= "press" then return true end
        if key:len() == 1 and t.name:len() <= 20 then
            t.name = t.name:sub(1, t.name:len() - 1) .. key .. '_'
        elseif key == "BackSpace" and t.name:len() > 1 then
            t.name = t.name:sub(1, t.name:len() - 2) .. '_'
        elseif key == "Return" and t.name:len() > 1 then
            t.name = t.name:sub(1, t.name:len() - 1)
            return false
        elseif key == "Escape" then
            t.name = name
            return false
        end
        return true
    end)
end

capi.client.add_signal("unmanage", function (c)
    local t = c:tags()
    for i, v in ipairs(t) do
        remove(c.screen, tag2idx(v))
    end
end)
