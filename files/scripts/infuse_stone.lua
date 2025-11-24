-- local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local reaction_distance_max = 10 -- maybe change to entity variable
local vanilla_stone_path = "data/entities/items/pickup/"
local elemental_stone_path = "mods/blankStone/files/entities/"
local material_to_stone_tbl =
{
  -- Vanilla Stone
  ["magic_liquid_mana_regeneration"] = vanilla_stone_path .. "wandstone",
  ["liquid_fire"] = vanilla_stone_path .. "brimstone",
  ["spark_electric"] = vanilla_stone_path .. "thunderstone",
  ["rock_static"] = vanilla_stone_path .. "stonestone",
  [ "water" ] = vanilla_stone_path .. "waterstone",
  [ "poo" ] = vanilla_stone_path .. "poopstone",

  -- Custom Stone
  ["radioactive_liquid"] = elemental_stone_path .. "stone_toxic",
}


function material_area_checker_success(pos_x, pos_y)
  local entity_id    = GetUpdatedEntityID()

  -- Visual hint
    local segments = 32
    for i = 0, segments - 1 do
        local angle = (i / segments) * 2 * math.pi
        local x = pos_x + math.cos(angle) * reaction_distance_max
        local y = pos_y + math.sin(angle) * reaction_distance_max
        GameCreateParticle("spark_white_bright", x, y, 1, 0, 0, false, false, false)
    end

  local potion_id = EntityGetClosestWithTag(pos_x,pos_y,"potion")
  local potion_x,potion_y = EntityGetTransform(potion_id)

  local distance = math.sqrt((potion_x - pos_x) ^ 2 + (potion_y - pos_y) ^ 2 )
  if(distance < reaction_distance_max) then
    local material_id = GetMaterialInventoryMainMaterial(potion_id)
    if(material_id ~= 0) then
      local material = CellFactory_GetName(material_id)
      local stone = material_to_stone_tbl[material]
      if(stone) then
        EntityLoad( stone ..".xml", pos_x, pos_y - 5)
        EntityLoad("data/entities/projectiles/explosion.xml", pos_x, pos_y - 10)
        EntityKill(entity_id)
        EntityKill(potion_id)
      end
    end
  end
end