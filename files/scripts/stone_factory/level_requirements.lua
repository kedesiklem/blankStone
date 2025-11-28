local min_level = 1
local max_level = 20

local LEVEL_REQUIREMENTS_RAW = {
    [5] = {
        min_potion_count = 100,
    },
    [9] = {
        min_potion_count = 500,
        min_orb = 5,
    },
    [10] = {
        min_potion_count = 1000,
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

return LEVEL_REQUIREMENTS