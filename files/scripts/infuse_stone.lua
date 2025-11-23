local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local reaction_distance_max = 10 -- maybe change to entity variable
local elemental_stone_path = "mods/blankStone/files/entities/"
local material_to_stone_tbl =
{
  ["radioactive_liquid"] = "stone_toxic",
}
-- TODO:
-- [Get nearby flask -> get main material] -> check table -> convert blank_stone
function material_area_checker_success(pos_x, pos_y)
  local entity_id    = GetUpdatedEntityID()
  log.info("infuse")
  local potion_id = EntityGetClosestWithTag(pos_x,pos_y,"potion")
  local potion_x,potion_y = EntityGetTransform(potion_id)

  local distance = math.sqrt((potion_x - pos_x) ^ 2 + (potion_y - pos_y) ^ 2 )
  if(distance < reaction_distance_max) then
    local material_id = GetMaterialInventoryMainMaterial(potion_id)
    if(material_id == 0) then
      log.debug("No material found in potion")
    else
      local material = CellFactory_GetName(material_id)
      log.debug("Main material in potion : " .. material)
      local stone = material_to_stone_tbl[material]
      if(stone) then
        log.debug("Linked stone : " .. stone)
        EntityLoad(elemental_stone_path .. stone ..".xml", pos_x, pos_y - 5)
        EntityLoad("data/entities/projectiles/explosion.xml", pos_x, pos_y - 10)
        EntityKill(entity_id)
        EntityKill(potion_id)
        log.info("A transformation happend")
      else
        log.debug("No linked stone.")
      end
    end
  else
    log.debug("No potion close enough")
  end
  
end