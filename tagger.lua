-- {{{ instructions
--[[    Add a line like
        require('tagger')
        to the top of your rc.lua.

        Then, set the list of your preferred tags like this:
        tagger.config = {
            { name = "Main", layout = layouts[5] },
            { name = "Term", layout = layouts[4] },
            { name = "WWW",  layout = layouts[3], mwfact = 0.7, nmaster = 1 },
            { name = "Misc", layout = layouts[4] },
            { name = "Text", layout = layouts[4] },
            { name = "Chat", layout = layouts[1], mwfact = 0.7, nmaster = 1 },
            { name = "Mail", layout = layouts[3] },
            { name = "Float",layout = layouts[6] }
        }

        Set the tags for your applications like this:
        tagger.apptags =
        {   ["urxvt.weechat"]   = "Chat",
            ["urxvt.cmus"]      = "Music",
            ["claws-mail"]      = "Mail",
            ["urxvt"]           = "Term",
            ["firefox"]         = "WWW",
            ["gvim"]            = "Text",
            ["xpdf"]            = "Misc",
            ["wicd-client.py"]  = "Wicd"
        }
        As you can see, not all application tags need to be defined in tagger.config.
        If a tag has no config, a standard tag with "tile" as it's layout and the name
        you set in tagger.apptags is used.

        You should change the section of your manage hook which moves clients to their
        application tags to look like this:

        local target
        if tagger.apptags[inst] then
            target = tagger.apptags[inst]
        elseif tagger.apptags[cls] then
            target = tagger.apptags[cls]
        elseif tagger.apptags[name] then
            target = tagger.apptags[inst]
        end

        if target then
            awful.client.movetotag(tagger.apptag(target, c.screen))
        end

        This code creates a tag for the client if it doesn't already exist.

        Please note that you should also change keybindings which operate on a certain tag
        like this:

        keybinding({ modkey }, i, function () awful.tag.viewonly(tags[mouse.screen][i]) end):add()
        becomes:
        keybinding({ modkey }, i, function () awful.tag.viewonly(tagger.gettag(i)) end):add()

        The following functions are available for manipulating tags with tagger:
        
        add(screen, name, layout, mwfact, nmaster) - adds a tag with the given properties to the
                                                     specified screen. If one of the last four 
                                                     arguments is omitted, a standard value is
                                                     assumed instead

        remove(screen, index)                      - removes the tag with number index from screen,
                                                     unless the tag has more than zero clients assigned
                                                     or it is the last tag on screen

        clean(screen)                              - removes all empty tags (i.e. tags with no assigned
                                                     clients) from the specified screen

        rename(screen, name)                       - renames the first selected tag on screen, if name is
                                                     omitted, a keygrabber is started which lets you
                                                     change the tags name directly with the keyboard

        moveto(index, client)                      - moves the specified client to the tag with the specified
                                                     index

        movetorel(index, client)                   - behaves as moveto(index, client), except that index is
                                                     relative to the first selected tag on the current screen
                                                     positive values move the client to the right, negative
                                                     values move the client to the left

        movescreen(target)                         - moves the first selected tag on the currently focussed 
                                                     screen to the screen with index tag. all clients on the moved
                                                     tag get their tag table reset so that it contains only the
                                                     moved tag and are moved to the target screen

        movescreenrel(target)                      - behaves as movescreen(target), except index is relative to
                                                     the currently focussed screen

        apptag(name, screen)                       - if a tag with the specified name exists on the specified screen,
                                                     it is returned, else a new tag is created with add(...), and
                                                     also returned

        gettag(index, screen)                      - returns the tag with the number index on the specified screen
--]]
-- }}}
-- {{{ env
local screen = screen
local awful = require("awful")
local table = table
local pairs = pairs
local tag = tag
local mouse = mouse
local client = client
local keygrabber = keygrabber

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
            if tag.selected then
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
    if #tags <= 1 then return end
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
local function name2index(scr, name)
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
local function tag2index(scr, tag)
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
    local tags = screen[scr]:tags()
    local t1 = awful.tag.selected(scr)
    local i1 = tag2index(scr, t1)
    local i2 = awful.util.cycle(#tags, (i1 + idx))

    tags[i1] = tags[i2]
    tags[i2] = t1

    screen[scr]:tags(tags)
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
    local tags = screen[scr_source]:tags()
    if t.selected then
        if index == #tags then
            awful.tag.viewidx(-1, scr)
        else
            awful.tag.viewidx(1, scr)
        end
    end
    table.remove(tags, index)
    screen[scr_source]:tags(tags)

    -- insert the tag into target screens tag list
    t.screen = scr_target
    tags = screen[scr_target]:tags()
    table.insert(tags, t)

    awful.hooks.user.call("arrange", scr_target)
    awful.tag.viewonly(tags[#tags])
end
-- }}}
-- {{{ movescreenrel(idx)
function movescreenrel(idx)
    local index = awful.util.cycle(screen.count(), mouse.screen + idx)
    movescreen(index)
end
-- }}}
-- {{{ apptag(c)
function apptag(c)
    local target
    if apptags[c.instance:lower()] then
        target = apptags[c.instance:lower()]
    elseif apptags[c.class:lower()] then
        target = apptags[c.class:lower()]
    elseif apptags[c.name:lower()] then
            target = apptags[c.name:lower()]
    end
    if not target then return end

    local scr = c.screen
    local idx = name2index(scr, target)
    local tag

    if idx ~= 0 then
        local tags = screen[scr]:tags()
        awful.client.movetotag(tags[idx], c)
    else
        local created = false

        for i = 1, #config do
            if config[i].name == target then
                add(scr, target, config[i].layout, config[i].mwfact, config[i].nmaster)
                created = true
                break
            end
        end
        if not created then add(scr, target) end

        local tags = screen[scr]:tags()
        awful.client.movetotag(tags[#tags], c)
    end
end
-- }}}
-- {{{ gettag(idx, scr)
function gettag(idx, scr)
    if not scr then scr = mouse.screen end
    local tags = screen[scr]:tags()
    return tags[idx]
end
-- }}}
-- {{{ hooks
awful.hooks.manage.register(apptag)
awful.hooks.unmanage.register(function (c)
    clean(c.screen)
end)
-- }}}
