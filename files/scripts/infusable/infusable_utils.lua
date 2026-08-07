local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
local I = {}

local reaction_distance_max = 12

function I.findMaterialKey(potion_id, stoneKey)
    local material, material_tags = U.getPotionMaterial(potion_id)
    if not material then
        log.debug("Potion has no valid material")
        return nil
    end

    local stone_map = craft.INFUSION_RECIPES[stoneKey]
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

function I.tryCreateStone(potion_id, pos_x, pos_y, stone_id, infusable_id, entityName)
    local key = I.findMaterialKey(potion_id, entityName)
    if not key then return false end

    local hint_id = U.getVariable(infusable_id, "hintEnable")
    local hintCount = U.getValue(hint_id, "value_int", 1)

    local is_success = stone_factory.tryInfuseStone(entityName, key, hintCount, pos_x, pos_y)

    if is_success then
        EntityKill(stone_id)
        EntityKill(potion_id)
        return true
    else
        if hintCount == 0 then
            U.setValue(hint_id, "value_int", 1)
        end
        return false
    end
end

function I.getNearbyReactives(pos_x, pos_y)
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

return I