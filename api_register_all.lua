--[[
  ## StreetsMod 2.0 ##
  Submod: streetsapi
  Optional: false
  Category: Init
]]

minetest.after(0, function()
  local surface_list = streets.api.register_road_surfaces
  local marking_list = streets.api.register_road_markings
  -- Loop thorugh the list of surfaces
  for surface_name, surface_definition in pairs(surface_list) do
    -- Register the surface itself (e.g. plain asphalt)
    minetest.register_node(surface_name, surface_definition)
    -- Register for surface alias if given
    if type(surface_definition.aka) == "table" then
      for _, old_name in ipairs(surface_definition.aka) do
        minetest.register_alias(old_name, surface_name)
      end
    end
    -- Register the craft for this surface
    minetest.register_craft(surface_definition.craft)
    -- Loop through the list of markings
    for marking_suffix, marking_data in pairs(marking_list) do
      -- Collect required data for node defintion
      local nn = surface_name .. "_" .. marking_suffix
      local description = surface_definition.description .. " " .. marking_data.friendly_suffix
      local tiles = {surface_definition.tiles[1] .. "^" .. marking_data.overlay, surface_definition.tiles[1]}
      local tiles2 = {surface_definition.tiles[1] .. "^" .. marking_data.overlay:split(".")[1] .. "_yellow.png", surface_definition.tiles[1]}
      local groups = surface_definition.groups
      local sounds = surface_definition.sounds
      -- Replace placeholders in craft recipe
      local craft = table.copy(marking_data.craft)
      local replacement = surface_name:sub(2, -1)
      if craft[1][1] == "?" then craft[1][1] = replacement end
      if craft[1][2] == "?" then craft[1][2] = replacement end
      if craft[1][3] == "?" then craft[1][3] = replacement end
      if craft[2][1] == "?" then craft[2][1] = replacement end
      if craft[2][2] == "?" then craft[2][2] = replacement end
      if craft[2][3] == "?" then craft[2][3] = replacement end
      if craft[3][1] == "?" then craft[3][1] = replacement end
      if craft[3][2] == "?" then craft[3][2] = replacement end
      if craft[3][3] == "?" then craft[3][3] = replacement end
      -- Register the combination of surface and marking
      minetest.register_node(nn, {
        description = description,
        tiles = tiles,
        groups = groups,
        sounds = sounds,
        paramtype = "light",
        paramtype2 = "facedir"
      })
      local craft_output = nn:sub(2, -1)
      -- Register the craft for this node
      minetest.register_craft({
        output = craft_output,
        recipe = craft
      })
      -- Register alias for the marking if given
      if type(marking_data.aka) == "table" then
        for _, old_name in ipairs(marking_data.aka) do
          minetest.register_alias(old_name, craft_output)
        end
      end
      -- Register the yellow version, too
      nn = nn .. "_yellow"
      minetest.register_node(nn, {
        description = description,
        tiles = tiles2,
        groups = groups,
        sounds = sounds,
        paramtype = "light",
        paramtype2 = "facedir"
      })
      craft = table.copy(marking_data.craft)
      replacement = surface_name:sub(2, -1)
      for i = 1, 3 do
        for j = 1, 3 do
          if craft[i][j] == "?" then craft[i][j] = replacement end
          if craft[i][j] == "dye:white" then craft[i][j] = "dye:yellow" end
        end
      end
      craft_output = nn:sub(2, -1)
      minetest.register_craft({
        output = craft_output,
        recipe = craft
      })
      if type(marking_data.aka) == "table" then
        for _, old_name in ipairs(marking_data.aka) do
          minetest.register_alias(old_name, craft_output)
        end
      end
    end
  end
end)