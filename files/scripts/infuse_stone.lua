local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )


local reaction_distance_max = 70 -- maybe change to entity variable
local elemental_stone_path = "mods/blankStone/files/entities/"
local material_to_stone_tbl =
{
  ["radioactive_liquid"] = "stone_toxic",
}

-- TODO:
-- Get nearby flask -> get main material -> check table -> convert blank_stone