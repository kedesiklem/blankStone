local log = dofile_once("mods/blankStone/utils/logger.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local function storageStoneUpgrade(item)
    EntitySetName(item, "upgraded_universal_storageStone")
    local name = utils.getName(item)
    utils.changeName(item, name .. "+")
end

local SHIELD_XML = "mods/blankStone/files/entities/misc/shield.xml"
local RADIUS_STEP = 3  -- offset entre chaque anneau

local function fuseShield(spawned, ctx)

    local stoneIn1 = EntityGetAllChildren(ctx.ingredients[1][1], "energy_shield")
    local stoneIn2 = EntityGetAllChildren(ctx.ingredients[1][2], "energy_shield")
    local stoneOut = EntityGetAllChildren(spawned[1], "energy_shield")

    if not stoneIn1 or not stoneIn2 or not stoneOut then
        log.error("Couldn't find all 3 stones")
        return
    end

    local total = #stoneIn1 + #stoneIn2

    -- (-1 car stoneOut en a déjà un)
    local ox, oy = EntityGetTransform(spawned[1])
    for i = 1, total - 1 do
        local new_shield = EntityLoad(SHIELD_XML, ox, oy)
        EntityAddChild(spawned[1], new_shield)
    end

    local all_out = EntityGetAllChildren(spawned[1], "energy_shield")

    for i, shield_entity in ipairs(all_out) do
        local radius = 12 + (i - 1) * RADIUS_STEP
        -- EnergyShieldComponent
        local shield_comps = EntityGetComponentIncludingDisabled(shield_entity, "EnergyShieldComponent")
        if shield_comps then
            for _, c in ipairs(shield_comps) do
                ComponentSetValue2(c, "radius", radius)
            end
        end

        -- ParticleEmitterComponents (les anneaux visuels)
        local particle_comps = EntityGetComponentIncludingDisabled(shield_entity, "ParticleEmitterComponent")
        if particle_comps then
            for _, c in ipairs(particle_comps) do
                ComponentSetValue2(c, "area_circle_radius", radius, radius)
            end
        end
    end

    local name = utils.getName(spawned[1])
    utils.changeName(spawned[1], name .. " [" .. total .. "]")

    log.info("Shield fusion complete — " .. #all_out .. " rings")
end

-- Note : preferably use tags to identify ingredients/catalysts if possible
local FUSE_RECIPES = {
    { -- quintessence craft
        radius = 20,
        collect = {
            ingredients = {
                { tag = "brimstone", count = 1 },
                { tag = "thunderstone", count = 1 },
                { tag = "waterstone", count = 1 },
                { tag = "stonestone", count = 1 }
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "quintessence", offset_y = -10 },
            },
        },
        message = {
            title = "$text_blankstone_quintessence_unleash_title",
            desc = "$text_blankstone_quintessence_unleash_desc",
        },
        on_success = function() end,
    },
    { -- voidStone to nigredo
        radius = 20,
        collect = {
            ingredients = {
                { name = "voidStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "nigredo", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- milkStone to albedo
        radius = 20,
        collect = {
            ingredients = {
                { name = "milkStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "albedo", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- honeyStone to citrinitas
        radius = 20,
        collect = {
            ingredients = {
                { name = "honeyStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "citrinitas", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- confuseStone to rubedo
        radius = 20,
        collect = {
            ingredients = {
                { name = "confuseStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "rubedo", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- albedo purification
        radius = 20,
        collect = {
            ingredients = {
                { tag = "brimstone|stonestone|waterstone|thunderstone", count = 1 },
            },
            catalysts   = {
                { name = "albedo", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "blankStone", offset_y = -10 },

            },
        },
        message = {
            title = "$text_blankstone_albedo_purify_title",
            desc = "$text_blankstone_albedo_purify_desc",
        },
        on_success = function() end,
    },
    { -- opum magnum
        radius = 20,
        collect = {
            ingredients = {
                { name = "nigredo", count = 1 },
                { name = "albedo", count = 1 },
                { name = "rubedo", count = 1 },
                { name = "citrinitas", count = 1 },
            },
            catalysts   = {
                { name = "quintessence", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "lapis_philosophorum", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_magnum_opus_title",
            desc = "$text_blankstone_magnum_opus_desc",
        },
        on_success = function() end,
    },
    { -- hasteStone by fusion
        radius = 20,
        collect = {
            ingredients = {
                { name = "levitatiumStone", count = 1 },
                { name = "acceleratiumStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "hasteStone", offset_y = -10},
            },
        },
        on_success = function() end,
    },
    { -- teleportStone by fusion
        radius = 20,
        collect = {
            ingredients = {
                { name = "slimeStone", count = 1 },
                { name = "teleportStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "trueTeleportStone", offset_y = -10},
            },
        },
        on_success = function() end,
    },
    { -- explosionStone by fusion
        radius = 20,
        collect = {
            ingredients = {
                { name = "slimeStone", count = 1 },
                { name = "hasteStone|acceleratiumStone|levitatiumStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "explosionStone", offset_y = -10},
            },
        },
        on_success = function() end,
    },
    { -- poisonharmful to poison
        radius = 20,
        collect = {
            ingredients = {
                { name = "poisonHarmfulStone", count = 1 },
            },
            catalysts   = {
                { name = "albedo|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "poisonStone", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- berserk to pheromone
        radius = 20,
        collect = {
            ingredients = {
                { name = "bigStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|rubedo|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "loveStone", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- fire to lava
        radius = 20,
        collect = {
            ingredients = {
                { tag = "brimstone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "lavaStone", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- wandstone to manaStone
        radius = 20,
        collect = {
            ingredients = {
                { name = "wandstone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "manaStone", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- honey + diamond = ambrosia + poison
        radius = 20,
        collect = {
            ingredients = {
                { tag = "thunderstone", count = 1 },
                { name = "honeyStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "ambrosiaStone", offset_y = -10},
                { key = "poisonHarmfulStone", offset_y = -10},
            },
        },
        on_success = function() end,
    },
    { -- Gods secrets
        radius = 20,
        collect = {
            ingredients = {
                { name = "reforged_book_infuse", count = 1 },
                { name = "reforged_book_purity", count = 1 },
                { name = "reforged_book_magnum_opus", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "bookGodsSecrets", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_fuse_book_title",
            desc = "$text_blankstone_fuse_book_desc",
        },
        on_success = function() end,
    },
    { -- Sun Seed Paha Silmä
        radius = 20,
        collect = {
            ingredients = {
                { name = "wormBloodStone", count = 1 }
            },
            catalysts   = {
                { tag = "evil_eye", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "sunseed", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_sunSeed_craft_title",
            desc = "$text_blankstone_sunSeed_craft_desc",
        },
        on_success = function() end,
    },
    { -- invisible to phasing
        radius = 20,
        collect = {
            ingredients = {
                { name = "invisibilityStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "phasingStone", offset_y = -10},
            },
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- storageStone upgrade
        radius = 20,
        collect = {
            ingredients = {
                { name = "storageStone", count = 1 },
            },
            catalysts   = {
                { name = "quintessence|lapis_philosophorum", count = 1 },
            },
        },
        effect = {
            type  = "upgrade",
            apply = storageStoneUpgrade,
        },
        message = {
            title = "$text_blankstone_quintesscence_upgrade_title",
            desc = "$text_blankstone_quintesscence_upgrade_desc",
        },
        on_success = function() end,
    },
    { -- orbPowderStone
        radius = 20,
        collect = {
            ingredients = {
                { name = "confuseStone", count = 1 },
                { name = "unstableTeleportStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "orbPowderStone", offset_y = -10 },
            },
        },
        on_success = function() end,
    },
    { -- shieldStone
        radius = 20,
        collect = {
            ingredients = {
                { name = "magicLiquidStone", count = 1 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "shieldStone", offset_y = -10 },
            },
        },
        on_success = function() end,
    },

    { -- shieldStone Fuse
        radius = 20,
        collect = {
            ingredients = {
                { name = "shieldStone", count = 2 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "shieldStone", offset_y = -10 },
            },
        },
        on_success = fuseShield
    },

    { -- blankStone generation
        radius = 50,
        collect = {
            ingredients = {
                { name = "rock", count = 3 },
            },
        },
        effect = {
            type    = "fusion",
            results = {
                { key = "blankStone", offset_y = -10 },
            },
        },
    },
    -- ##ANCHOR_FUSE_END##
}

return FUSE_RECIPES