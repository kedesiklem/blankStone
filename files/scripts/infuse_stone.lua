-- local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local reaction_distance_max = 10 -- maybe change to entity variable
local vanilla_stone_path = "data/entities/items/pickup/"
local elemental_stone_path = "mods/blankStone/files/entities/elemental_stone/"



-- Level indicate two things : how strong the stone is, and how hard it is go get normaly for the vanilla ones
-- Higher level means stronger stone and harder to get
-- Level 1 : Can naturally be found
-- Level 5 : Need to use essence eater, or equivalent (not hard, but not trivial)
-- Level 9 : Obtain from boss or special event only
-- From there you can use the scale and define complexe rituals. 

local ambrosiaStone = {path = elemental_stone_path .. "stone_ambrosia", level = 12}
local healthStone = {path = elemental_stone_path .. "stone_health", level = 12}
local loveStone = {path = elemental_stone_path .. "stone_love", level = 10}
local stone_toxic = {path = elemental_stone_path .. "stone_toxic", level = 1}

local sunseed = {path = vanilla_stone_path .. "sun/sunseed", level = 9}
local wandstone = {path = vanilla_stone_path .. "wandstone", level = 9}
local brimstone = {path = vanilla_stone_path .. "brimstone", level = 1}
local thunderstone = {path = vanilla_stone_path .. "thunderstone", level = 1}
local stonestone = {path = vanilla_stone_path .. "stonestone", level = 5}
local waterstone = {path = vanilla_stone_path .. "waterstone", level = 5}
local poopstone = {path = vanilla_stone_path .. "poopstone", level = 5}

local material_to_stone_tbl =
{
  -- Vanilla Stone

  ["blood_worm"] = sunseed,
  ["magic_liquid_mana_regeneration"] = wandstone,
  ["liquid_fire"] = brimstone,
  ["spark_electric"] = thunderstone,
  ["rock_static"] = stonestone,
  [ "water" ] = waterstone,
  [ "poo" ] = poopstone,

  -- Custom Stone


  ["radioactive_liquid"] = stone_toxic,
  ["magic_liquid_hp_regeneration"] = healthStone,
  ["magic_liquid_hp_regeneration_unstable"] = healthStone,
  ["magic_liquid_protection_all"] = ambrosiaStone,
  ["magic_liquid_charm"] = loveStone,
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
      local stone = material_to_stone_tbl[material].path
      if(stone) then
        --- Infuse stone
        EntityLoad( stone ..".xml", pos_x, pos_y - 5)
        EntityLoad("data/entities/projectiles/explosion.xml", pos_x, pos_y - 10)
        EntityKill(entity_id)
        EntityKill(potion_id)
      end
    end
  end
end