local io = {
    popen = io.popen,
    open = io.open
}

local os = {
    execute = os.execute
}

local error = error

local strict = require('strict')
local dbg = require('dbg')

local capi = {
    keygrabber = keygrabber,
    mousegrabber = mousegrabber
}

module('lock')

local function hash(str, mode)
    mode = mode or 'md5'

    local fh = io.popen('mktemp')
    if not fh then error('mktemp failed') end
    local tmpfile = fh:read('*all'):gsub("\n$","")
    fh:close()

    os.execute('chmod 600 "' .. tmpfile .. '"')
    fh = io.open(tmpfile, 'w')
    fh:write(str)
    fh:close()

    fh = io.popen(mode .. 'sum "' .. tmpfile .. '" | cut -d" " -f1')
    if not fh then error('hashing failed') end
    local data = fh:read('*all')
    fh:close()

    os.execute('rm "' .. tmpfile .. '"')
    return data
end

local pwd = 'foo'
pwd = hash(pwd, 'md5') .. hash(pwd, 'sha1')

local locked = true

capi.mousegrabber.run(function(mouse)
    return true
end, 'fleur')

capi.keygrabber.run(function(modifiers, key)
    dbg.dump(key)
    return true
end)

dbg.dump(pwd)
