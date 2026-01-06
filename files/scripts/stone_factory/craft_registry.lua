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
        ["blood_worm"] = {stone_key = "sunseed"},
        ["magic_liquid_mana_regeneration"] = {stone_key = "wandstone"},
        -------------------------
        
        ["[radioactive]"] = {stone_key = "toxicStone"},
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

        ["alcohol"] = {stone_key = "whiskeyStone"},
        ["alcohol_gas"] = {stone_key = "whiskeyStone"},
        ["juhannussima"] = {stone_key = "whiskeyStone"},
        ["beer"] = {stone_key = "whiskeyStone"},

        -- Should be an upgraded version of a stone (fuse with quintessence as catalist to upgrade)
        -- lava stone
        ["poison"] = {stone_key = "poisonStone"},

        ["void_liquid"] = {stone_key = "nigredo"},
        ["milk"] = {stone_key = "albedo"},
        ["material_confusion"] = {stone_key = "rubedo"},
        ["[gold]"] = {stone_key = "citrinitas"},

        
    },
    ["unstableTeleportStone"] = {
        ["[slime]"] = {stone_key = "teleportStone"},
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
        ["magic_liquid_protection_all"] = {stone_key = "ambrosiaStone"},
        ["[magic_polymorph]"] = {stone_key = "polyStone"},
    },
}

-- Note : preferably use tags to identify ingredients if possible
local FUSE_RECIPES = {
    {
        -- Ingrédients requis
        ingredients = {
            { tag = "brimstone", count = 1 },
            { tag = "thunderstone", count = 1 },
            { tag = "waterstone", count = 1 },
            { tag = "stonestone", count = 1 }
        },
        -- Rayon de détection
        radius = 20,
        -- Résultats à spawner (key for STONE_REGISTRY)
        results = {
            { key = "quintessence", offset_y = -10 },
        },
        message = {
            title = "$text_blankstone_quintessence_unleash_title",
            desc = "$text_blankstone_quintessence_unleash_desc",
        },
        -- Callback optionnel après craft réussi
        on_success = function() end
    },

    {
        ingredients = {
            { tag = "brimstone|stonestone|waterstone|thunderstone", count = 1 },
        },
        catalistes = {
            { name = "albedo", count = 1 },
        },
        radius = 20,
        results = {
            { key = "blankStone", offset_y = -10 },

        },
        on_success = function() end
    },
    
    {
        ingredients = {
            { tag = "nigredo", count = 1 },
            { tag = "albedo", count = 1 },
            { tag = "rubedo", count = 1 },
            { tag = "citrinitas", count = 1 },
        },
        catalistes = {
            { name = "quintessence", count = 1 },
        },
        radius = 20,
        results = {
            { key = "lapis_philosophorum", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_magnum_opus_title",
            desc = "$text_blankstone_magnum_opus_desc",
        },
        on_success = function() end
    },
}

local FORGE_RECIPES = {
    ["magicLiquidStone"] = {
        spells = {"BLANKSTONE_STONE_FUSER"},
        message = {
            title = "$text_blankstone_repair_broken_stone_title",
            desc = "$text_blankstone_repair_broken_stone_desc",
        }
    }
}

return {
    STONE_TO_MATERIAL_TO_STONE = STONE_TO_MATERIAL_TO_STONE,
    FUSE_RECIPES = FUSE_RECIPES,
    FORGE_RECIPES = FORGE_RECIPES,
}