local function storageStoneUpgrade(item)
    EntitySetName(item, "upgraded_universal_storageStone")
end

-- Note : preferably use tags to identify ingredients/catalysts if possible
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
        catalysts = {
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
        catalysts = {
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
        catalysts = {
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
        catalysts = {
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
        catalysts = {
            { name = "albedo", count = 1 },
        },
        radius = 20,
        results = {
            { key = "blankStone", offset_y = -10 },

        },
        message = {
            title = "$text_blankstone_albedo_purify_title",
            desc = "$text_blankstone_albedo_purify_desc",
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
        catalysts = {
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
        on_success = function() end
    },
    { -- teleportStone by fusion
        ingredients = {
            { name = "slimeStone", count = 1 },
            { name = "teleportStone", count = 1 },
        },
        radius = 20,
        results = {
            { key = "trueTeleportStone", offset_y = -10},
            { key = "blankStone", offset_y = -10},
        },
        on_success = function() end
    },
    { -- explosionStone by fusion
        ingredients = {
            { name = "slimeStone", count = 1 },
            { name = "hasteStone|acceleratiumStone|levitatiumStone", count = 1 },
        },
        radius = 20,
        results = {
            { key = "explosionStone", offset_y = -10},
            { key = "blankStone", offset_y = -10},
        },
        on_success = function() end
    },
    { -- poisonharmful to poison
        ingredients = {
            { name = "poisonHarmfulStone", count = 1 },
        },
        catalysts = {
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
        catalysts = {
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
        catalysts = {
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
        catalysts = {
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
    { -- honey + diamond = ambrosia + poison
        ingredients = {
            { tag = "thunderstone", count = 1 },
            { name = "honeyStone", count = 1 },
        },
        -- catalysts = {
        --     { name = "quintessence|lapis_philosophorum", count = 1 },
        -- },
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
        catalysts = {
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
    { -- invisible to phasing
        ingredients = {
            { name = "invisibilityStone", count = 1 },
        },
        catalysts = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,
        results = {
            { key = "phasingStone", offset_y = -10},
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },
    { -- storageStone upgrade
        ingredients = {
            { name = "storageStone", count = 1 },
        },
        catalysts = {
            { name = "quintessence|lapis_philosophorum", count = 1 },
        },
        radius = 20,

        upgrade = function(item) storageStoneUpgrade(item) end,

        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end

    },

    { -- orbPowderStone
        ingredients = {
            { name = "confuseStone", count = 1 },
            { name = "unstableTeleportStone", count = 1 },
        },
        radius = 20,
        results = {
            { key = "orbPowderStone", offset_y = -10 },
            { key = "blankStone", offset_y = -10 },
        },
        on_success = function() end
    },
    { -- shieldStone
        ingredients = {
            { name = "magicLiquidStone", count = 1 },
        },
        radius = 20,
        results = {
            { key = "shieldStone", offset_y = -10 },
        },
        on_success = function() end
    },
    -- ##ANCHOR_FUSE_END##
}

return FUSE_RECIPES
