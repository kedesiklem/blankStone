local log = dofile_once("mods/blankStone/utils/logger.lua")

local function isPure()
    local corrupted = false
    for i=0, 11 do 
        for _, j in ipairs({128, 256}) do
            corrupted = corrupted or GameGetOrbCollectedThisRun(i + j)
            
        end
    end
    return not(corrupted)
end

local function checkFlagRequirements(flags_required)
    if not flags_required then return true end

    for _, flag in pairs(flags_required) do
        if not GameHasFlagRun(flag.run) then
            if not HasFlagPersistent( flag.persistant ) then
                return false
            end
        end

    end
    return true
end

local function checkOrbRequirements(orb_required)
    if not orb_required then return true end

    -- Orb count check
    local np_orb = GameGetOrbCountThisRun()
    return np_orb >= orb_required
end

local function checkPurityRequirements(purity_required)
    if not purity_required then return true end
    return isPure()
end

local function checkRequirements(stone_data)
    local orbs_check = checkOrbRequirements(stone_data.conditions.orbs)
    local purity_check = checkPurityRequirements(stone_data.conditions.purity)
    local flags_check = checkFlagRequirements(stone_data.conditions.flags)

    local full_check = orbs_check and purity_check and flags_check

    log.debug("Check result : orb[".. tostring(orbs_check) .. "] purity[" ..tostring(purity_check) .. "] flags["..tostring(flags_check) .."]")

    local message = stone_data.message_fail
    if full_check then message = stone_data.message end

    return full_check, message, purity_check
end

return {
    checkOrbRequirements=checkOrbRequirements,
    checkPurityRequirements=checkPurityRequirements,
    checkFlagRequirements=checkFlagRequirements,
    checkRequirements=checkRequirements,
}