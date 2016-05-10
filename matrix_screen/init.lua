local matrix_px = 16

-- gets the object at pos
local function get_screen(pos)
	for _,obj in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		local ent = obj:get_luaentity()
		if ent
		and ent.name == "streets:matrix_screen_lights" then
			return obj
		end
	end
end

-- used to get the texture for the object
local function generate_textures(data)
	local texture,n = {"streets_matrix_screen_front.png^[combine:"..matrix_px.."x"..matrix_px},2
	for y = 1,matrix_px do
		local xs = data[y]
		for x = 1,matrix_px do
			if xs[x] then
				texture[n] = ":".. x-1 ..",".. y-1 .."=streets_matrix_px.png"
				n = n+1
			end
		end
	end
	if n == 2 then
		-- entirely disabled
		texture = "streets_matrix_screen_front.png"
	else
		texture[n] = "^streets_matrix_screen_lines.png"
		texture = table.concat(texture, "")
	end
	--print(texture)
	return {texture, texture, texture, texture, texture, texture}
end

-- updates texture of screen
local function update_screen(pos, data)
	local obj = get_screen(pos) or minetest.add_entity(pos, "streets:matrix_screen_lights")
	obj:set_properties({textures = generate_textures(data)})
end

-- returns an empty toggleds table
local function new_toggleds()
	local t = {}
	for y = 1,matrix_px do
		t[y] = {}
	end
	return t
end

-- gets the toggleds of the node from meta
local function get_data(meta)
	local data = minetest.deserialize(minetest.decompress(meta:get_string("toggleds")))
	if type(data) ~= "table" then
		data = new_toggleds()
	end
	return data
end

-- update toggleds via a table sent by digiline
local function apply_changes(toggleds, t)
	if type(t) ~= "table" then
		if t == "reset" then
			for y = 1,matrix_px do
				toggleds[y] = {}
			end
			return true
		end
		return false, "matrix screen: got unsupported thing: "..dump(t)
	end
	local changed
	for y = 1,16 do
		local xs = t[y]
		if type(xs) == "table" then
			for x = 1,16 do
				local enabled = xs[x]
				if enabled
				and enabled ~= 0
				and not toggleds[y][x] then
					toggleds[y][x] = true
					changed = true
				elseif (enabled == false
					or enabled == 0)
				and toggleds[y][x] then
					toggleds[y][x] = nil
					changed = true
				end
			end
		end
	end
	if changed then
		--return true, "successfully updated toggleds"
		return true
	end
	return false, "nothing updated"
end

-- sets the toggleds of the node to meta
local function set_data(meta, toggleds)
	meta:set_string("toggleds", minetest.compress(minetest.serialize(toggleds)))
end

minetest.register_node("streets:matrix_screen_base", {
	description = "digiline controllable matrix screen",
	tiles = {"streets_matrix_screen_front.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3, oddly_breakable_by_hand=2},
	sounds = default.node_sound_stone_defaults(),
	light_source = 15,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.49, 0.5, 0.5, 0.5},
		},
	},
	on_construct = function(pos)
		minetest.add_entity(pos, "streets:matrix_screen_lights")
	end,
	on_destruct = function(pos)
		local obj = get_screen(pos)
		if obj then
			obj:remove()
		end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, t)
				if channel ~= "streets:matrix_screen" then
					return
				end
				local meta = minetest.get_meta(pos)
				local toggleds = get_data(meta)
				local changed, msg = apply_changes(toggleds, t)
				if changed then
					set_data(meta, toggleds)
					update_screen(pos, toggleds)
				else
					digiline:receptor_send(pos, digiline.rules.default, "streets:matrix_screen_error", msg)
				end
			end
		},
	},
})

-- ensure the screen existence
minetest.register_lbm({
	name = "streets:matrix_screen_loading",
	nodenames = {"streets:matrix_screen_base"},
	run_at_every_load = true,
	action = function(pos, node)
		if not get_screen(pos) then
			local toggleds = get_data(minetest.get_meta(pos))
			update_screen(pos, toggleds)
			minetest.log("error", "[streets] matrix screen object was missing")
		end
	end,
})

-- the screen
minetest.register_entity("streets:matrix_screen_lights", {
	collisionbox = {0,0,0, 0,0,0},
	physical = false,
	visual = "cube",
	visual_size = {x=0.99, y=0.99},
	on_activate = function(self, staticdata)
		local pos = self.object:getpos()
		if not vector.equals(pos, vector.round(pos)) then
			self.object:remove()
			return
		end
		local node = minetest.get_node(pos)
		if node.name ~= "streets:matrix_screen_base"
		and node.name ~= "ignore" then
			self.object:remove()
			return
		end
		minetest.after(0, function(pos)
			update_screen(pos, get_data(minetest.get_meta(pos)))
		end, pos)
		--[[
		print(8)
		self.object:set_properties(
		{textures = generate_texture(
		get_data(minetest.get_meta(pos)))})--]]
	end,
})
