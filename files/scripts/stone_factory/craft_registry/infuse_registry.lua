-- Mapping material to keys in STONE_REGISTRY for infusion
local STONE_TO_MATERIAL_TO_STONE = {
    ["blankStone"] = {
        -- Vanilla Stones --
        -------------------------
        ["[hot]"] = {stone_key = "brimstone"},
        ["diamond"] = {stone_key = "thunderstone"},
        ["spark_electric"] = {stone_key = "thunderstone"},
        ["rock_static"] = {stone_key = "stonestone"},
        ["[grows_grass]"] = {stone_key = "stonestone"},
        ["water"] = {stone_key = "waterstone"},
        ["poo"] = {stone_key = "poopstone"},
        ["blood_worm"] = {stone_key = "wormBloodStone"},
        ["magic_liquid_mana_regeneration"] = {stone_key = "wandstone"},
        ["[gold]"] = {stone_key = "shinyOrb"},
        -------------------------
        
        ["[radioactive]"] = {stone_key = "toxicStone"},
        ["magic_liquid_invisibility"] = {stone_key = "invisibilityStone"},
        ["magic_liquid_berserk"] = {stone_key = "bigStone"},
        ["magic_liquid_faster_levitation"] = {stone_key = "levitatiumStone"},
        ["magic_liquid_movement_faster"] = {stone_key = "acceleratiumStone"},
        ["magic_liquid_faster_levitation_and_movement"] = {stone_key = "hasteStone"},
        ["plasma_fading"] = {stone_key = "magicLiquidStone"},
        ["plasma_fading_bright"] = {stone_key = "magicLiquidStone"},
        ["plasma_fading_green"] = {stone_key = "magicLiquidStone"},
        ["plasma_fading_pink"] = {stone_key = "magicLiquidStone"},
        ["magic_liquid_unstable_teleportation"] = {stone_key = "unstableTeleportStone"},
        ["magic_gas_midas"] = {stone_key = "goldStone"},
        ["midas"] = {stone_key = "goldStone"},
        ["bone"] = {stone_key = "bonesStone"},
        ["poison"] = {stone_key = "poisonHarmfulStone"},
        ["[slime]"] = {stone_key = "slimeStone"},

        ["gunpowder_explosive"] = {stone_key = "gunponwderStone"},
        ["gunpowder_tnt"] = {stone_key = "gunponwderStone"},
        ["gunpowder"] = {stone_key = "gunponwderStone"},
        ["gunpowder_unstable"] = {stone_key = "gunponwderStone"},
        ["gunpowder_unstable_big"] = {stone_key = "gunponwderStone"},
        
        ["alcohol"] = {stone_key = "whiskeyStone"},
        ["alcohol_gas"] = {stone_key = "whiskeyStone"},
        ["juhannussima"] = {stone_key = "whiskeyStone"},
        ["beer"] = {stone_key = "whiskeyStone"},

        ["urine"] = {stone_key = "urineStone"},
        
        ["blood_cold"] = {stone_key = "freezeStone"},
        ["blood_cold_vapour"] = {stone_key = "freezeStone"},

        ["milk"] = {stone_key = "milkStone"},
        ["material_confusion"] = {stone_key = "confuseStone"},
        ["honey"] = {stone_key = "honeyStone"},

        -- HINT (not recipes)

        ["void_liquid"] = {stone_key = "voidStone"},
        ["magic_liquid_teleportation"] = {hint_key = "hint_blankstone_teleport"},
        ["lava"] = {hint_key = "hint_blankstone_skipping_step"},
        ["magic_liquid_charm"] = {hint_key = "hint_blankstone_skipping_step"},


        ["acid"] = {hint_key = "hint_blankstone_useless"},
        ["oil"] = {hint_key = "hint_blankstone_useless"},

        ["[blood]"] = {hint_key = "hint_quintessence_base"},
        ["[regenerative]"] = {hint_key = "hint_quintessence_base"},
        ["[regenerative_gas]"] = {hint_key = "hint_quintessence_base"},
        ["[magic_polymorph]"] = {hint_key = "hint_quintessence_base"},

    },

    ["slimeStone"] = {
        ["[magic_faster]"] = {stone_key = "explosionStone"},
    },

    ["teleportStone"] = {
        ["[slime]"] = {stone_key = "trueTeleportStone"},
    },
    ["hasteStone"] = {
        ["[slime]"] = {stone_key = "explosionStone"},
    },
    ["levitatiumStone"] = {
        ["magic_liquid_movement_faster"] = {stone_key = "hasteStone"},
        ["[slime]"] = {stone_key = "explosionStone"},
    },
    ["acceleratiumStone"] = {
        ["magic_liquid_faster_levitation"] = {stone_key = "hasteStone"},
        ["[slime]"] = {stone_key = "explosionStone"},
    },
    ["bigStone"] = {
        ["material_confusion"] = {stone_key = "loveStone"},
    },

    ["quintessence"] = {
        ["[blood]"] = {stone_key = "bloodStone"},
        ["[regenerative]"] = {stone_key = "healthStone"},
        ["[regenerative_gas]"] = {stone_key = "healthStone"},
        ["[magic_polymorph]"] = {stone_key = "polyStone"},
    },
}

return STONE_TO_MATERIAL_TO_STONE