local log = dofile_once("mods/blankStone/utils/logger.lua")

local min_level = 1
local max_level = 20

-- level -1 = impossible (use to give hint)
local LEVEL_REQUIREMENTS_RAW = {
    [5] = {
        min_orb = 1,
    },
    [7] = {
        min_orb = 3,
    },
    [9] = {
        min_orb = 5,
    },
    [10] = {
        min_orb = 11,
    },
    [11] = {
        pure_orb_only = true,
    }
}

local LEVEL_REQUIREMENTS = {}

function BuildCumulativeRequirements()
    local cumulative = {}
    
    -- Parcourir tous les levels possibles
    for level = min_level, max_level do
        local level_raw = LEVEL_REQUIREMENTS_RAW[level]
        
        if level_raw then
            -- Merger les nouvelles conditions
            for key, value in pairs(level_raw) do
                cumulative[key] = value
            end
        end
        
        -- Créer une copie profonde pour ce level
        LEVEL_REQUIREMENTS[level] = DeepCopy(cumulative)
    end
end

function DeepCopy(tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            copy[key] = DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end


-- Appeler à l'initialisation
BuildCumulativeRequirements()

local function checkLevelRequirements(level)

    if (level == -1) then return false end

    local all_requirements = LEVEL_REQUIREMENTS[level]

    local check = true

    if (not all_requirements) then return true end

    -- Orb count check
    local min_orb = all_requirements.min_orb or 0
    local np_orb = GameGetOrbCountThisRun()
    check = check and np_orb >= min_orb

    -- Purity check
    -- ID of Corrupted Orb in the west adds 128 to Main World's ID, and the ones in east adds 256
    local pure_orb_only = all_requirements.pure_orb_only or false
    if pure_orb_only and np_orb ~= 0 then
        local corrupted = false
        for i=0, 11 do 
            for _, j in ipairs({128, 256}) do
                corrupted = corrupted or GameGetOrbCollectedThisRun(i + j)
            end
        end
        if corrupted then
            GamePrintImportant("$text_blankstone_corrupt", "")
        end
        check = check and not(corrupted)
    end

    return check
end


return {
    LEVEL_REQUIREMENTS=LEVEL_REQUIREMENTS,
    checkLevelRequirements=checkLevelRequirements
}