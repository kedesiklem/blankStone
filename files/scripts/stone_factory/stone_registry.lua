local elemental_stone_path =    "mods/blankStone/files/entities/elemental_stone/"
local vanilla_stone_path =      "data/entities/items/pickup/"

local function stone_mk(path, level, conditions)
    return {
        path = path,
        level = level,
        conditions = conditions or {}
    }
end

local STONE_REGISTRY = {

    -- Custom Stones

    ["toxicStone"] = stone_mk(
        elemental_stone_path .. "stone_toxic",
        1,
        { use_level_requirements = true }
    ),

    ["healthStone"] = stone_mk(
        elemental_stone_path .. "stone_health",
        11,
        {
            specific = {
                requires_catalyst = {
                    catalyst = "gold_nugget", 
                    amount = 3,
                },
            },
            use_level_requirements = true
        }
    ),

    ["ambrosiaStone"] = stone_mk(
        elemental_stone_path .. "stone_ambrosia",
        11,
        { use_level_requirements = true }
    ),

    ["loveStone"] = stone_mk(
        elemental_stone_path .. "stone_love",
        10,
        { use_level_requirements = true }
    ),
    
    -- Vanilla Stones

    ["brimstone"] = stone_mk(
        vanilla_stone_path .. "brimstone",
        1,
        { use_level_requirements = true }
    ),

    ["thunderstone"] = stone_mk(
        vanilla_stone_path .. "thunderstone",
        1,
        { use_level_requirements = true }
    ),

    ["stonestone"] = stone_mk(
        vanilla_stone_path .. "stonestone",
        5,
        { use_level_requirements = true }
    ),

    ["waterstone"] = stone_mk(
        vanilla_stone_path .. "waterstone",
        5,
        { use_level_requirements = true }
    ),

    ["poopstone"] = stone_mk(
        vanilla_stone_path .. "poopstone",
        5,
        { use_level_requirements = true }
    ),

    ["sunseed"] = stone_mk(
        vanilla_stone_path .. "sun/sunseed",
        9,
        { use_level_requirements = true }
    ),

    ["wandstone"] = stone_mk(
        vanilla_stone_path .. "wandstone",
        9,
        { use_level_requirements = true }
    ),
    
}

return STONE_REGISTRY