local STONE_REGISTRY  = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local craft           = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local utils            = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log              = dofile_once("mods/blankStone/utils/logger.lua")

local PURIFY_RECIPES = craft.PURIFY_RECIPES

local DEFAULT_STONE_KEY = "blankStone"

-- Sanity check at load time: warn if a purify_registry entry is shadowed by
-- a same-named STONE_REGISTRY key, since resolve() always checks stones
-- first. This is meant to catch a copy-paste mistake early, in the log,
-- instead of leaving a silently-ignored recipe in purify_registry.lua.
for identifier, _ in pairs(PURIFY_RECIPES) do
    if STONE_REGISTRY[identifier] then
        log.warn(
            "purify_activation: \"" .. identifier .. "\" exists in both STONE_REGISTRY "
            .. "and PURIFY_RECIPES -- the stone will always win, the purify_registry entry is dead code"
        )
    end
end

--- Resolves an entity's "purifyInto" variable into something purifyStone
--- can execute.
---
--- Resolution order:
---   1. STONE_REGISTRY[identifier]  -> plain stone spawn (common case)
---   2. PURIFY_RECIPES[identifier]  -> forge-style recipe (spells/items),
---      executed by forge_executor so purify and forge share one executor
---      for anything that isn't a stone.
---   3. Unknown identifier or missing variable -> DEFAULT_STONE_KEY,
---      with a warning (never silently guessed as a spell id).
---
--- @param entity_id number
--- @return table  { type = "stone", stone_data = table } | { type = "recipe", recipe = table }
local function resolve(entity_id)
    local var = utils.getVariable(entity_id, "purifyInto")
    local identifier = var and utils.getValue(var, "value_string")

    if not identifier then
        log.warn("purify_activation: missing \"purifyInto\" variable on entity " .. tostring(entity_id))
        identifier = DEFAULT_STONE_KEY
    end

    local stone_data = STONE_REGISTRY[identifier]
    if stone_data then
        return { type = "stone", stone_data = stone_data }
    end

    local recipe = PURIFY_RECIPES[identifier]
    if recipe then
        return { type = "recipe", recipe = recipe }
    end

    log.warn(
        "purify_activation: \"" .. tostring(identifier) .. "\" is neither a STONE_REGISTRY key "
        .. "nor a PURIFY_RECIPES entry, falling back to \"" .. DEFAULT_STONE_KEY .. "\""
    )
    return { type = "stone", stone_data = STONE_REGISTRY[DEFAULT_STONE_KEY] }
end

return { resolve = resolve }
