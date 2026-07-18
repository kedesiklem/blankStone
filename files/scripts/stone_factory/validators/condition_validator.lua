local log      = dofile_once("mods/blankStone/utils/logger.lua")
local QUEST_ON = ModSettingGet("blankStone.quest_mod")

-- ---------------------------------------------------------------------------
-- Checks individuels
-- ---------------------------------------------------------------------------

local function checkPure()
    for i = 0, 11 do
        for _, flag_offset in ipairs({128, 256}) do
            if GameGetOrbCollectedThisRun(i + flag_offset) then
                return false
            end
        end
    end
    return true
end

local function checkFlags(flags_required)
    if not flags_required then return true end
    for _, flag in pairs(flags_required) do
        if flag.run or flag.persistent then
            local run_ok = flag.run and GameHasFlagRun(flag.run)
            local persistent_ok = flag.persistent and HasFlagPersistent(flag.persistent)

            if not run_ok and not persistent_ok then
                return false
            end
        end
        if flag.no_run and GameHasFlagRun(flag.no_run) then
            return false
        else
            log.debug("no no_flag restriction [" .. flag.no_run .. "]")
        end

    end
    return true
end

local function checkOrbs(orbs_required)
    if not QUEST_ON then return true end
    if not orbs_required then return true end
    return GameGetOrbCountThisRun() >= orbs_required
end

-- ---------------------------------------------------------------------------
-- Interface publique
-- ---------------------------------------------------------------------------

--- Valide une stone_data contre l'état du jeu.
---
--- @param stone_data table  Entrée normalisée du STONE_REGISTRY
--- @return table
---   {
---     ok      : bool,
---     reason  : nil | "orbs" | "purity" | "flags",
---     message : string
---   }
local function validate(stone_data)
    local conds = stone_data.conditions or {}

    local orbs_ok   = checkOrbs(conds.orbs)
    local purity_ok = not conds.purity or checkPure()
    local flags_ok  = checkFlags(conds.flags)

    log.debug(
        "validate [" .. tostring(stone_data.path) .. "]"
        .. " orbs=" .. tostring(orbs_ok)
        .. " purity=" .. tostring(purity_ok)
        .. " flags=" .. tostring(flags_ok)
    )

    if orbs_ok and purity_ok and flags_ok then
        return { ok = true, reason = nil, message = stone_data.message }
    end

    -- Priorité : purity > orbs > flags (ordre narratif du mod)
    local reason
    if not purity_ok then
        reason = "purity"
    elseif not orbs_ok then
        reason = "orbs"
    else
        reason = "flags"
    end

    return { ok = false, reason = reason, message = stone_data.message_fail }
end

return { validate = validate }