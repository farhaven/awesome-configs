require('awful')

session = { }

if os.getenv("XDG_CACHE_HOME") then session.clientcache = os.getenv("XDG_CACHE_HOME") .. "/awesome/clients"
else session.clientcache = os.getenv("HOME") .. "/.cache/awesome/clients" end

session.clients_data = { } 
session.clients_blacklist = { }
session.clients_managed = { }

-- {{{ table.contains(table, item) returns true if table contains item
function table.contains(table, item)
	for k, v in pairs(table) do
		if v == item then return true end
	end
	return false
end
-- }}}

-- {{{ gettagnumber (tag) returns the position of a tag inside the taglist
function gettagnumber (tag)
	local t = screen[tag.screen]:tags()
	for i = 1, #t do
		if t[i] == tag then
			return i
		end
	end
	return 0
end
-- }}}

-- {{{ session.save_clients(client) dumps information about managed clients
function session.save_clients (c)
	if not c then
		print("\nUpdating client cache")
		local clients = client.get()
		for i = 1, #clients do 
			local c = clients[i]
			if not session.clients_blacklist[c.class:lower()] then
				local fp = c.class .. "." .. c.instance .. "." .. c.name 
				local t = c:tags()
				local coords = c:coords()

				session.clients_data[fp] = { }
				session.clients_data[fp].class = c.class
				session.clients_data[fp].instance = c.instance
				session.clients_data[fp].name = c.name
				session.clients_data[fp].tags = ""

				for j = 1, #t do
					session.clients_data[fp].tags = gettagnumber(t[j]) .. ":" .. t[j].screen .. " " .. session.clients_data[fp].tags
				end
		
				--session.clients_data[fp].coords = coords.x .. "x" .. coords.y .. "+" .. coords.width .. "+" .. coords.height
				session.clients_data[fp].coords = coords.width .. "x" .. coords.height .. "+" .. coords.x .. "+" .. coords.y
				print(fp)
				print("\t"..session.clients_data[fp].coords.." "..session.clients_data[fp].tags)
			end
		end
	else
		print("\nWriting client cache to disk")
		local t = session.clients_managed
		local i = 0
		while #t > 0 do
			i = i + 1
			if t[1] == c then break end
			table.remove(t, 1)
		end
		table.remove(session.clients_managed, i)

		local fh = io.open(session.clientcache, "w")
		if fh then
			for k, v in pairs(session.clients_data) do
				fh:write(v.class.."\n")
				fh:write(v.instance.."\n")
				fh:write(v.name.."\n")

				fh:write(v.tags.."\n")
				fh:write(v.coords.."\n")
				print(v.class..":"..v.instance..":"..v.name)
				print("\t"..v.coords.. " "..v.tags)
				fh:flush()
			end
		end
	end
end
-- }}}

-- {{{ session.restore_clients(client) restores all currently managed clients to their original screen, tag and position
function session.restore_clients (c)
	if not c then
		print("\nReading client cache from disk")
		local fh = io.open(session.clientcache, "r")
		local readbuffer = { }
		while true do
			-- {{{ read the next line and abort on eof / error
			if not fh then break end
			local line = fh:read("*line")
			if not line then break end
			table.insert(readbuffer, line)
			-- }}}
		end
		if fh then fh:close() end
		while #readbuffer >= 1 do	
			-- {{{ parse the information
			local class = readbuffer[1]
			table.remove(readbuffer, 1)

			local inst = readbuffer[1]
			table.remove(readbuffer, 1)

			local name = readbuffer[1]
			table.remove(readbuffer, 1)

			local tags = readbuffer[1]
			table.remove(readbuffer, 1)


			local pos = { }
			pos.match = readbuffer[1]
			table.remove(readbuffer, 1)
		
			local fp = class .. "." .. inst .. "." .. name
			session.clients_data[fp] = { }
			session.clients_data[fp].coords = pos.match
			session.clients_data[fp].tags = tags
			session.clients_data[fp].class = class
			session.clients_data[fp].instance = inst
			session.clients_data[fp].name = name
			-- }}}
		end
	else
		print("\nRestoring clients")
		table.insert(session.clients_managed, c)
		-- {{{ find a matching client
		-- first, we match by class .. name, as it's more accurate
		-- if that didn't yield results, we match by class .. instance
		-- suggested by koniu
		local clients = client.get()
		while #clients > 0 do
			local cached = { }
			cached.found = false
			cached.client = clients[1]
			table.remove(clients, 1)
			function find_client(class, name, inst)
				if name ~= "" then cached.fp = class .. "\n" .. name
				else cached.fp = class .. "\n" .. inst end

				for k, v in pairs(session.clients_data) do
					local fp = v.class
					if name ~= "" then fp = fp .. "\n" .. v.name
					else fp = fp .. "\n" .. v.inst end
					if fp == cached.fp then
						cached.found = true
						cached.coords = v.coords
						cached.tags = v.tags
						break
					end
				end
				return cached.found
			end
			if not find_client(cached.client.class, cached.client.name, "") then find_client(cached.client.class, "", cached.client.instance) end
		-- }}}
		-- {{{ restore the client to its previous state
			if cached.found and not session.clients_blacklist[cached.client.class:lower()] then
				print(cached.client.class..":"..cached.client.instance..":"..cached.client.name)
				print("\t"..cached.coords.." "..cached.tags)
				-- {{{ restore the clients tags 
				local newtags = { }
				for tag in string.gmatch(cached.tags, "(%d+:%d+)") do
					local tagnumber = tonumber(string.match(tag, "^(%d+):"))
					local tagscreen = tonumber(string.match(tag, ":(%d+)$"))
					local tags = screen[tagscreen]:tags()
					cached.client.screen = tagscreen
					table.insert(newtags, tags[tagnumber])
				end
				cached.client:tags(newtags)
				-- }}}
				-- {{{ restore the clients geometry
				cached.geometry = { }
				cached.geometry.x = tonumber(string.match(cached.coords, ".*%+(%d+)%+.*"))
				cached.geometry.y = tonumber(string.match(cached.coords, ".*%+(%d+).*"))
				cached.geometry.height = tonumber(string.match(cached.coords, "(%d+)x.*"))
				cached.geometry.width = tonumber(string.match(cached.coords, ".*%+(%d+)%+.*"))

				print("Should be: "..cached.geometry.height.."x"..cached.geometry.width.."+"..cached.geometry.x.."+"..cached.geometry.y)

				cached.client:coords(cached.geometry)
				cached.geometry = cached.client:fullcoords()

				print("Is: "..cached.geometry.height.."x"..cached.geometry.width.."+"..cached.geometry.x.."+"..cached.geometry.y)
				-- }}}
			end
		-- }}}
		end
	end
end
-- }}}

--{{{ session.property_hook
awful.hooks.property.register(function (c, property)
	if property == "geometry" and table.contains(session.clients_managed, c) then
		session.save_clients()
	end
end)
-- }}}

-- {{{ session.unmanage_hook
awful.hooks.unmanage.register(function (c)
	session.save_clients(c)
end)
-- }}}

-- {{{ session.manage_hook
awful.hooks.manage.register(function (c)
	session.restore_clients(c)
end)
-- }}}

session.restore_clients()
