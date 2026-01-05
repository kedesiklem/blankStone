-- Mapping material to keys in STONE_REGISTRY for infusion
local STONE_TO_MATERIAL_TO_STONE = {
    ["blankStone"] = {
        -- Vanilla Stones --
        -------------------------
        ["[hot]"] = "brimstone",
        ["diamond"] =           "thunderstone",
        ["spark_electric"] =    "thunderstone",
        ["rock_static"] = "stonestone",
        ["[grows_grass]"] = "stonestone",
        ["water"] = "waterstone",
        ["poo"] = "poopstone",
        ["blood_worm"] = "sunseed",
        ["magic_liquid_mana_regeneration"] = "wandstone",
        -------------------------
        
        ["[radioactive]"] = "toxicStone",
        ["poison"] = "poisonStone",
        ["magic_liquid_berserk"] = "bigStone",
        ["magic_liquid_faster_levitation"] = "levitatiumStone",
        ["magic_liquid_movement_faster"] = "acceleratiumStone",
        ["magic_liquid_faster_levitation_and_movement"] = "hasteStone",
        ["plasma_fading"] = "magicLiquidStone",
        ["plasma_fading_bright"] = "magicLiquidStone",
        ["plasma_fading_green"] = "magicLiquidStone",
        ["plasma_fading_pink"] = "magicLiquidStone",
        ["magic_liquid_unstable_teleportation"] = "unstableTeleportStone",
        ["magic_gas_midas"] = "goldStone",
        ["midas"] = "goldStone",
        ["bone"] = "bonesStone",

        ["alcohol"] = "whiskeyStone",
        ["alcohol_gas"] = "whiskeyStone",
        ["juhannussima"] = "whiskeyStone",
        ["beer"] = "whiskeyStone",
        
    },
    ["unstableTeleportStone"] = {
        ["[slime]"] = "teleportStone",
    },
    ["hasteStone"] = {
        ["[slime]"] = "explosionStone",
    },
    ["levitatiumStone"] = {
        ["magic_liquid_movement_faster"] = "hasteStone",
        ["[slime]"] = "explosionStone",
    },
    ["acceleratiumStone"] = {
        ["magic_liquid_faster_levitation"] = "hasteStone",
        ["[slime]"] = "explosionStone",
    },
    ["bigStone"] = {
        ["material_confusion"] = "loveStone",
    },

    ["quintessence"] = {
        ["[blood]"] = "bloodStone",
        ["[regenerative]"] = "healthStone",
        ["[regenerative_gas]"] = "healthStone",
        ["magic_liquid_protection_all"] = "ambrosiaStone",
        ["[magic_polymorph]"] = "polyStone",
        ["void_liquid"] = "nigredo",
    },

    -- Chemin vers le Grand OEuvre

    ["nigredo"] = {
        ["milk"] = "albedo",
    },
    ["albedo"] = {
        ["[gold]"] = "citrinitas",
    },
    ["citrinitas"] = {
        ["material_confusion"] = "rubedo",
    },
    ["rubedo"] = {
        ["material_rainbow"] = "lapis_philosophorum",
    },
}

-- Note : preferably use tags to identify ingredients if possible
local FUSE_RECIPIES = {
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
        -- Callback optionnel après craft réussi
        on_success = function() end
    },

    {
        ingredients = {
            { tag = "brimstone|stonestone|waterstone|thunderstone", count = 1 },
        },
        catalistes = {
            { name = "blankStone|albedo", count = 1 },
        },
        radius = 20,
        results = {
            { key = "blankStone", offset_y = -10 },

        },
        on_success = function() end
    },
}

local FORGE_RECIPIES = {
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
    FUSE_RECIPIES = FUSE_RECIPIES,
    FORGE_RECIPIES = FORGE_RECIPIES,
}