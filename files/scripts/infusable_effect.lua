local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local reaction_distance_max = 12

local function findMaterialKey(potion_id, stoneKey)
    local material, material_tags = utils.getPotionMaterial(potion_id)
    if not material then
        log.debug("Potion has no valid material")
        return nil
    end

    local stone_map = craft.STONE_TO_MATERIAL_TO_STONE[stoneKey]
    if not stone_map then return nil end

    if stone_map[material] then
        return material
    end

    for _, tag in ipairs(material_tags) do
        if stone_map[tag] then
            log.debug(stoneKey .. " : recette trouvée via tag '" .. tag .. "'")
            return tag
        end
    end

    log.debug(stoneKey .. "@" .. material .. " : aucune recette pour ce matériau/ces tags")
    return nil
end

local function tryCreateStone(potion_id, pos_x, pos_y, stone_id, infusable_id, entityName)
    local key = findMaterialKey(potion_id, entityName)
    if not key then return false end

    local hint_id = utils.getVariable(infusable_id, "hintEnable")
    local hintCount = utils.getValue(hint_id, "value_int", 1)

    local is_success = stone_factory.tryInfuseStone(entityName, key, hintCount, pos_x, pos_y)

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

local function getNearbyReactives(pos_x, pos_y)
    local potions_id = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "potion")
    local powder_stashs_id = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "powder_stash")

    if #potions_id == 0 then
        log.debug("No valid potion found nearby")
    end

    if #powder_stashs_id == 0 then
        log.debug("No valid powder_stash found nearby")
    end

    for i = 1, #powder_stashs_id do
        potions_id[#potions_id + 1] = powder_stashs_id[i]
    end

    return potions_id
end

local entity_id = GetUpdatedEntityID()
local stone_id = EntityGetParent(entity_id)
if stone_id == 0 then return end

local infusable_id
local children = EntityGetAllChildren(stone_id)
if children then
    for _, child in pairs(children) do
        if EntityGetName(child) == "infusableEntity" then
            infusable_id = child
        end
    end
end
if not infusable_id then return end

local pos_x, pos_y = EntityGetTransform(entity_id)
local entityName = utils.getEntityIdentifier(stone_id)
local reactives_id = getNearbyReactives(pos_x, pos_y)

if #reactives_id == 0 then
    log.debug("Reset hint count")
    local hint_id = utils.getVariable(infusable_id, "hintEnable")
    utils.setValue(hint_id, "value_int", 0)
else
    for i = 1, #reactives_id do
        -- Don't use potion directly from inventory
        if reactives_id[i] == EntityGetRootEntity(reactives_id[i]) then
            if tryCreateStone(reactives_id[i], pos_x, pos_y, stone_id, infusable_id, entityName) then
                break
            end
        end
    end
end