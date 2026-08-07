local MOD_PATH = "mods/blankStone/"

local STONE_REGISTRY = dofile_once(MOD_PATH .. "files/scripts/stone_factory/stone_registry.lua")
local log             = dofile_once(MOD_PATH .. "utils/logger.lua") ---@type logger

local PROGRESS_PREFIX = "blankstone_progress_"

-- =============================================================================
-- Hint roles : one per (craft type x direction). Add/remove/reorder freely --
-- everything downstream (progress_hint.lua, progress_update.lua) reads this
-- table generically, no hardcoded role names anywhere else.
--
-- NOTE: material names below are placeholders, swap them for whatever you
-- want -- only the "spark_red"/"spark_green"/"spark_yellow" trio is known to
-- already work (used by the previous input/output/both system).
-- =============================================================================

local HINT_ROLES = {
    infuse_input  = { material = "spark_red",    flagPrefix = "blankstone_hint_infuse_input_" },
    infuse_output = { material = "spark_green",  flagPrefix = "blankstone_hint_infuse_output_" },

    forge_input   = { material = "spark_electric", flagPrefix = "blankstone_hint_forge_input_" },
    forge_output  = { material = "spark_yellow",   flagPrefix = "blankstone_hint_forge_output_" },

    fuse_input    = { material = "spark_blue_dark", flagPrefix = "blankstone_hint_fuse_input_" },
    fuse_catalyst = { material = "spark_blue_dark", flagPrefix = "blankstone_hint_fuse_catalyst_" },
    fuse_output   = { material = "spark_purple",   flagPrefix = "blankstone_hint_fuse_output_" },

    purify_input  = { material = "spark",  flagPrefix = "blankstone_hint_purify_input_" },
    purify_output = { material = "spark_white", flagPrefix = "blankstone_hint_purify_output_" },
}

-- Only ONE material can be shown per stone at a time: there is a single
-- particle emitter per stone (see progress_init.lua / progress_update.lua).
-- When several roles are active at once on the same stone, resolution goes:
--
--   1. HINT_COMBOS[exact active role-set] -- pin a specific blend color for
--      a specific combination of roles, if you want one.
--   2. HINT_PRIORITY -- otherwise, the earliest-listed active role wins.
--
-- Both are plain data: reorder/extend without touching any logic below.
-- =============================================================================

local HINT_PRIORITY = {
    "purify_output", "forge_output", "fuse_output", "infuse_output",
    "purify_input", "forge_input", "fuse_input", "fuse_catalyst", "infuse_input",
}

-- Example: keep the old "yellow when both infuse roles are active" behaviour.
-- Key = role names active at once, sorted alphabetically, joined with "+".
local HINT_COMBOS = {
    -- ["infuse_input+infuse_output"] = "spark_yellow",
}

-- =============================================================================
-- Unlock : permanent, persists across runs/games
-- =============================================================================

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

-- =============================================================================
-- Hint : temporary, non-persistent, reflects what's currently being carried
-- =============================================================================

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

-- activeByRole = { infuse_input = {key1, ...}, forge_output = {key2, ...}, ... }
-- Any role from HINT_ROLES not present in activeByRole is treated as empty.
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

-- Returns the material to apply on a stone's single emitter, or nil if no
-- role is active for it (emitter should be disabled).
local function getHintMaterial(stoneKey)
    local activeRoles = {}
    for role, _ in pairs(HINT_ROLES) do
        if isHinted(role, stoneKey) then
            table.insert(activeRoles, role)
        end
    end

    if #activeRoles == 0 then
        return nil
    end

    if #activeRoles > 1 then
        table.sort(activeRoles)
        local combo = HINT_COMBOS[table.concat(activeRoles, "+")]
        if combo then
            return combo
        end
    end

    for _, role in ipairs(HINT_PRIORITY) do
        for _, active in ipairs(activeRoles) do
            if active == role then
                return HINT_ROLES[role].material
            end
        end
    end

    -- Active role not listed in HINT_PRIORITY (forgotten entry): fall back
    -- to it directly rather than showing nothing.
    return HINT_ROLES[activeRoles[1]].material
end

return {
    prefix = PROGRESS_PREFIX,
    isUnlock = isUnlock,
    unlock = unlock,
    reset = resetProgress,

    HINT_ROLES = HINT_ROLES,
    HINT_PRIORITY = HINT_PRIORITY,
    HINT_COMBOS = HINT_COMBOS,
    isHinted = isHinted,
    setHint = setHint,
    setActiveHints = setActiveHints,
    getHintMaterial = getHintMaterial,
}
