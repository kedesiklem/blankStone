local MOD_PATH = "mods/blankStone/"

local STONE_REGISTRY = dofile_once(MOD_PATH .. "files/scripts/stone_factory/stone_registry.lua")
local log             = dofile_once(MOD_PATH .. "utils/logger.lua") ---@type logger

local PROGRESS_PREFIX = "blankstone_progress_"
local HINT_PREFIX     = "blankstone_hint_"

-- Unlock : permanent, persiste entre les runs/parties
local function isUnlocked(stoneKey)
    return HasFlagPersistent(PROGRESS_PREFIX .. stoneKey)
end

local function unlock(stoneKey)
    if isUnlocked(stoneKey) then
        return false
    end
    AddFlagPersistent(PROGRESS_PREFIX .. stoneKey)
    log.debug("SetFlagPersistent(" .. PROGRESS_PREFIX .. stoneKey .. ")")
    return true
end

local function resetProgress()
    for k, _ in pairs(STONE_REGISTRY) do
        RemoveFlagPersistent(PROGRESS_PREFIX .. k)
    end
    log.debug("RemoveFlagPersistent(" .. PROGRESS_PREFIX .. "*)")
end

-- Hint : temporaire, non persistant, reflète le matériau actuellement tenu
local function isHinted(stoneKey)
    return GameHasFlagRun(HINT_PREFIX .. stoneKey)
end

local function setHint(stoneKey, active)
    local flag = HINT_PREFIX .. stoneKey
    local currently = GameHasFlagRun(flag)
    if active and not currently then
        GameAddFlagRun(flag)
    elseif not active and currently then
        GameRemoveFlagRun(flag)
    end
end

-- Active uniquement les hints donnés, désactive tous les autres
local function setActiveHints(activeStoneKeys)
    local activeSet = {}
    for _, k in ipairs(activeStoneKeys) do
        activeSet[k] = true
    end
    for k, _ in pairs(STONE_REGISTRY) do
        setHint(k, activeSet[k] == true)
    end
end

return {
    prefix = PROGRESS_PREFIX,
    isUnlocked = isUnlocked,
    unlock = unlock,
    reset = resetProgress,

    hintPrefix = HINT_PREFIX,
    isHinted = isHinted,
    setHint = setHint,
    setActiveHints = setActiveHints,
}