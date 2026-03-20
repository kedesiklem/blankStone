-- Mapping material to keys in STONE_REGISTRY for infusion
local STONE_TO_MATERIAL_TO_STONE = {
    ["blankStone"] = {

        -- Vanilla Stones --
        -------------------------
        ["[hot]"] = {stone_keys = {"brimstone"}},
        ["diamond"] = {stone_keys = {"thunderstone"}},
        ["spark_electric"] = {stone_keys = {"thunderstone"}},
        ["rock_static"] = {stone_keys = {"stonestone"}},
        ["[grows_grass]"] = {stone_keys = {"stonestone"}},
        ["water"] = {stone_keys = {"waterstone"}},
        ["poo"] = {stone_keys = {"poopstone"}},
        ["blood_worm"] = {stone_keys = {"wormBloodStone"}},
        ["magic_liquid_mana_regeneration"] = {stone_keys = {"wandstone"}},
        ["[gold]"] = {stone_keys = {"shinyOrb"}},
        ["cheese_static"] = {stone_keys = {"moon"}},
        -------------------------
        
        ["[radioactive]"] = {stone_keys = {"toxicStone"}},
        ["magic_liquid_invisibility"] = {stone_keys = {"invisibilityStone"}},
        ["magic_liquid_berserk"] = {stone_keys = {"bigStone"}},
        ["magic_liquid_faster_levitation"] = {stone_keys = {"levitatiumStone"}},
        ["magic_liquid_movement_faster"] = {stone_keys = {"acceleratiumStone"}},
        ["magic_liquid_faster_levitation_and_movement"] = {stone_keys = {"hasteStone"}},
        ["plasma_fading"] = {stone_keys = {"magicLiquidStone"}},
        ["plasma_fading_bright"] = {stone_keys = {"magicLiquidStone"}},
        ["plasma_fading_green"] = {stone_keys = {"magicLiquidStone"}},
        ["plasma_fading_pink"] = {stone_keys = {"magicLiquidStone"}},
        ["magic_liquid_unstable_teleportation"] = {stone_keys = {"unstableTeleportStone"}},
        ["magic_gas_midas"] = {stone_keys = {"goldStone"}},
        ["midas"] = {stone_keys = {"goldStone"}},
        ["bone"] = {stone_keys = {"bonesStone"}},
        ["poison"] = {stone_keys = {"poisonHarmfulStone"}},
        ["[slime]"] = {stone_keys = {"slimeStone"}},

        ["gunpowder_explosive"] = {stone_keys = {"gunpowderStone"}},
        ["gunpowder_tnt"] = {stone_keys = {"gunpowderStone"}},
        ["gunpowder"] = {stone_keys = {"gunpowderStone"}},
        ["gunpowder_unstable"] = {stone_keys = {"gunpowderStone"}},
        ["gunpowder_unstable_big"] = {stone_keys = {"gunpowderStone"}},
        
        ["alcohol"] = {stone_keys = {"whiskeyStone"}},
        ["alcohol_gas"] = {stone_keys = {"whiskeyStone"}},
        ["juhannussima"] = {stone_keys = {"whiskeyStone"}},
        ["beer"] = {stone_keys = {"whiskeyStone"}},

        ["urine"] = {stone_keys = {"urineStone"}},
        
        ["blood_cold"] = {stone_keys = {"freezeStone"}},
        ["blood_cold_vapour"] = {stone_keys = {"freezeStone"}},

        ["milk"] = {stone_keys = {"milkStone"}},
        ["material_confusion"] = {stone_keys = {"confuseStone"}},
        ["honey"] = {stone_keys = {"honeyStone"}},

        ["copper"] = {stone_keys = {"copperStone"}},
        ["copper_molten"] = {stone_keys = {"copperStone"}},

        ["brass"] = {stone_keys = {"brassStone"}},
        ["brass_molten"] = {stone_keys = {"brassStone"}},
        ["orb_powder"] = {stone_keys = {"orbPowderStone"}},
        ["sodium"] = {stone_keys = {"sodiumStone"}},
        ["magic_gas_weakness"] = {stone_keys = {"diminutionStone"}},
        ["magic_liquid_weakness"] = {stone_keys = {"diminutionStone"}},
        ["cement"] = {stone_keys = {"cementStone"}},
        -- HINT (not recipes)

        ["void_liquid"] = {stone_keys = {"voidStone"}},
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
    ["milkStone"] = {
        ["meat_helpless"] = {stone_keys = {"moon"}},
        ["salt"] = {stone_keys = {"moon"}},
        ["grass"] = {stone_keys = {"moon"}},
    },
    ["slimeStone"] = {
        ["[magic_faster]"] = {stone_keys = {"explosionStone"}},
    },

    ["teleportStone"] = {
        ["[slime]"] = {stone_keys = {"trueTeleportStone"}},
    },
    ["hasteStone"] = {
        ["[slime]"] = {stone_keys = {"explosionStone"}},
    },
    ["levitatiumStone"] = {
        ["magic_liquid_movement_faster"] = {stone_keys = {"hasteStone"}},
        ["[slime]"] = {stone_keys = {"explosionStone"}},
    },
    ["acceleratiumStone"] = {
        ["magic_liquid_faster_levitation"] = {stone_keys = {"hasteStone"}},
        ["[slime]"] = {stone_keys = {"explosionStone"}},
    },
    ["bigStone"] = {
        ["material_confusion"] = {stone_keys = {"loveStone"}},
    },

    ["quintessence"] = {
        ["[blood]"] = {stone_keys = {"bloodStone"}},
        ["[regenerative]"] = {stone_keys = {"healthStone"}},
        ["[regenerative_gas]"] = {stone_keys = {"healthStone"}},
        ["[magic_polymorph]"] = {stone_keys = {"polyStone"}},
    },
    
    ["copperStone"] = {
        ["magic_liquid_teleportation"] = {stone_keys = {"brassStone"}},
    },
    ["unstableTeleportStone"] = {
        ["material_confusion"] = {stone_keys = {"orbPowderStone"}},
    },
    ["confuseStone"] = {
        ["magic_liquid_unstable_teleportation"] = {stone_keys = {"orbPowderStone"}},
    },
    ["sodiumStone"] = {
        ["water"] = {stone_keys = {"explosionStone"}},
    },
    -- ##ANCHOR_INFUSE_END##
}

return STONE_TO_MATERIAL_TO_STONE
