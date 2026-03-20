local blankStone_path    = "mods/blankStone/files/entities/"
local elemental_stone_path = blankStone_path .. "elemental_stone/"
local magnum_opus_path   = blankStone_path .. "magnum_opus/"
local vanilla_stone_path = "data/entities/items/pickup/"
local book_path          = "mods/blankStone/files/entities/items/books/"

-- ============================================================================
-- VFX PRESETS  (partagés, référencés par nom dans chaque pierre)
-- ============================================================================

local VFX_PRESETS = {
    default = {
        "data/entities/projectiles/explosion.xml",
    },
    magnum_opus_ultimate = {
        "data/entities/projectiles/deck/explosion_giga.xml",
        "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml",
    },
    magnum_opus_standard = {
        "data/entities/projectiles/explosion.xml",
        "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml",
    },
    quintessence_unleash = {
        "data/entities/projectiles/deck/explosion_giga.xml",
        "mods/blankStone/files/VFX/image_emitters/quintessence_symbol_fast.xml",
    },
}

-- ============================================================================
-- CONDITIONS par niveau  (déduites automatiquement si non précisées)
-- ============================================================================

local LEVEL_CONDITIONS = {
    [5]  = { orbs = 1 },
    [7]  = { orbs = 3 },
    [9]  = { orbs = 5 },
    [10] = { orbs = 11 },
    [11] = { orbs = 11, purity = true },
}

-- ============================================================================
-- MESSAGES par défaut
-- ============================================================================

local DEFAULT_MESSAGES = {
    success = "$text_blankstone_default_success",
    fail    = "$text_blankstone_default_fail",
}

-- ============================================================================
-- STONE DEFINITIONS  (source de vérité unique par pierre)
--
-- Champs disponibles :
--   path        (string)   chemin sans .xml  [obligatoire]
--   level       (number)   niveau requis      [obligatoire]
--   category    (string)   "elemental" | "magnum_opus" | "special" | "vanilla" | "book"  [obligatoire]
--
--   messages    (table)    { success = "...", fail = "..." }  -- omis = défauts
--   vfx         (string)   nom d'un VFX_PRESET  -- omis = "default"
--   conditions  (table)    { flags = {...} }      -- omis = déduit du level
--
--   preprocess  (function) function(data) return data end   -- appelée avant spawn
--   postprocess (function) function(entity_id) end          -- appelée après spawn
-- ============================================================================

