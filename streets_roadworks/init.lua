--[[
  ## StreetsMod 2.0 ##
  Submod: roadworks
  Optional: true
]]

minetest.register_node(":streets:rw_cross",{
	description = "Roadworks: Cross",
	tiles = {"streets_cross.png", "streets_transparent.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {snappy = 3,attached_node = 1,oddly_breakable_by_hand = 1},
	sunlight_propagates = true,
	walkable = false,
	inventory_image = "streets_cross.png",
	wield_image = "streets_cross.png",
  node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.499, 0.5}}
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}
	}
})

minetest.register_node(":streets:rw_line_solid",{
  description = "Roadworks: Solid line",
  tiles = {"streets_line_solid_yellow.png", "streets_rw_solid_curve.png", "streets_rw_solid_tjunction.png", "streets_rw_solid_crossing.png"},
	drawtype = "raillike",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy = 3,attached_node = 1,oddly_breakable_by_hand = 1},
	sunlight_propagates = true,
	walkable = false,
	inventory_image = "streets_line_solid_yellow.png",
	wield_image = "streets_line_solid_yellow.png",
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}
	}
})

minetest.register_node(":streets:rw_line_dashed",{
  description = "Roadworks: Dashed line",
  tiles = {"streets_line_dashed_yellow.png", "streets_rw_solid_curve.png", "streets_rw_solid_tjunction.png", "streets_rw_solid_crossing.png"},
	drawtype = "raillike",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy = 3,attached_node = 1,oddly_breakable_by_hand = 1},
	sunlight_propagates = true,
	walkable = false,
	inventory_image = "streets_line_dashed_yellow.png",
	wield_image = "streets_line_dashed_yellow.png",
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}
	}
})
