-- infuse_stone.lua

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local entity_id = GetUpdatedEntityID()
local reaction_distance_max = 10


local function setValue(component, name, value)
    if component ~= nil then
        ComponentSetValue2(component, name, value)
    end
end
local function getValue(component, name, default)
    if component ~= nil then
        return ComponentGetValue2(component, name)
    end
    return default
end

local hint_variable = EntityGetFirstComponentIncludingDisabled(entity_id, "VariableStorageComponent")


-- Mapping material to keys in STONE_REGISTRY
local STONE_TO_MATERIAL_TO_STONE = {
    ["blankStone"] = {

        -- Vanilla Stones --
        -------------------------
        ["blood_worm"] = "sunseed",
        ["magic_liquid_mana_regeneration"] = "wandstone",
        ["liquid_fire"] = "brimstone",
        ["spark_electric"] = "thunderstone",
        ["rock_static"] = "stonestone",
        ["water"] = "waterstone",
        ["poo"] = "poopstone",
        -------------------------
        
        ["radioactive_liquid"] = "toxicStone",
        ["magic_liquid_berserk"] = "bigStone",
        ["magic_liquid_faster_levitation"] = "levitatiumStone",
        ["magic_liquid_movement_faster"] = "acceleratiumStone",
        ["magic_liquid_faster_levitation_and_movement"] = "hasteStone",
        ["magic_liquid_hp_regeneration"] = "healthStone",
        ["magic_liquid_hp_regeneration_unstable"] = "healthStone",
        ["magic_liquid_protection_all"] = "ambrosiaStone",
    },
    ["levitatiumStone"] = {
        ["magic_liquid_movement_faster"] = "hasteStone",
    },
    ["acceleratiumStone"] = {
        ["magic_liquid_faster_levitation"] = "hasteStone",
    },
    ["bigStone"] = {
        ["material_confusion"] = "loveStone",
    },
}

local function enableHalo(id, enable)
    local components = EntityGetComponentIncludingDisabled(id, "SpriteParticleEmitterComponent")
    if components then
        for _, comp_id in ipairs(components) do
            if ComponentGetValue2(comp_id, "sprite_file") == "mods/blankStone/files/VFX/particles/bubble.xml" then
                ComponentSetValue2(comp_id, "is_emitting", enable)
            end
        end
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
    entity_id = GetUpdatedEntityID()

    -- Visual hint
    
    local stored_variable = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    if(stored_variable) then
        for _, value in ipairs(stored_variable) do
            if(ComponentGetValue2(value, "name") == "hintEnable") 
            then
                hint_variable = value
            end
        end
    end

    setValue(hint_variable, "value_bool", true)
    enableHalo(entity_id, true)
    
    local entityName = EntityGetName(EntityGetParent(entity_id))

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
    local stone_key = STONE_TO_MATERIAL_TO_STONE[entityName][material]
    if not stone_key then
        log.info(entityName .. " has no recipies involving '" .. material .. "'.")
        return
    end
    
    local success = stone_factory.tryCreateStone(stone_key, pos_x, pos_y, potion_id)
    
    -- Handle the result
    if success then
        EntityKill(EntityGetParent(entity_id))
        EntityKill(potion_id)
        EntityLoad("data/entities/projectiles/explosion.xml", pos_x, pos_y - 10)
        GamePrint("You've done something...")
    else
        GamePrint("Something's wrong...")
    end

end

if getValue(hint_variable, "value_bool", false) then
    log.info("disable halo [" .. hint_variable .. "]")
    setValue(hint_variable, "value_bool", false)
else
    enableHalo(entity_id, false)
end