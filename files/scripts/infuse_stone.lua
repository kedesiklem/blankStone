-- infuse_stone.lua

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local reaction_distance_max = 10

-- Mapping material to keys in STONE_REGISTRY
local MATERIAL_TO_STONE = {
    -- Vanilla Stones
    ["blood_worm"] = "sunseed",
    ["magic_liquid_mana_regeneration"] = "wandstone",
    ["liquid_fire"] = "brimstone",
    ["spark_electric"] = "thunderstone",
    ["rock_static"] = "stonestone",
    ["water"] = "waterstone",
    ["poo"] = "poopstone",

    -- Custom Stones
    ["radioactive_liquid"] = "toxicStone",
    ["magic_liquid_hp_regeneration"] = "healthStone",
    ["magic_liquid_hp_regeneration_unstable"] = "healthStone",
    ["magic_liquid_protection_all"] = "ambrosiaStone",
    ["magic_liquid_charm"] = "loveStone",
}

local function drawCircle(pos_x, pos_y, radius)
    local segments = 32
    for i = 0, segments - 1 do
        local angle = (i / segments) * 2 * math.pi
        local x = pos_x + math.cos(angle) * radius
        local y = pos_y + math.sin(angle) * radius
        GameCreateParticle("spark_white_bright", x, y, 1, 0, 0, false, false, false)
    end
end

local function isValidPotion(potion_id, pos_x, pos_y, max_distance)
    if potion_id == 0 then
        return false
    end
    
    local potion_x, potion_y = EntityGetTransform(potion_id)
    local distance = math.sqrt((potion_x - pos_x) ^ 2 + (potion_y - pos_y) ^ 2)
    
    return distance < max_distance
end

local function getPotionMaterial(potion_id)
    local material_id = GetMaterialInventoryMainMaterial(potion_id)
    if material_id == 0 then
        return nil
    end
    
    return CellFactory_GetName(material_id)
end

function material_area_checker_success(pos_x, pos_y)
    local entity_id = GetUpdatedEntityID()
    
    -- Visual hint
    drawCircle(pos_x, pos_y, reaction_distance_max)
    
    -- Get potion material
    local potion_id = EntityGetClosestWithTag(pos_x, pos_y, "potion")
    if not isValidPotion(potion_id, pos_x, pos_y, reaction_distance_max) then
        log.info("No valid potion found nearby")
        return
    end
    
    local material = getPotionMaterial(potion_id)
    if not material then
        log.info("Potion has no valid material")
        return
    end
    
    -- Let the factory do its job
    local stone_key = MATERIAL_TO_STONE[material]
    if not stone_key then
        log.info("Material '" .. material .. "' does not produce any stone")
        return
    end
    
    local success = stone_factory.tryCreateStone(stone_key, pos_x, pos_y, potion_id)
    
    -- Handle the result
    if success then
        EntityKill(entity_id)
        EntityKill(potion_id)
        EntityLoad("data/entities/projectiles/explosion.xml", pos_x, pos_y - 10)
        GamePrint("You've done something...")
    else
        GamePrint("Something's wrong...")
    end
end