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
    props = props or { }
    props.name = props.name or name
    local idx = name2idx(name, screen)
    if not idx then
        return add(screen, props)
    end
    return capi.screen[screen]:tags()[idx]
end
-- }}}
function add(scr, props) -- {{{
    scr = scr or capi.mouse.screen
    props = props or { }
    local name = props.name or '.oO'

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
    awful.tag.setproperty(t, "ncol", props.ncol)
    awful.tag.setproperty(t, "icon", props.icon)

    if #(capi.screen[scr]:tags()) == 1 or props.switch then
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

    local ct = awful.tag.selected()
    ct.selected = false
    ct.selected = true

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
local function move(t, idx) -- {{{
    local tags = capi.screen[t.screen]:tags()
    local idx_old = tag2idx(t)
    local c = capi.client.focus
    if not idx_old then return end

    table.remove(tags, idx_old)
    table.insert(tags, idx, t)

    capi.screen[t.screen]:tags(tags)
    update_names(t.screen)
    capi.client.focus = c
end
-- }}}
local function moverel(t, off) -- {{{
    local idx = tag2idx(t)
    if not idx then return end
    local idx_max = #(capi.screen[t.screen]:tags())
    local idx_new = awful.util.cycle(idx_max, idx + off)
    move(t, idx_new)
end
-- }}}
function moveleft(t) -- {{{
    t = t or awful.tag.selected(capi.mouse.screen)
    moverel(t, -1)
end
-- }}}
function moveright(t) -- {{{
    t = t or awful.tag.selected(capi.mouse.screen)
    moverel(t, 1)
end
-- }}}
local function movescreen(t, scr) -- {{{
    if t.screen == scr or #(capi.screen[t.screen]:tags()) == 1 then return end
    if t.selected then
        awful.tag.viewnext(capi.screen[t.screen])
    end
    local clients = t:clients()
    local oldscr = t.screen
    local idx = tag2idx(awful.tag.selected(scr))
    t.screen = scr
    for i, v in pairs(clients) do
        v.screen = scr
        v:tags({ t })
    end
    local tags = capi.screen[scr]:tags()
    local c = capi.client.focus
    table.remove(tags)
    table.insert(tags, idx, t)
    capi.screen[scr]:tags(tags)
    update_names(scr)
    update_names(oldscr)
    capi.client.focus = c
    if not capi.client.focus or not capi.client.focus.visible then
        capi.client.focus = awful.tag.selected(scr):clients()[1]
    end
    capi.mouse.screen = scr
    awful.tag.viewonly(t)
end
-- }}}
local function movescreenrel(t, off) -- {{{
    local idx = t.screen
    local idx_max = capi.screen.count()
    local idx_new = awful.util.cycle(idx_max, idx + off)
    movescreen(t, idx_new)
end
-- }}}
function movescreenleft(t) -- {{{
    t = t or awful.tag.selected(capi.mouse.screen)
    movescreenrel(t, -1)
end
-- }}}
function movescreenright(t) -- {{{
    t = t or awful.tag.selected(capi.mouse.screen)
    movescreenrel(t, 1)
end
-- }}}
