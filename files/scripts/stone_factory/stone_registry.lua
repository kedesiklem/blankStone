local blankStone_path = "mods/blankStone/files/entities/"
local elemental_stone_path = blankStone_path .. "elemental_stone/"
local vanilla_stone_path =      "data/entities/items/pickup/"

local function stone_mk(path, level, message, message_fail ,vfx, conditions)
    return {
        path = path .. ".xml",
        level = level,
        message = message or "You've done something...",
        message_fail = message_fail or "Something's wrong",
        vfx = vfx or {"data/entities/projectiles/explosion.xml"},
        conditions = conditions or { use_level_requirements = true },
    }
end

local STONE_REGISTRY = {

    -- Custom Stones
    ["quintessence"] = stone_mk(
        blankStone_path .. "quintessence_stone",
        11,
        "The Gods can't hide it anymore.",
        nil,
        {
            "data/entities/projectiles/deck/explosion_giga.xml",
            "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml"
        }
    ),
    ["goldStone"] = stone_mk(
        elemental_stone_path .. "stone_gold",
        5,
        "The Gods pity you.",
        "The Gods warn you not to do that."
    ),
    ["unstableTeleportStone"] = stone_mk(
        elemental_stone_path .. "stone_unstable_teleport",
        1
    ),
    ["teleportStone"] = stone_mk(
        elemental_stone_path .. "stone_teleport",
        5,
        nil,
        "You need more knowledge."
    ),
    ["toxicStone"] = stone_mk(
        elemental_stone_path .. "stone_toxic",
        1
    ),

    ["bigStone"] = stone_mk(
        elemental_stone_path .. "stone_big",
        1
    ),
 
    ["acceleratiumStone"] = stone_mk(
        elemental_stone_path .. "stone_acceleratium",
        1
    ),
    ["levitatiumStone"] = stone_mk(
        elemental_stone_path .. "stone_levitatium",
        1
    ),
    ["hasteStone"] = stone_mk(
        elemental_stone_path .. "stone_haste",
        5
    ),

    ["explosionStone"] = stone_mk(
        elemental_stone_path .. "stone_explosion",
        5
    ),

    ["polyStone"] = stone_mk(
        elemental_stone_path .. "stone_poly",
        11,
        "The Gods fear this.",
        "The Gods are afraid of what you're trying to do"
    ),
 
    ["healthStone"] = stone_mk(
        elemental_stone_path .. "stone_health",
        11,
        "The Gods are pleased."
    ),

    ["ambrosiaStone"] = stone_mk(
        elemental_stone_path .. "stone_ambrosia",
        11
    ),

    ["loveStone"] = stone_mk(
        elemental_stone_path .. "stone_love",
        10,
        nil,
        "You need more knowledge."
    ),
    
    -- Vanilla Stones

    ["brimstone"] = stone_mk(
        vanilla_stone_path .. "brimstone",
        1
    ),

    ["thunderstone"] = stone_mk(
        vanilla_stone_path .. "thunderstone",
        1
    ),

    ["stonestone"] = stone_mk(
        vanilla_stone_path .. "stonestone",
        5,
        nil,
        "You need more knowledge."
    ),

    ["waterstone"] = stone_mk(
        vanilla_stone_path .. "waterstone",
        5,
        nil,
        "You need more knowledge."
    ),

    ["poopstone"] = stone_mk(
        vanilla_stone_path .. "poopstone",
        5,
        nil,
        "You need more knowledge."
    ),

    ["sunseed"] = stone_mk(
        vanilla_stone_path .. "sun/sunseed",
        9
    ),

    ["wandstone"] = stone_mk(
        vanilla_stone_path .. "wandstone",
        9,
        nil,
        "You need far more knowledge."
    ),
}

return STONE_REGISTRY