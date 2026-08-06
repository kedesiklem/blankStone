local pipeline      = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_pipeline.lua")
local infuseAct     = dofile_once("mods/blankStone/files/scripts/stone_factory/activation/infuse_activation.lua")
local forgeAct      = dofile_once("mods/blankStone/files/scripts/stone_factory/activation/forge_activation.lua")
local purifyAct     = dofile_once("mods/blankStone/files/scripts/stone_factory/activation/purify_activation.lua")
local forgeExec     = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/forge_executor.lua")
local purifyExec    = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/purify_executor.lua")
local spawnExec     = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/spawn_executor.lua")
local feedback      = dofile_once("mods/blankStone/files/scripts/stone_factory/feedback/game_feedback.lua")
local craft         = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local log           = dofile_once("mods/blankStone/utils/logger.lua")

-- =============================================================================
-- Public API
-- =============================================================================

--- Raw stone spawn (no VFX). Kept for external scripts.
--- For a spawn with VFX, use createStone.
--- @param stone_data table  STONE_REGISTRY entry (already normalized)
--- @param pos_x      number
--- @param pos_y      number
--- @return number  entity_id
local function spawnStone(stone_data, pos_x, pos_y)
    log.info("spawnStone: " .. stone_data.path)
    return spawnExec.spawnRaw(stone_data, pos_x, pos_y)
end

--- Spawn a stone with its VFX.
--- @param stone_data table
--- @param pos_x      number
--- @param pos_y      number
--- @return number  entity_id
local function createStone(stone_data, pos_x, pos_y)
    return spawnExec.spawnWithVFX(stone_data, pos_x, pos_y)
end

--- Attempts an infusion.
---
--- MIGRATION: the old signature took a pre-resolved stone_recipe.
--- The new signature takes stone_id + material directly.
--- The registry => recipe|hint resolution is now internal.
---
--- Hint rate-limiting (hintCount) stays the caller's responsibility:
--- pass hintCount = 0 to show the hint, > 0 to suppress it.
---
--- @param stone_id       string   Identifier of the carried stone (blankStoneID)
--- @param material_key   string   Noita material name
--- @param hintCount      number   Frame count since the last hint was shown
--- @param pos_x          number
--- @param pos_y          number
--- @return boolean
local function tryInfuseStone(stone_id, material_key, hintCount, pos_x, pos_y)
    local resolved = infuseAct.resolve(stone_id, material_key)
    if not resolved then return false end

    if resolved.type == "hint" then
        if hintCount == 0 then
            if resolved.data then feedback.onHint(resolved.data, pos_x, pos_y) end
        end
        return false
    end

    local result = pipeline.runInfuse(resolved.stone_keys, hintCount, pos_x, pos_y)

    return result
end

--- Attempts every Fuse recipe in declaration order.
--- @param cx number
--- @param cy number
--- @return boolean
local function tryAllFuse(cx, cy)
    return pipeline.tryAllFuse(craft.FUSE_RECIPES, cx, cy)
end

--- Attempts a Forge recipe on a specific entity.
--- @param entity_id number  Entity placed on the forge
--- @param x         number
--- @param y         number
--- @return boolean
local function forgeStone(entity_id, x, y)
    local recipe = forgeAct.resolve(entity_id)
    if not recipe then return false end

    local ok = forgeExec.execute(recipe, x, y)
    if ok then
        feedback.onRecipeSuccess(recipe)
    end
    return ok
end

--- Attempts to purify a specific entity, driven entirely by its own
--- "purifyInto" VariableStorageComponent (see purify_activation.lua).
---
--- Two outcomes, resolved by purify_activation:
---   - "stone"  : validated and spawned through purify_executor
---                (same validate/VFX/progress-unlock path as Infuse).
---   - "recipe" : a forge-style recipe (spells/items), executed by
---                forge_executor directly -- this is what lets a stone
---                purify into a spell, the same way Forge already can.
---
--- @param entity_id number  Entity carrying "purifyInto"
--- @param x         number
--- @param y         number
--- @return boolean  true if something was actually produced
local function purifyStone(entity_id, x, y)
    local resolved = purifyAct.resolve(entity_id)

    if resolved.type == "recipe" then
        local ok = forgeExec.execute(resolved.recipe, x, y)
        if ok then
            feedback.onRecipeSuccess(resolved.recipe)
        end
        return ok
    end

    return purifyExec.execute(resolved.stone_data, x, y)
end

return {
    spawnStone     = spawnStone,
    createStone    = createStone,
    tryInfuseStone = tryInfuseStone,
    tryAllFuse     = tryAllFuse,
    forgeStone     = forgeStone,
    purifyStone    = purifyStone,
}
