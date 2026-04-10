local FORGE_RECIPES = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry/forge_registry.lua")
local utils         = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log           = dofile_once("mods/blankStone/utils/logger.lua")

--- Résout un entity_id en recette Forge.
--- @param entity_id number
--- @return table|nil  Recette Forge ou nil si aucun match
local function resolve(entity_id)
    local identifier = utils.getEntityIdentifier(entity_id)
    if not identifier then
        log.debug("forge_activation: pas d'identifiant pour entity " .. tostring(entity_id))
        return nil
    end
    return FORGE_RECIPES[identifier]
end

return { resolve = resolve }
