local STONE_REGISTRY  = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local craft           = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local utils            = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log              = dofile_once("mods/blankStone/utils/logger.lua")

local PURIFY_RECIPES = craft.PURIFY_RECIPES

local DEFAULT_STONE_KEY = "blankStone"

--- @param entity_id number
--- @return table  { type = "recipe", recipe = table }
local function resolve(entity_id)
    local identifier = utils.getEntityIdentifier(entity_id)
    local recipe = identifier and PURIFY_RECIPES[identifier]
    if recipe then
        return recipe
    end
    return {stone = {DEFAULT_STONE_KEY}}
end

return { resolve = resolve }
