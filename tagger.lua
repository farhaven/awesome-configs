-- Environment
local awful = require('awful')
local capi = {
    tag = tag,
    mouse = mouse,
    screen = screen,
    keygrabber = keygrabber,
    client = client
}
local ipairs = ipairs
local pairs = pairs
local table = table

module('tagger')

function tag2idx(tag) -- {{{
    if not tag then return nil end
    local tags = capi.screen[tag.screen]:tags()

    for i, t in ipairs(tags) do
        if t == tag then
            return i
        end
    end

    return nil
end
-- }}}
function name2idx(name, screen) -- {{{
    screen = screen or capi.mouse.screen
    local tags = capi.screen[screen]:tags()
    for i, v in ipairs(tags) do
        if v.name == name or v.name:match("^%d+:" .. name .. "$") then
            return i
        end
    end
    return nil
end
-- }}}
function apptag(name, props, client) -- {{{
    local screen = client and client.screen or capi.mouse.screen
    local idx = name2idx(name, screen)
    if not idx then
        return add(screen, name, props)
    end
    return capi.screen[screen]:tags()[idx]
end
-- }}}
function add(scr, name, props) -- {{{
    local switchthere = false
    if not scr then
        switchthere = true
    end
    scr = scr or capi.mouse.screen
    name = name or 'default'
    props = props or { }

    local tags = capi.screen[scr]:tags()
    local t = capi.tag({ name = name })
    local idx = tag2idx(awful.tag.selected())
    idx = idx or 0
    table.insert(tags, idx + 1, t)
    t.screen = scr
    capi.screen[scr]:tags(tags)

    awful.tag.setproperty(t, "layout", props.layout or awful.layout.suit.tile)
    awful.tag.setproperty(t, "mwfact", props.mwfact)
    awful.tag.setproperty(t, "nmaster", props.nmaster)
    awful.tag.setproperty(t, "ncols", props.ncols)
    awful.tag.setproperty(t, "icon", props.icon)

    if #(capi.screen[scr]:tags()) == 1 or switchthere then
        awful.tag.viewonly(t)
    end

    update_names(scr)
    return t
end
-- }}}
function clean(scr) -- {{{
    local tags = capi.screen[scr]:tags()
    local t2 = { }
    for i, v in pairs(tags) do
        if #(v:clients()) ~= 0 then
            table.insert(t2, v)
        else
            if v.selected then
                awful.tag.viewprev(capi.screen[v.screen])
            end
        end
    end
    if #t2 == 0 then
        table.insert(t2, tags[1])
    end
    capi.screen[scr]:tags(t2)
end
-- }}}
function remove(scr, idx) -- {{{
    scr = scr or capi.mouse.screen
    idx = idx or tag2idx(awful.tag.selected(scr))
    if not idx then return end

    local t = capi.screen[scr]:tags()
    if idx > #t or #t == 1 then return end
    if #(t[idx]:clients()) ~= 0 then return end
    if t[idx].selected then awful.tag.viewnext() end
    table.remove(t, idx)
    capi.screen[scr]:tags(t)

    update_names(scr)
end
-- }}}
function update_names(scr) -- {{{
    local t = capi.screen[scr]:tags()
    for i, v in ipairs(t) do
        if not v.name:match("^%d+:") then
            v.name = i .. ":" .. v.name
        else
            v.name = v.name:gsub("^(%d+):", i..":")
        end
    end
end
-- }}}
function rename(t) -- {{{
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
            update_names(t.screen)
            return false
        elseif key == "Escape" then
            t.name = name
            return false
        end
        return true
    end)
end
-- }}}
