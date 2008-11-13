-- {{{ env
local screen = screen
local awful = require("awful")
local table = table
local tag = tag
local mouse = mouse

module("tagger")

apptags = { }
config = {
    { name = "Main" }
}
-- }}}
-- {{{ add(scr, name, layout, mwfact, nmaster)
function add(scr, name, layout, mwfact, nmaster)
    local tags = screen[scr]:tags()
    local index = #tags
    if index >= #config then
        if not name then name = "unnamed" end
        if not layout then layout = "tile" end
    else
        if not name then name = config[index + 1].name end
        if not layout then layout = config[index + 1].layout end
        if not mwfact then mwfact = config[index + 1].mwfact end
        if not nmaster then nmaster = config[index + 1].nmaster end
    end
    local t = tag({ name = name, layout = layout, mwfact = mwfact, nmaster = nmaster })
    t.screen = scr
    table.insert(tags, t)
    awful.hooks.user.call("arrange", scr)
end
-- }}}
-- {{{ remove(scr, idx)
function remove(scr, idx)
    if not scr then scr = mouse.scr end
    local tags = screen[scr]:tags()
    if #tags <= 1 then return end
    local tag
    if not idx then tag = awful.tag.selected(scr)
    else tag = tags[idx] end

    if #(tag:clients()) > 0 then return end
    for i = 1, #tags do
        if tag == tags[i] then
            if tag == awful.tag.selected(scr) then
                if i == #tags then
                    awful.tag.viewidx(-1, scr)
                else
                    awful.tag.viewidx(1, scr)
                end
            end
            tags[i].screen = nil
            table.remove(tags, i)
            screen[scr]:tags(tags)
            awful.hooks.user.call("tags", scr)
            awful.hooks.user.call("arrange", scr)
            break
        end
    end
end
-- }}}
-- {{{ clean(scr)
function clean(scr)
    local tags = screen[scr]:tags()
    for i = #tags, 1, -1 do
        remove(scr, i)
    end
end
-- }}}
-- {{{ rename(scr, name)
function rename(scr, name)
    if not scr then scr = mouse.scr end
    local t = awful.tag.selected(scr)
    if name then
        t.name = name
    else
        t.name = t.name .. "_"
        keygrabber.run(
        function (mod, key)
            if key:len() == 1 and t.name:len() <= 20 then
                t.name = t.name:sub(1, t.name:len() - 1) .. key .. "_"
            elseif key == "BackSpace" and t.name:len() > 1 then
                t.name = t.name:sub(1, t.name:len() - 2) .. "_"
            elseif key == "Return" then
                if t.name:len() > 1 then
                    t.name = t.name:sub(1, t.name:len() - 1)
                    return false
                end
            end
            return true
        end)
    end
    awful.hooks.user.call("tags", scr)
end
-- }}}
-- {{{ name2index(scr, name)
function name2index(scr, name)
    local tags = screen[scr]:tags()
    for i = 1, #tags do
        if tags[i].name == name then
            return i
        end
    end
    return 0
end
-- }}}
-- {{{ tag2index(scr, tag)
function tag2index(scr, tag)
    local tags = screen[scr]:tags()
    for i = 1, #tags do
        if tags[i] == tag then
            return i
        end
    end
    return 0
end
-- }}}
-- {{{ moveto(idx, c)
function moveto(idx, c)
    if not c then c = client.focus end
    if not c then return end
    local tags = screen[c.screen]:tags()
    awful.client.movetotag(tags[idx])
end
-- }}}
-- {{{ movetorel(idx, c)
function movetorel(idx, c)
    if not c then c = client.focus end
    if not c then return end
    local tags = screen[c.screen]:tags()
    awful.client.movetotag(tags[awful.util.cycle(#tags, tag2index(c.screen, awful.tag.selected(c.screen)) + idx)])
end
-- }}}
-- {{{ move(idx, scr)
function move(idx, scr)
    if not s then scr = mouse.screen end
    local t1 = awful.tag.selected(scr)
    local i1 = tags.tag2index(scr, t1)
    local i2 = awful.util.cycle(#(tags[scr]), (i1 + idx))
    local tags = screen[scr]:tags()

    tags[scr][i1] = tags[scr][i2]
    tags[scr][i2] = t1

    screen[scr]:tags(tags[scr])
    awful.hooks.user.call("tags", scr)
end
-- }}}
-- {{{ movescreen(scr_target)
function movescreen(scr_target)
    local scr_source = mouse.screen
    if #(screen[scr_source]:tags()) <= 1 then return end
    local t = awful.tag.selected(scr_source)
    -- first, move all clients on the tag to the target screen and set the tag as their only tag
    local clients = t:clients()
    for i = 1, #clients do
        clients[i].screen = scr_target
        clients[i]:tags({ t })
    end
    t:clients(clients)

    -- then, remove the tag from the source screens taglist
    local index = tag2index(scr_source, t)
    remove(scr_source, index)

    -- insert the tag into target screens tag list
    t.screen = scr_target
    local tags = screen[scr_target]:tags()
    table.insert(tags, t)

    awful.hooks.user.call("arrange", scr_target)
end
-- }}}
-- {{{ movescreenrel(idx)
function movescreenrel(idx)
    local index = awful.util.cycle(screen.count(), mouse.screen + idx)
    movescreen(index)
end
-- }}}
-- {{{ apptag(name)
function apptag(name, scr)
    if not scr then scr = mouse.screen end
    local idx = name2index(scr, name)

    if idx ~= 0 then
        local tags = screen[scr]:tags()
        return tags[idx]
    end

    local created = false

    for i = 1, #config do
        if config[i].name == name then
            add(scr, config[i].name, config[i].layout, config[i].mwfact, config[i].nmaster)
            created = true
            break
        end
    end
    if not created then add(scr, name) end

    local tags = screen[scr]:tags()
    return tags[#tags]
end
-- }}}
