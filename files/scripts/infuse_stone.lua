-- infuse_stone.lua
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local reaction_distance_max = 12

--- VFX function
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

local function findInfusionRecipes(potion_id, entityName)
    local material, material_tags = utils.getPotionMaterial(potion_id)
    if not material then
        log.debug("Potion has no valid material")
        return false
    end
    
    -- Let the factory do its job
    local stone_craft_list = craft.STONE_TO_MATERIAL_TO_STONE[entityName]
    local stone_recipes = stone_craft_list[material]
    -- Check for tag recipes

    if not stone_recipes then
        log.debug(entityName .. " has no recipes involving material '" .. material .. "'.")
        for _, value in ipairs(material_tags) do
            stone_recipes = stone_craft_list[value]
            if stone_recipes then
                log.debug(entityName .. " has recipes involving the tag " .. value)
                break
            else
                log.debug(entityName .. " has no recipes involving the tag " .. value)
            end
        end
    end
    
    if not stone_recipes then
        log.debug(entityName .. " has no recipes involving the potion")
        return false
    end

    return stone_recipes
end

local function tryCreateStone(potion_id, pos_x, pos_y, entityName)

    local stone_key = findInfusionRecipes(potion_id, entityName).stone_key

    local hint_id = utils.getVariable(entity_id, "hintEnable")
    
    local is_success = stone_factory.tryInfuseStone(stone_key, utils.getValue(hint_id, "value_int", 1), pos_x, pos_y)
    
    -- Handle the result
    if is_success then
        EntityKill(EntityGetParent(entity_id))
        EntityKill(potion_id)
        return true
    else
        if(utils.getValue(hint_id, "value_int", 1) == 0) then
            utils.setValue(hint_id, "value_int", 1)
        end

        return false
    end
end

--- Main infusion function
function material_area_checker_success(pos_x, pos_y)
    entity_id = GetUpdatedEntityID()

    -- Visual hint
    utils.setVariable(entity_id, "hintEnable", "value_bool", true)
    enableHalo(entity_id, true)
    
    local entityName = EntityGetName(EntityGetParent(entity_id))

    -- Get potion or powder_stash material
    local potions_id = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "potion")
    local powder_stashs_id = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "powder_stash")


    if #potions_id == 0 then
        log.debug("No valid potion found nearby")
    end

    if #powder_stashs_id == 0 then
        log.debug("No valid powder_stash found nearby")
    end
    
    for i=1,#powder_stashs_id do
        potions_id[#potions_id+1] = powder_stashs_id[i]
    end

    for i=1, #potions_id do
        if (tryCreateStone(potions_id[i], pos_x, pos_y, entityName)) then
            return
        end
    end

end

function item_pickup(entity_item, entity_pickupper, item_name )
    utils.setVariable(entity_item, "hintEnable", "value_bool", true)
    utils.setVariable(entity_item, "hintEnable", "value_int", 0)
    enableHalo(entity_item, false)
end

--- File code

local hint_variable = utils.getVariable(entity_id, "hintEnable")

if utils.getValue(hint_variable, "value_bool", false) then
    log.debug("disable halo [" .. hint_variable .. "]")
    utils.setValue(hint_variable, "value_bool", false)
else
    utils.setVariable(entity_id, "hintEnable", "value_int", 0)
    enableHalo(entity_id, false)
end