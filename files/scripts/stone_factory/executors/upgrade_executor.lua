local log     = dofile_once("mods/blankStone/utils/logger.lua")

local UPGRADE_COMP = "blankStoneUpgraded"

-- ---------------------------------------------------------------------------
-- Helpers internes — marquage upgrade
-- ---------------------------------------------------------------------------

local function isUpgraded(entity_id)
    local comps = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    if not comps then return false end
    for _, c in ipairs(comps) do
        if ComponentGetValue2(c, "name") == UPGRADE_COMP then
            return ComponentGetValue2(c, "value_bool")
        end
    end
    return false
end

local function markUpgraded(entity_id)
    EntityAddComponent2(entity_id, "VariableStorageComponent", {
        name       = UPGRADE_COMP,
        value_bool = true,
    })
end

-- ---------------------------------------------------------------------------
-- Interface publique
-- ---------------------------------------------------------------------------

--- Applique l'effet d'upgrade sur les entités éligibles des ingrédients.
--- Ne retraite pas une entité déjà upgradée.
---
--- @param recipe table   Recette avec effect.apply (function(entity_id))
--- @param ctx    table   { ingredients = {{id,...},...}, catalysts = {...} }
--- @return table|nil     Liste des entités upgradées, ou nil si aucun upgrade
local function execute(recipe, ctx)
    local apply = recipe.effect.apply
    if not apply then
        log.error("upgrade_executor: recipe.effect.apply est nil")
        return nil
    end

    local upgraded = {}
    for _, entity_id in ipairs(ctx.ingredients[1]) do
        if not isUpgraded(entity_id) then
            apply(entity_id)
            markUpgraded(entity_id)
            table.insert(upgraded, entity_id)
        end
    end

    if #upgraded == 0 then
        log.debug("upgrade_executor: toutes les entités sont déjà upgradées")
        return nil
    end

    return upgraded
end

return { execute = execute }
