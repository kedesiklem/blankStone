local MOD_PATH = "mods/blankStone/"

local STONE_REGISTRY = dofile_once(MOD_PATH .. "files/scripts/stone_factory/stone_registry.lua")
local log             = dofile_once(MOD_PATH .. "utils/logger.lua") ---@type logger

local PROGRESS_PREFIX = "blankstone_progress_"

local HINT_ROLES = {
    input  = { material = "spark_red",   flagPrefix = "blankstone_hint_input_" },
    output = { material = "spark_green", flagPrefix = "blankstone_hint_output_" },
}

-- Material utilise quand input ET output sont actifs en meme temps sur une stone
local HINT_BOTH_MATERIAL = "spark_yellow"

-- Material par defaut pose sur l'emitter a sa creation (avant tout hint reel)

-- Unlock : permanent, persiste entre les runs/parties
local function isUnlock(stoneKey)
    return HasFlagPersistent(PROGRESS_PREFIX .. stoneKey)
end

local function unlock(stoneKey)
    if isUnlock(stoneKey) then
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
    RemoveFlagPersistent("blankstone_unlock_portal")
    log.debug("RemoveFlagPersistent(" .. PROGRESS_PREFIX .. "*)")
end

-- Hint : temporaire, non persistant, reflete le materiau actuellement tenu
local function isHinted(role, stoneKey)
    local roleDef = HINT_ROLES[role]
    if not roleDef then return false end
    return GameHasFlagRun(roleDef.flagPrefix .. stoneKey)
end

local function setHint(role, stoneKey, active)
    local roleDef = HINT_ROLES[role]
    if not roleDef then return end
    local flag = roleDef.flagPrefix .. stoneKey
    local currently = GameHasFlagRun(flag)
    if active and not currently then
        GameAddFlagRun(flag)
    elseif not active and currently then
        GameRemoveFlagRun(flag)
    end
end

-- activeByRole = { input = {key1, key2, ...}, output = {key3, ...} }
local function setActiveHints(activeByRole)
    for role, _ in pairs(HINT_ROLES) do
        local activeSet = {}
        for _, k in ipairs(activeByRole[role] or {}) do
            activeSet[k] = true
        end
        for k, _ in pairs(STONE_REGISTRY) do
            setHint(role, k, activeSet[k] == true)
        end
    end
end

-- Renvoie le material a appliquer sur l'unique emitter d'une stone,
-- ou nil si aucun role n'est actif (emitter a desactiver)
local function getHintMaterial(stoneKey)
    local activeRoles = {}
    for role, _ in pairs(HINT_ROLES) do
        if isHinted(role, stoneKey) then
            table.insert(activeRoles, role)
        end
    end

    if #activeRoles == 0 then
        return nil
    elseif #activeRoles > 1 then
        return HINT_BOTH_MATERIAL
    else
        return HINT_ROLES[activeRoles[1]].material
    end
end

return {
    prefix = PROGRESS_PREFIX,
    isUnlock = isUnlock,
    unlock = unlock,
    reset = resetProgress,

    HINT_ROLES = HINT_ROLES,
    HINT_BOTH_MATERIAL = HINT_BOTH_MATERIAL,
    isHinted = isHinted,
    setHint = setHint,
    setActiveHints = setActiveHints,
    getHintMaterial = getHintMaterial,
}