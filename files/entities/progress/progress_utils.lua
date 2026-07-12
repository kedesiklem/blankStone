local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function resetProgress()
    local mod_progess_prefix = "blankstone_progress_"
    for k,_ in pairs(STONE_REGISTRY) do
        RemoveFlagPersistent(mod_progess_prefix .. k)
    end
    log.debug("RemoveFlagPersistent(blankstone_progress_*)")
end

return {
    reset = resetProgress
}