local STONE_DATA = {

    -- -------------------------------------------------------------------------
    -- SPECIAL
    -- -------------------------------------------------------------------------

    ["blankStone"] = {
        path     = blankStone_path .. "blank_stone",
        level    = 0,
        category = "special",
    },

    ["quintessence"] = {
        path     = blankStone_path .. "quintessence_stone",
        level    = 7,
        category = "special",
        messages = {
            success = "$text_blankstone_quintessence_unleash_title",
            fail    = "$text_blankstone_missing_knowledge",
        },
        vfx = "quintessence_unleash",
    },

    ["storageStone"] = {
        path     = blankStone_path .. "stone_storage",
        level    = 1,
        category = "special",
    },

    -- -------------------------------------------------------------------------
    -- MAGNUM OPUS
    -- -------------------------------------------------------------------------

    ["lapis_philosophorum"] = {
        path     = magnum_opus_path .. "lapis_philosophorum",
        level    = 34,
        category = "magnum_opus",
        messages = {
            success = "$text_blankstone_lapis_philosophorum_success",
            fail    = "$text_blankstone_lapis_philosophorum_fail",
        },
        vfx = "magnum_opus_ultimate",
    },

    ["nigredo"] = {
        path     = magnum_opus_path .. "nigredo",
        level    = 5,
        category = "magnum_opus",
        messages = {
            success = "$text_blankstone_nigredo_success_craft",
            fail    = "$text_blankstone_nigredo_fail_craft",
        },
        vfx        = "magnum_opus_standard",
        conditions = { flags = {{ run = "progress_darksun", persistent = "secret_hat" }} },
    },

    ["albedo"] = {
        path     = magnum_opus_path .. "albedo",
        level    = 7,
        category = "magnum_opus",
        messages = {
            success = "$text_blankstone_albedo_success_craft",
            fail    = "$text_blankstone_albedo_fail_craft",
        },
        vfx = "magnum_opus_standard",
    },

    ["citrinitas"] = {
        path     = magnum_opus_path .. "citrinitas",
        level    = 9,
        category = "magnum_opus",
        messages = {
            success = "$text_blankstone_citrinitas_success_craft",
            fail    = "$text_blankstone_citrinitas_fail_craft",
        },
        vfx        = "magnum_opus_standard",
        conditions = { flags = {{ run = "progress_sun", persistent = "secret_hat" }} },
    },

    ["rubedo"] = {
        path     = magnum_opus_path .. "rubedo",
        level    = 9,
        category = "magnum_opus",
        messages = {
            success = "$text_blankstone_rubedo_success_craft",
            fail    = "$text_blankstone_rubedo_fail_craft",
        },
        vfx = "magnum_opus_standard",
    },

    -- -------------------------------------------------------------------------
    -- ELEMENTAL
    -- -------------------------------------------------------------------------

    ["goldStone"] = {
        path     = elemental_stone_path .. "stone_gold",
        level    = 5,
        category = "elemental",
        messages = {
            success = "$text_blankstone_goldstone_success",
            fail    = "$text_blankstone_goldstone_fail",
        },
    },

    ["magicLiquidStone"] = {
        path     = elemental_stone_path .. "stone_magic_liquid",
        level    = 1,
        category = "elemental",
    },

    ["toxicStone"] = {
        path     = elemental_stone_path .. "stone_toxic",
        level    = 7,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["voidStone"] = {
        path     = elemental_stone_path .. "stone_void",
        level    = 1,
        category = "elemental",
    },

    ["phasingStone"] = {
        path     = elemental_stone_path .. "stone_phasing",
        level    = 9,
        category = "elemental",
    },

    ["milkStone"] = {
        path     = elemental_stone_path .. "stone_milk",
        level    = 1,
        category = "elemental",
    },

    ["confuseStone"] = {
        path     = elemental_stone_path .. "stone_confuse",
        level    = 1,
        category = "elemental",
    },

    ["poisonHarmfulStone"] = {
        path     = elemental_stone_path .. "stone_poison_harmful",
        level    = 1,
        category = "elemental",
    },

    ["bigStone"] = {
        path     = elemental_stone_path .. "stone_big",
        level    = 1,
        category = "elemental",
    },

    ["honeyStone"] = {
        path     = elemental_stone_path .. "stone_honey",
        level    = 1,
        category = "elemental",
        messages = { success = "$text_blankstone_honey_success_craft" },
    },

    ["invisibilityStone"] = {
        path     = elemental_stone_path .. "stone_invisibility",
        level    = 1,
        category = "elemental",
    },

    ["acceleratiumStone"] = {
        path     = elemental_stone_path .. "stone_acceleratium",
        level    = 1,
        category = "elemental",
    },

    ["levitatiumStone"] = {
        path     = elemental_stone_path .. "stone_levitatium",
        level    = 1,
        category = "elemental",
    },

    ["whiskeyStone"] = {
        path     = elemental_stone_path .. "stone_whiskey",
        level    = 1,
        category = "elemental",
        messages = {
            success = "$text_blankstone_whiskeystone_success",
            fail    = "$text_blankstone_whiskeystone_fail",
        },
    },

    ["urineStone"] = {
        path     = elemental_stone_path .. "stone_urine",
        level    = 1,
        category = "elemental",
    },

    ["unstableTeleportStone"] = {
        path     = elemental_stone_path .. "stone_unstable_teleport",
        level    = 1,
        category = "elemental",
    },

    ["slimeStone"] = {
        path     = elemental_stone_path .. "stone_slime",
        level    = 1,
        category = "elemental",
    },

    ["freezeStone"] = {
        path     = elemental_stone_path .. "stone_freeze",
        level    = 7,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["teleportStone"] = {
        path     = elemental_stone_path .. "stone_teleport",
        level    = 5,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["trueTeleportStone"] = {
        path     = elemental_stone_path .. "stone_true_teleport",
        level    = 5,
        category = "elemental",
    },

    ["hasteStone"] = {
        path     = elemental_stone_path .. "stone_haste",
        level    = 5,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["explosionStone"] = {
        path     = elemental_stone_path .. "stone_explosion",
        level    = 5,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_lot_knowledge" },
    },

    ["gunpowderStone"] = {
        path     = elemental_stone_path .. "stone_gunpowder",
        level    = 7,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["poisonStone"] = {
        path     = elemental_stone_path .. "stone_poison",
        level    = 7,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_lot_knowledge" },
    },

    ["bonesStone"] = {
        path     = elemental_stone_path .. "stone_bones",
        level    = 7,
        category = "elemental",
        messages = {
            success = "$text_blankstone_bonestone_success",
            fail    = "$text_blankstone_bonestone_fail",
        },
    },

    ["lavaStone"] = {
        path     = elemental_stone_path .. "stone_lava",
        level    = 9,
        category = "elemental",
        messages = {
            success = "$text_blankstone_lavastone_success",
            fail    = "$text_blankstone_lavastone_fail",
        },
    },

    ["bloodStone"] = {
        path     = elemental_stone_path .. "stone_blood",
        level    = 9,
        category = "elemental",
        messages = {
            success = "$text_blankstone_bloodstone_success",
            fail    = "$text_blankstone_bloodstone_fail",
        },
    },

    ["manaStone"] = {
        path     = elemental_stone_path .. "stone_mana",
        level    = 9,
        category = "elemental",
    },

    ["wormBloodStone"] = {
        path     = elemental_stone_path .. "stone_worm_blood",
        level    = 9,
        category = "elemental",
    },

    ["polyStone"] = {
        path     = elemental_stone_path .. "stone_poly",
        level    = 11,
        category = "elemental",
        messages = {
            success = "$text_blankstone_poly_craft_success",
            fail    = "$text_blankstone_poly_craft_fail",
        },
    },

    ["healthStone"] = {
        path     = elemental_stone_path .. "stone_health",
        level    = 11,
        category = "elemental",
        messages = {
            success = "$text_blankstone_healthstone_success",
            fail    = "$text_blankstone_missing_all_knowledge",
        },
    },

    ["ambrosiaStone"] = {
        path     = elemental_stone_path .. "stone_ambrosia",
        level    = 11,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_all_knowledge" },
    },

    ["loveStone"] = {
        path     = elemental_stone_path .. "stone_love",
        level    = 10,
        category = "elemental",
        messages = {
            success = "$text_blankstone_lovestone_success",
            fail    = "$text_blankstone_lovestone_fail",
        },
    },

    ["copperStone"] = {
        path     = elemental_stone_path .. "stone_copper",
        level    = 7,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["brassStone"] = {
        path     = elemental_stone_path .. "stone_brass",
        level    = 9,
        category = "elemental",
        messages = { fail = "$text_blankstone_missing_lot_knowledge" },
    },

    ["orbPowderStone"] = {
        path     = elemental_stone_path .. "stone_orb_powder",
        level    = 1,
        category = "elemental",
    },

    ["sodiumStone"] = {
        path     = elemental_stone_path .. "stone_sodium",
        level    = 1,
        category = "elemental",
    },

    ["diminutionStone"] = {
        path     = elemental_stone_path .. "stone_diminution",
        level    = 5,
        category = "elemental",
    },

    ["shieldStone"] = {
        path     = elemental_stone_path .. "stone_shield",
        level    = 1,
        category = "elemental",
    },

    ["cementStone"] = {
        path     = elemental_stone_path .. "stone_cement",
        level    = 1,
        category = "elemental",
    },

    -- -------------------------------------------------------------------------
    -- VANILLA
    -- -------------------------------------------------------------------------

    ["brimstone"] = {
        path     = vanilla_stone_path .. "brimstone",
        level    = 1,
        category = "vanilla",
    },

    ["thunderstone"] = {
        path     = vanilla_stone_path .. "thunderstone",
        level    = 1,
        category = "vanilla",
    },

    ["stonestone"] = {
        path     = vanilla_stone_path .. "stonestone",
        level    = 5,
        category = "vanilla",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["waterstone"] = {
        path     = vanilla_stone_path .. "waterstone",
        level    = 5,
        category = "vanilla",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["poopstone"] = {
        path     = vanilla_stone_path .. "poopstone",
        level    = 5,
        category = "vanilla",
        messages = { fail = "$text_blankstone_missing_knowledge" },
    },

    ["sunseed"] = {
        path     = vanilla_stone_path .. "sun/sunseed",
        level    = 9,
        category = "vanilla",
        messages = { fail = "$text_blankstone_missing_lot_knowledge" },
    },

    ["wandstone"] = {
        path     = vanilla_stone_path .. "wandstone",
        level    = 9,
        category = "vanilla",
        messages = { fail = "$text_blankstone_missing_lot_knowledge" },
    },

    ["shinyOrb"] = {
        path     = vanilla_stone_path .. "physics_gold_orb",
        level    = 1,
        category = "vanilla",
        messages = { success = "$text_blankstone_shinyorb_anticlimax" },
        preprocess = function(data)
            if GameHasFlagRun("greed_curse") and not GameHasFlagRun("greed_curse_gone") then
                data.path = "data/entities/items/pickup/physics_gold_orb_greed.xml"
            end
            return data
        end,
    },

    ["moon"] = {
        path     = vanilla_stone_path .. "moon",
        level    = 1,
        category = "vanilla",
        messages = { success = "$text_blankstone_cheese" },
    },

    -- -------------------------------------------------------------------------
    -- BOOKS
    -- -------------------------------------------------------------------------

    ["bookInfuse"] = {
        path     = book_path .. "book_infuse",
        level    = 0,
        category = "book",
    },

    ["bookPurity"] = {
        path     = book_path .. "book_purity",
        level    = 0,
        category = "book",
    },

    ["bookMagnumOpus"] = {
        path     = book_path .. "book_magnum_opus",
        level    = 0,
        category = "book",
    },

    ["reforgedBookInfuse"] = {
        path     = book_path .. "reforged_book_infuse",
        level    = 0,
        category = "book",
    },

    ["reforgedBookPurity"] = {
        path     = book_path .. "reforged_book_purity",
        level    = 0,
        category = "book",
    },

    ["reforgedBookMagnumOpus"] = {
        path     = book_path .. "reforged_book_magnum_opus",
        level    = 0,
        category = "book",
    },

    ["bookGodsSecrets"] = {
        path     = book_path .. "book_gods_secrets",
        level    = 0,
        category = "book",
    },

    ["reforgedBookGodsSecrets"] = {
        path     = book_path .. "reforged_book_gods_secrets",
        level    = 0,
        category = "book",
    },
}

-- ============================================================================
-- BUILDER
-- ============================================================================

local function buildStoneRegistry()
    local registry = {}

    for key, def in pairs(STONE_DATA) do
        local msgs = def.messages or {}

        registry[key] = {
            path         = def.path .. ".xml",
            level        = def.level,
            category     = def.category,
            message      = msgs.success or DEFAULT_MESSAGES.success,
            message_fail = msgs.fail    or DEFAULT_MESSAGES.fail,
            vfx          = VFX_PRESETS[def.vfx or "default"],
            conditions   = def.conditions or LEVEL_CONDITIONS[def.level] or {},
            preprocess   = def.preprocess  or function(data) return data end,
            postprocess  = def.postprocess or function(_id) end,
        }
    end

    return registry
end

return buildStoneRegistry()