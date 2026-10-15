local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
local I = {}

local reaction_distance_max = 12

-- Quantité minimale (en cellules) de matériau requise pour infuser, par source.
-- Une fiole pleine = 1000 cellules.
-- Valeurs par défaut : surchargeables par matériau via `min_amount` dans infuse_registry.
I.SOURCE_FLASK = "flask"
I.SOURCE_SUCK  = "suck"
local MIN_AMOUNT = {
    [I.SOURCE_FLASK] = 100,
    [I.SOURCE_SUCK]  = 500,
}

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

--- Somme des cellules du conteneur qui correspondent à la clé de recette
--- (nom exact du matériau, ou tag "[xxx]").
function I.getMaterialAmount(container_id, key)
    local inv = EntityGetFirstComponentIncludingDisabled(container_id, "MaterialInventoryComponent")
    if not inv then return 0 end

    local total = 0
    for index, count in ipairs(ComponentGetValue2(inv, "count_per_material_type") or {}) do
        if count > 0 then
            local material_id = index - 1
            if CellFactory_GetName(material_id) == key then
                total = total + count
            else
                for _, tag in ipairs(CellFactory_GetTags(material_id)) do
                    if tag == key then
                        total = total + count
                        break
                    end
                end
            end
        end
    end
    return total
end

local function getQuantity(container_id, key, source)
    local main_id = GetMaterialInventoryMainMaterial(container_id)
    return {
        amount = I.getMaterialAmount(container_id, key),
        min    = MIN_AMOUNT[source] or 0,
        name   = GameTextGetTranslatedOrNot(CellFactory_GetUIName(main_id)),
        source = source,
    }
end

--- @param source string  I.SOURCE_FLASK | I.SOURCE_SUCK (seuil de quantité appliqué)
function I.tryCreateStone(potion_id, pos_x, pos_y, stone_id, infusable_id, entityName, source)
    local key = I.findMaterialKey(potion_id, entityName)
    if not key then return false end

    local hint_id = U.getVariable(infusable_id, "hintEnable")
    local hintCount = U.getValue(hint_id, "value_int", 1)

    local quantity = getQuantity(potion_id, key, source)
    local is_success = stone_factory.tryInfuseStone(entityName, key, hintCount, pos_x, pos_y, quantity)

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