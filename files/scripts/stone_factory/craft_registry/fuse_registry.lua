local fuseShieldEffect      = dofile_once("mods/blankStone/files/scripts/stone_factory/effects/fuse_shield_effect.lua")
local storageUpgradeApply   = dofile_once("mods/blankStone/files/scripts/stone_factory/effects/storage_upgrade_effect.lua")
local fuseGreedEffect = dofile_once("mods/blankStone/files/scripts/stone_factory/effects/fuse_greed_effect.lua")

local FUSE_RECIPES = {
    { -- quintessence craft
        radius = 20,
        collect = {
            ingredients = {
                { tag = "brimstone",   count = 1 },
                { tag = "thunderstone",count = 1 },
                { tag = "waterstone",  count = 1 },
                { tag = "stonestone",  count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "quintessence", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintessence_unleash_title",
            desc  = "$text_blankstone_quintessence_unleash_desc",
        },
    },
    { -- voidStone => nigredo
        radius = 20,
        collect = {
            ingredients = { { name = "voidStone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "nigredo", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- milkStone => albedo
        radius = 20,
        collect = {
            ingredients = { { name = "milkStone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "albedo", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- honeyStone => citrinitas
        radius = 20,
        collect = {
            ingredients = { { name = "honeyStone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "citrinitas", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- confuseStone => rubedo
        radius = 20,
        collect = {
            ingredients = { { name = "confuseStone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "rubedo", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- albedo purification
        radius = 20,
        collect = {
            ingredients = { { tag = "brimstone|stonestone|waterstone|thunderstone", count = 1 } },
            catalysts   = { { name = "albedo", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "blankStone", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_albedo_purify_title",
            desc  = "$text_blankstone_albedo_purify_desc",
        },
    },
    { -- MAGNUM OPUS
        radius = 20,
        collect = {
            ingredients = {
                { name = "nigredo",    count = 1 },
                { name = "albedo",     count = 1 },
                { name = "rubedo",     count = 1 },
                { name = "citrinitas", count = 1 },
            },
            catalysts = { { name = "quintessence", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "lapis_philosophorum", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_magnum_opus_title",
            desc  = "$text_blankstone_magnum_opus_desc",
        },
    },
    { -- hasteStone par fusion
        radius = 20,
        collect = {
            ingredients = {
                { name = "levitatiumStone",  count = 1 },
                { name = "acceleratiumStone",count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "hasteStone", offset_y = -10 } },
        },
    },
    { -- teleportStone par fusion
        radius = 20,
        collect = {
            ingredients = {
                { name = "slimeStone",   count = 1 },
                { name = "teleportStone",count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "trueTeleportStone", offset_y = -10 } },
        },
    },
    { -- explosionStone par fusion
        radius = 20,
        collect = {
            ingredients = {
                { name = "slimeStone", count = 1 },
                { name = "hasteStone|acceleratiumStone|levitatiumStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "explosionStone", offset_y = -10 } },
        },
    },
    { -- poisonHarmful => poison
        radius = 20,
        collect = {
            ingredients = { { name = "poisonHarmfulStone", count = 1 } },
            catalysts   = { { name = "albedo|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "poisonStone", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- bigStone => loveStone
        radius = 20,
        collect = {
            ingredients = { { name = "bigStone", count = 1 } },
            catalysts   = { { name = "rubedo|quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "loveStone", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- brimstone => lavaStone
        radius = 20,
        collect = {
            ingredients = { { tag = "brimstone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "lavaStone", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- wandstone => manaStone
        radius = 20,
        collect = {
            ingredients = { { name = "wandstone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "manaStone", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- thunderstone + honeyStone => ambrosiaStone + poisonHarmfulStone
        radius = 20,
        collect = {
            ingredients = {
                { tag  = "thunderstone", count = 1 },
                { name = "honeyStone",   count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "ambrosiaStone",     offset_y = -10 },
                { key = "poisonHarmfulStone",offset_y = -10 },
            },
        },
    },
    { -- Gods Secrets (fusion de livres)
        radius = 20,
        collect = {
            ingredients = {
                { name = "reforged_book_infuse",     count = 1 },
                { name = "reforged_book_purity",     count = 1 },
                { name = "reforged_book_magnum_opus",count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "bookGodsSecrets", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_fuse_book_title",
            desc  = "$text_blankstone_fuse_book_desc",
        },
    },
    { -- wormBloodStone + evil_eye => sunseed
        radius = 20,
        collect = {
            ingredients = { { name = "wormBloodStone", count = 1 } },
            catalysts   = { { tag  = "evil_eye",        count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "sunseed", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_sunSeed_craft_title",
            desc  = "$text_blankstone_sunSeed_craft_desc",
        },
    },
    { -- invisibilityStone => phasingStone
        radius = 20,
        collect = {
            ingredients = { { name = "invisibilityStone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "phasingStone", offset_y = -10 } },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- storageStone upgrade
        -- NOTE : effect.apply référence la fonction extraite dans effects/
        radius = 20,
        collect = {
            ingredients = { { name = "storageStone", count = 1 } },
            catalysts   = { { name = "quintessence|lapis_philosophorum", count = 1 } },
        },
        effect = {
            type  = "upgrade",
            apply = storageUpgradeApply,  -- extrait de ce fichier => effects/storage_upgrade_effect.lua
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc  = "$text_blankstone_quintesscence_upgrade_desc",
        },
    },
    { -- orbPowderStone
        radius = 20,
        collect = {
            ingredients = {
                { name = "confuseStone",       count = 1 },
                { name = "unstableTeleportStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "orbPowderStone", offset_y = -10 } },
        },
    },
    { -- shieldStone (craft initial)
        radius = 20,
        collect = {
            ingredients = { { name = "magicLiquidStone", count = 1 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "shieldStone", offset_y = -10 } },
        },
    },
    { -- shieldStone fuse (cumul d'anneaux)
        -- NOTE : on_success référence la fonction extraite dans effects/
        radius = 20,
        collect = {
            ingredients = { { name = "shieldStone", count = 2 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "shieldStone", offset_y = -10 } },
        },
        on_success = fuseShieldEffect,  -- extrait de ce fichier => effects/fuse_shield_effect.lua
    },
    { -- blankStone depuis rochers
        radius = 50,
        collect = {
            ingredients = { { name = "rock", count = 3 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "blankStone", offset_y = -10 } },
        },
    },

    { -- shiniestOrbStone fuse entre elles (cumul d'avidité)
        radius = 20,
        collect = {
            ingredients = { { name = "shiniestOrbStone", count = 2 } },
        },
        effect = {
            type    = "fusion",
            results = { { key = "shiniestOrbStone", offset_y = -10 } },
        },
        on_success = fuseGreedEffect,
    },
    { -- shiniestOrbStone + shiny orb vanilla (absorbe un orb)
        radius = 20,
        collect = {
            ingredients = {
                { name = "shiniestOrbStone", count = 1 },
                { name = "physics_gold_orb", count = 1 }, -- adapte au blankStoneID exact de ton "shiny orb"
            },
        },
        effect = {
            type    = "fusion",
            results = { { key = "shiniestOrbStone", offset_y = -10 } },
        },
        on_success = fuseGreedEffect,
    },
    { -- gluttonyStone
        radius = 20,
        collect = {
            ingredients = {
                { name = "stonestone", count = 1 },
            },
            catalysts = {
                { name = "quintessence", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "gluttonyStone", offset_y = -10 },
            },
        },
        on_success = function() end
    },
    -- ##ANCHOR_FUSE_END##
}

return FUSE_RECIPES
