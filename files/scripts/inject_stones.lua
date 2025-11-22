local entity_path = "mods/blankStone/files/entities"

local add_list = {
    {
        load_entity = entity_path .. "blank_stone.xml",
        value_min = 80,
        value_max = 95
    },{
        load_entity = entity_path .. "stone_toxic.xml",
        value_min = 85,
        value_max = 90
    }
}

local function register_item(spawn_list)
	return function(add)
		for _, item in ipairs(add) do
			spawn_list[#spawn_list + 1] = item
		end
	end
end

register_item(spawnlists.potion_spawnlist.spawns)(add_list)