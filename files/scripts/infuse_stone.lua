local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")



local function get_infusion_entity()
    local entity_id
    local stone_id = GetUpdatedEntityID()
    local children = EntityGetAllChildren(stone_id)
    if children then
        for _, child in pairs(children) do
            if EntityGetName(child) == "infusableEntity" then
                entity_id = child
            end
        end
    end
    return stone_id, entity_id
end
local reaction_distance_max = 12

--- VFX function
local function enableHalo(id, enable)
    local compnames = {"ParticleEmitterComponent","SpriteParticleEmitterComponent"}
    for _, compname in pairs(compnames) do
            local components = EntityGetComponentIncludingDisabled(id, compname)
        if components then
            for _, comp_id in ipairs(components) do
                ComponentSetValue2(comp_id, "is_emitting", enable)
            end
        end
    end
end

--- Résout la clé à utiliser pour l'infusion (nom de matériau ou tag).
--- La résolution de recette elle-même est déléguée à stone_factory.
--- Retourne la première clé trouvée dans le registre, ou nil.
local function findMaterialKey(potion_id, entityName)
    local material, material_tags = utils.getPotionMaterial(potion_id)
    if not material then
        log.debug("Potion has no valid material")
        return nil
    end
 
    local stone_map = craft.STONE_TO_MATERIAL_TO_STONE[entityName]
    if not stone_map then return nil end
 
    -- Priorité au nom de matériau exact
    if stone_map[material] then
        return material
    end
 
    -- Fallback sur les tags du matériau
    for _, tag in ipairs(material_tags) do
        if stone_map[tag] then
            log.debug(entityName .. " : recette trouvée via tag '" .. tag .. "'")
            return tag
        end
    end
 
    log.debug(entityName .. "@".. material .. " : aucune recette pour ce matériau/ces tags")
    return nil
end

local function tryCreateStone(potion_id, pos_x, pos_y, entityName)
 
    local entity_id = GetUpdatedEntityID()
    local stone_id = EntityGetParent(entity_id)
 
    local key = findMaterialKey(potion_id, entityName)
    if not key then return false end
 
    local hint_id = utils.getVariable(entity_id, "hintEnable")
    local hintCount = utils.getValue(hint_id, "value_int", 1)
 
    local is_success = stone_factory.tryInfuseStone(entityName, key, hintCount, pos_x, pos_y)
 
    -- Handle the result
    if is_success then
        EntityKill(stone_id)
        EntityKill(potion_id)
        return true
    else
        if hintCount == 0 then
            utils.setValue(hint_id, "value_int", 1)
        end
        return false
    end
end

--- Main infusion function
function material_area_checker_success(pos_x, pos_y)
    local entity_id = GetUpdatedEntityID()
    local stone_id = EntityGetParent(entity_id)

    -- Visual hint
    utils.setVariable(entity_id, "hintEnable", "value_bool", true)
    enableHalo(entity_id, true)

    local entityName = utils.getEntityIdentifier(stone_id)

    -- Get potion or powder_stash material
    local potions_id = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "potion")
    local powder_stashs_id = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "powder_stash")


    if #potions_id == 0 then
        log.debug("No valid potion found nearby")
    end

    if #powder_stashs_id == 0 then
        log.debug("No valid powder_stash found nearby")
    end

    -- merge potions & pouch in one list
    for i=1,#powder_stashs_id do
        potions_id[#potions_id+1] = powder_stashs_id[i]
    end

    -- No potion around : no spamming possible
    if #potions_id == 0 then
        log.debug("Reset hint count")
        local hint_id = utils.getVariable(entity_id, "hintEnable")
        utils.setValue(hint_id, "value_int", 0)
    else

        for i=1, #potions_id do

            -- Don't use potion directly from inventory
            if(potions_id[i] ~= EntityGetRootEntity(potions_id[i])) then goto continue end

            if (tryCreateStone(potions_id[i], pos_x, pos_y, entityName)) then
                return
            end
            ::continue::
        end
    end

end

function item_pickup(entity_item, entity_pickupper, item_name )
    local _, entity_id = get_infusion_entity()

    utils.setVariable(entity_id, "hintEnable", "value_bool", false)
    utils.setVariable(entity_id, "hintEnable", "value_int", 0)
    enableHalo(entity_id, false)
end

--- File code

local _, entity_id = get_infusion_entity()

local hint_variable = utils.getVariable(entity_id, "hintEnable")

if utils.getValue(hint_variable, "value_bool", false) then
    log.debug("disable halo [" .. hint_variable .. "]")
    utils.setValue(hint_variable, "value_bool", false)
else
    utils.setVariable(entity_id, "hintEnable", "value_int", 0)
    enableHalo(entity_id, false)
end