local keygrabber = keygrabber
local awful = require("awful")
local math = math
local pairs = pairs
local table = table
local type = type
local wibox = wibox
local widget = widget
local image = image

math.randomseed(os.time())

module("maze")

config = {
	-- Width and height of the squares used for the maze
	square_size = 10,
	-- Position the maze will appear at
	x = 0,
	y = 0,
	-- Number of squares the maze is big
	width = 45,
	height = 45,
	-- Colors used to display various things
	wall = "#123456",
	path = "#000000",
	player = "#ff0000",
}

local maze

function init(width, height, screen)
	local w
	local h
	local px_width = config.square_size * width
	local px_height = config.square_size * height

	maze = { }
	maze.field = { }
	maze.player = { x = 2, y = 2 }
	maze.width = width
	maze.height = height

	for w = 1, width do
		maze.field[w] = { }
		for h = 1, height do
			maze.field[w][h] = config.wall
		end
	end

	maze.image = image.argb32(px_width, px_height, nil)
	maze.image:draw_rectangle(0, 0, px_width, px_height, true, config.wall)

	maze.imagebox = widget({ type = "imagebox" })
	maze.imagebox.image = maze.image

	maze.wibox = wibox({
		position = "floating",
		bg = config.wall,
		width = px_width,
		height = px_height,
		x = config.x,
		y = config.y,
	})
	maze.wibox.widgets = maze.imagebox
	maze.wibox.ontop = true
	maze.wibox.visible = true
	maze.wibox.screen = screen
end

function destroy()
	local w
	local h

	maze.wibox.screen = nil
	maze = nil
end

function get(x, y)
	return maze.field[x][y]
end

function set(x, y, v)
	local sq = config.square_size
	maze.field[x][y] = v

	-- We also have to draw the new version of the maze
	maze.image:draw_rectangle(sq * (x - 1), sq * (y - 1), sq, sq, true, v)
	-- This is necessary for the imagebox to be updated
	maze.imagebox.image = maze.image
end

function is_valid(x, y)
	if x < 1 or y < 1 then
		return false
	end
	if x > maze.width or y > maze.height then
		return false
	end
	return true
end

function is_wall(x, y)
	if not is_valid(x, y) then
		return false
	end
	if get(x, y) ~= config.wall then
		return false
	end
	return true
end

function is_path(x, y)
	if not is_valid(x, y) then
		return false
	end
	if get(x, y) ~= config.path then
		return false
	end
	return true
end

function move_player(x, y)
	if not is_path(x, y) then
		return
	end

	set(maze.player.x, maze.player.y, config.path)
	set(x, y, config.player)
	maze.player.x = x
	maze.player.y = y
end

local function make_maze()
	local start = 2 + 2 * math.random(config.width / 2 - 1)
	local finish = 2 + 2 * math.random(config.width / 2 - 1)

	set(start, 1, config.path)
	set(finish, config.height, config.path)

	maze.player.x = start
	maze.player.y = 1

	local x = 2 + 2 * math.random(config.width / 2 - 1)
	local y = 2 + 2 * math.random(config.height/ 2 - 1)

	local fieldlist = { { x = x, y = y } }

	while #fieldlist > 0 do
		local i = math.random(#fieldlist)
		local v = fieldlist[i]

		local x = v.x
		local y = v.y

		-- The code which inserted this field into the list should already have
		-- done this, but we better make sure.
		set(x, y, config.path)

		local dir = { 1, 2, 3, 4}
		while #dir > 0 do
			local tx = x
			local ty = y

			local _i = math.random(#dir)
			local _v = dir[_i]
			table.remove(dir, _i)

			if _v == 1 then
				ty = ty - 2
			elseif _v == 2 then
				tx = tx + 2
			elseif _v == 3 then
				ty = ty + 2
			elseif _v == 4 then
				tx = tx - 2
			end

			if is_wall(tx, ty) then
				set((x + tx) / 2, (y + ty) / 2, config.path)
				set(tx, ty, config.path)
				table.insert(fieldlist, { x = tx, y = ty})
				break
			end
		end

		if #dir == 0 then
			table.remove(fieldlist, i)
		end
	end

	set(maze.player.x, maze.player.y, config.player)
end

local function keyhandler(mod, key, event)
	if maze == nil then
		return false
	end
	if event ~= "press" then
		return true
	end

	if key == "q" then
		destroy()
		return false
	elseif key == "Left" or key == "h" then
		move_player(maze.player.x - 1, maze.player.y)
	elseif key == "Right" or key == "l" then
		move_player(maze.player.x + 1, maze.player.y)
	elseif key == "Down" or key == "j" then
		move_player(maze.player.x, maze.player.y + 1)
	elseif key == "Up" or key == "k" then
		move_player(maze.player.x, maze.player.y - 1)
	end

	-- If the player reached the exit (= is in the bottom-most row)
	if maze.player.y == maze.height then
		destroy()
		return false
	end
	return true
end

function run(s)
	local square_size = config.square_size
	local iw
	local ih

	s = s or 1

	if maze ~= nil then
		return
	end

	-- Make sure we have a border around the field.
	-- This makes sure we have an odd number of rows / columns.
	if config.height % 2 == 0 then
		config.height = config.height + 1
	end
	if config.width % 2 == 0 then
		config.width = config.width + 1
	end

	init(config.width, config.height, s)

	make_maze()

	keygrabber.run(keyhandler)
end
