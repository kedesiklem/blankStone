local validator = dofile_once("mods/blankStone/files/scripts/stone_factory/validators/condition_validator.lua")
local spawnExec = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/spawn_executor.lua")
local feedback  = dofile_once("mods/blankStone/files/scripts/stone_factory/feedback/game_feedback.lua")
local log       = dofile_once("mods/blankStone/utils/logger.lua")

--- Executes the "stone" branch of a purify resolution: validate against the
--- current run state, spawn with VFX (also unlocks the pool entry, see
--- spawn_executor.lua), run postprocess, and report success/failure.
---
--- The "recipe" branch (spells/items) does NOT go through here: it is
--- executed directly by forge_executor, see stone_factory.lua#purifyStone.
---
--- @param stone_data table  STONE_REGISTRY entry
--- @param x number
--- @param y number
--- @return boolean  true if the stone was actually spawned
local function execute(stone_data, x, y)
    stone_data = stone_data.preprocess(stone_data)
    local result = validator.validate(stone_data)

    if not result.ok then
        log.debug("purify_executor: validation failed for " .. tostring(stone_data.path))
        feedback.onValidationFail(result)
        return false
    end

    local stone_id = spawnExec.spawnWithVFX(stone_data, x, y)
    stone_data.postprocess(stone_id)
    feedback.onStoneSuccess(result.message)

    return true
end

return { execute = execute }
