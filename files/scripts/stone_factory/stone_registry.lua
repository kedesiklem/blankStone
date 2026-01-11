local blankStone_path = "mods/blankStone/files/entities/"
local elemental_stone_path = blankStone_path .. "elemental_stone/"
local opus_magnum_path = blankStone_path .. "opus_magnum/"

local vanilla_stone_path = "data/entities/items/pickup/"

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

-- TODO move text to translation.csv
local STONE_REGISTRY = {

    ["blankStone"] = stone_mk(
        blankStone_path .. "blank_stone",
        0
    ),

    -- Custom Stones
    ["lapis_philosophorum"] = stone_mk(
        opus_magnum_path .. "lapis_philosophorum",
        34,
       "The Gods applaud you. You have achieved the Opus Magnum.",
        "The ultimate transmutation requires absolute perfection.",
        {
            "data/entities/projectiles/deck/explosion_giga.xml",
            "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml"
        }
    ),

    ["nigredo"]= stone_mk(
        opus_magnum_path .. "nigredo",
        5,
        "$text_blankstone_nigredo_success_craft",
        "$text_blankstone_nigredo_fail_craft",
        {
            "data/entities/projectiles/explosion.xml",
            "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml"
        }
    ),
    ["albedo"]= stone_mk(
        opus_magnum_path .. "albedo",
        7,
        "$text_blankstone_albedo_success_craft",
        "$text_blankstone_albedo_fail_craft",
        {
            "data/entities/projectiles/explosion.xml",
            "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml"
        }
    ),
    ["citrinitas"]= stone_mk(
        opus_magnum_path .. "citrinitas",
        9,
        "$text_blankstone_citrinitas_success_craft",
        "$text_blankstone_citrinitas_fail_craft",
        {
            "data/entities/projectiles/explosion.xml",
            "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml"
        }
    ),
    ["rubedo"]= stone_mk(
        opus_magnum_path .. "rubedo",
        9,
        "$text_blankstone_rubedo_success_craft",
        "$text_blankstone_rubedo_fail_craft",
        {
            "data/entities/projectiles/explosion.xml",
            "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml"
        }
    ),

    ["quintessence"] = stone_mk(
        blankStone_path .. "quintessence_stone",
        7,
        "$text_blankstone_quintessence_unleash_title",
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

    ["magicLiquidStone"] = stone_mk(
        elemental_stone_path .. "stone_magic_liquid",
        1
    ),
    ["lavaStone"] = stone_mk(
        elemental_stone_path .. "stone_lava",
        9,
        "Phoenix",
        "You're not ready."
    ),
    ["bloodStone"] = stone_mk(
        elemental_stone_path .. "stone_blood",
        9,
        "Blood! Blood! Blood!",
        "You're not ready."
    ),

    ["unstableTeleportStone"] = stone_mk(
        elemental_stone_path .. "stone_unstable_teleport",
        1
    ),
    ["teleportStone"] = stone_mk(
        elemental_stone_path .. "stone_teleport",
        5,
        nil,
        "$text_blankstone_missing_knowledge."
    ),
    ["toxicStone"] = stone_mk(
        elemental_stone_path .. "stone_toxic",
        1
    ),

    ["poisonStone"] = stone_mk(
        elemental_stone_path .. "stone_poison",
        7,
        nil,
        "$text_blankstone_missing_lot_knowledge."
    ),

    ["poisonHarmfulStone"] = stone_mk(
        elemental_stone_path .. "stone_poison_harmful",
        1
    ),

    ["bigStone"] = stone_mk(
        elemental_stone_path .. "stone_big",
        1
    ),
    ["honeyStone"] = stone_mk(
        elemental_stone_path .. "stone_honey",
        1
    ),
    ["invisibilityStone"] = stone_mk(
        elemental_stone_path .. "stone_invisibility",
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
        5,
        nil,
        "$text_blankstone_missing_knowledge."
    ),

    ["explosionStone"] = stone_mk(
        elemental_stone_path .. "stone_explosion",
        5,
        nil,
        "$text_blankstone_missing_lot_knowledge."
    ),

    ["polyStone"] = stone_mk(
        elemental_stone_path .. "stone_poly",
        11,
        "$text_blankstone_poly_success_craft",
        "$text_blankstone_poly_fail_craft"
    ),
 
    ["healthStone"] = stone_mk(
        elemental_stone_path .. "stone_health",
        11,
        "The Gods are pleased.",
        "$text_blankstone_missing_all_knowledge"
    ),

    ["ambrosiaStone"] = stone_mk(
        elemental_stone_path .. "stone_ambrosia",
        11,
        nil,
        "$text_blankstone_missing_all_knowledge"
    ),

    ["loveStone"] = stone_mk(
        elemental_stone_path .. "stone_love",
        10,
        "You created love.",
        "You need all the knowledge."
    ),

    ["bonesStone"] = stone_mk(
        elemental_stone_path .. "stone_bones",
        7,
        "I am steve.",
        "The Gods are not ready to let you have it."
    ),

    ["whiskeyStone"] = stone_mk(
        elemental_stone_path .. "stone_whiskey",
        1,
        "...",
        "Why would you do that ?"
    ),
    ["manaStone"] = stone_mk(
        elemental_stone_path .. "stone_mana",
        9
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
        "$text_blankstone_missing_knowledge."
    ),

    ["waterstone"] = stone_mk(
        vanilla_stone_path .. "waterstone",
        5,
        nil,
        "$text_blankstone_missing_knowledge."
    ),

    ["poopstone"] = stone_mk(
        vanilla_stone_path .. "poopstone",
        5,
        nil,
        "$text_blankstone_missing_knowledge."
    ),

    ["sunseed"] = stone_mk(
        vanilla_stone_path .. "sun/sunseed",
        9,
        nil,
        "$text_blankstone_missing_lot_knowledge."
    ),

    ["wandstone"] = stone_mk(
        vanilla_stone_path .. "wandstone",
        9,
        nil,
        "$text_blankstone_missing_lot_knowledge."
    ),
}

return STONE_REGISTRY