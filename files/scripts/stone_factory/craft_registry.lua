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
        
        ["alcohol"] = {stone_key = "whiskeyStone"},
        ["alcohol_gas"] = {stone_key = "whiskeyStone"},
        ["juhannussima"] = {stone_key = "whiskeyStone"},
        ["beer"] = {stone_key = "whiskeyStone"},

        ["urine"] = {stone_key = "urineStone"},

        ["milk"] = {stone_key = "milkStone"},
        ["material_confusion"] = {stone_key = "confuseStone"},
        ["honey"] = {stone_key = "honeyStone"},

        -- HINT (not recipes)

        ["void_liquid"] = {hint_key = "hint_blankstone_void"},
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

    ["urineStone"] = {
        ["void_liquid"] = {stone_key = "voidStone"},
    },

    ["slimeStone"] = {
        ["unstableTeleportStone"] = {stone_key = "teleportStone"},
        ["[magic_faster]"] = {stone_key = "explosionStone"},
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
        ["[magic_polymorph]"] = {stone_key = "polyStone"},
    },
}

-- Note : preferably use tags to identify ingredients/catalistes if possible
local FUSE_RECIPES = {
    { -- quintessence craft
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
    { -- voidStone to nigredo
        ingredients = {
            { name = "voidStone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "nigredo", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- milkStone to albedo
        ingredients = {
            { name = "milkStone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "albedo", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- honeyStone to citrinitas
        ingredients = {
            { name = "honeyStone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "citrinitas", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- confuseStone to rubedo
        ingredients = {
            { name = "confuseStone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "rubedo", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- albedo purification
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
    { -- opum magnum
        ingredients = {
            { name = "nigredo", count = 1 },
            { name = "albedo", count = 1 },
            { name = "rubedo", count = 1 },
            { name = "citrinitas", count = 1 },
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
    { -- hasteStone by fusion
        ingredients = {
            { name = "levitatiumStone", count = 1 },
            { name = "acceleratiumStone", count = 1 },
        },
        radius = 20,
        results = {
            { key = "hasteStone", offset_y = -10},
            { key = "blankStone", offset_y = -10},
        },
        -- message = {
        --     title = "$text_blankstone_magnum_opus_title",
        --     desc = "$text_blankstone_magnum_opus_desc",
        -- },
        on_success = function() end
    },
    { -- poisonharmful to poison
        ingredients = {
            { name = "poisonHarmfulStone", count = 1 },
        },
        catalistes = {
            { name = "albedo|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "poisonStone", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end
    },
    { -- berserk to pheromone
        ingredients = {
            { name = "bigStone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|rubedo|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "loveStone", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end
    },
    { -- fire to lava
        ingredients = {
            { tag = "brimstone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "lavaStone", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- wandstone to manaStone
        ingredients = {
            { name = "wandstone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "manaStone", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- honey + diamond = ambrosia + posion
        ingredients = {
            { tag = "thunderstone", count = 1 },
            { name = "honeyStone", count = 1 },
        },
        catalistes = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "ambrosiaStone", offset_y = -10},
            { key = "poisonHarmfulStone", offset_y = -10},
        },
        -- message = {
        --     title = "$text_blankstone_title",
        --     desc = "$text_blankstone_desc",
        -- },
        on_success = function() end
    },
    { -- Gods secrets
        ingredients = {
            { name = "reforged_book_infuse", count = 1 },
            { name = "reforged_book_purity", count = 1 },
            { name = "reforged_book_magnum_opus", count = 1 },
        },
        radius = 20,
        results = {
            { key = "bookGodsSecrets", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_fuse_book_title",
            desc = "$text_blankstone_fuse_book_desc",
        },
        on_success = function() end

    },
    { -- Sun Seed Paha Silmä
        ingredients = {
            { name = "wormBloodStone", count = 1 }
        },
        catalistes = {
            { tag = "evil_eye", count = 1 },
        },
        radius = 20,
        results = {
            { key = "sunseed", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_sunSeed_craft_title",
            desc = "$text_blankstone_sunSeed_craft_desc",
        },
        on_success = function() end
    },
}

BOOK_PATH = "mods/blankStone/files/entities/items/books/"

local LIES_MESSAGE = {
    title = "$text_blankstone_unmask_book_title",
    desc  = "$text_blankstone_unmask_book_desc",
}

local REPAIR_MESSAGE = {
    title = "$text_blankstone_repair_book_title",
    desc  = "$text_blankstone_repair_book_desc",
}

local FORGE_RECIPES = {
    ["magicLiquidStone"] = {
        spells  = {"BLANKSTONE_STONE_FUSER"},
        message = {
            title = "$text_blankstone_repair_broken_stone_title",
            desc  = "$text_blankstone_repair_broken_stone_desc",
        }
    },
    ["book_infuse"]      = { items = {BOOK_PATH .. "reforged_book_infuse.xml"},      message = REPAIR_MESSAGE },
    ["book_purity"]      = { items = {BOOK_PATH .. "reforged_book_purity.xml"},      message = REPAIR_MESSAGE },
    ["book_magnum_opus"] = { items = {BOOK_PATH .. "reforged_book_magnum_opus.xml"}, message = REPAIR_MESSAGE },
    ["book_gods_secrets"]= { items = {BOOK_PATH .. "reforged_book_gods_secrets.xml"},message = REPAIR_MESSAGE },
    ["book_honey"]       = { items = {BOOK_PATH .. "reforged_book_honey.xml"},       message = REPAIR_MESSAGE },

    ["book_infuse_lies"]      = { items = {BOOK_PATH .. "tome_of_lies.xml"}, message = LIES_MESSAGE },
    ["book_purity_lies"]      = { items = {BOOK_PATH .. "tome_of_lies.xml"}, message = LIES_MESSAGE },
    ["book_magnum_opus_lies"] = { items = {BOOK_PATH .. "tome_of_lies.xml"}, message = LIES_MESSAGE },
}

return {
    STONE_TO_MATERIAL_TO_STONE = STONE_TO_MATERIAL_TO_STONE,
    FUSE_RECIPES = FUSE_RECIPES,
    FORGE_RECIPES = FORGE_RECIPES,
}