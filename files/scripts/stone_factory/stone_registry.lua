local blankStone_path = "mods/blankStone/files/entities/"
local elemental_stone_path = blankStone_path .. "elemental_stone/"
local magnum_opus_path = blankStone_path .. "magnum_opus/"
local vanilla_stone_path = "data/entities/items/pickup/"
local book_path = "mods/blankStone/files/entities/items/books/"

-- ============================================================================
-- STONE DEFINITIONS
-- ============================================================================

local STONE_DATA = {
    -- Blank Stone
    ["blankStone"] = {
        path = blankStone_path .. "blank_stone",
        level = 0,
        category = "special",
    },

    -- Magnum Opus
    ["lapis_philosophorum"] = {
        path = magnum_opus_path .. "lapis_philosophorum",
        level = 34,
        category = "magnum_opus",
    },
    ["nigredo"] = {
        path = magnum_opus_path .. "nigredo",
        level = 5,
        category = "magnum_opus",
    },
    ["albedo"] = {
        path = magnum_opus_path .. "albedo",
        level = 7,
        category = "magnum_opus",
    },
    ["citrinitas"] = {
        path = magnum_opus_path .. "citrinitas",
        level = 9,
        category = "magnum_opus",
    },
    ["rubedo"] = {
        path = magnum_opus_path .. "rubedo",
        level = 9,
        category = "magnum_opus",
    },

    -- Special

    ["quintessence"] = {
        path = blankStone_path .. "quintessence_stone",
        level = 7,
        category = "special",
    },
    ["goldStone"] = {
        path = elemental_stone_path .. "stone_gold",
        level = 5,
        category = "elemental",
    },

    -- Elemental

    ["magicLiquidStone"] = {
        path = elemental_stone_path .. "stone_magic_liquid",
        level = 1,
        category = "elemental",
    },
    ["toxicStone"] = {
        path = elemental_stone_path .. "stone_toxic",
        level = 1,
        category = "elemental",
    },
    ["voidStone"] = {
        path = elemental_stone_path .. "stone_void",
        level = 1,
        category = "elemental",
    },
    ["milkStone"] = {
        path = elemental_stone_path .. "stone_milk",
        level = 1,
        category = "elemental",
    },
    ["confuseStone"] = {
        path = elemental_stone_path .. "stone_confuse",
        level = 1,
        category = "elemental",
    },
    ["poisonHarmfulStone"] = {
        path = elemental_stone_path .. "stone_poison_harmful",
        level = 1,
        category = "elemental",
    },
    ["bigStone"] = {
        path = elemental_stone_path .. "stone_big",
        level = 1,
        category = "elemental",
    },
    ["honeyStone"] = {
        path = elemental_stone_path .. "stone_honey",
        level = 1,
        category = "elemental",
    },
    ["invisibilityStone"] = {
        path = elemental_stone_path .. "stone_invisibility",
        level = 1,
        category = "elemental",
    },
    ["acceleratiumStone"] = {
        path = elemental_stone_path .. "stone_acceleratium",
        level = 1,
        category = "elemental",
    },
    ["levitatiumStone"] = {
        path = elemental_stone_path .. "stone_levitatium",
        level = 1,
        category = "elemental",
    },
    ["whiskeyStone"] = {
        path = elemental_stone_path .. "stone_whiskey",
        level = 1,
        category = "elemental",
    },
    ["urineStone"] = {
        path = elemental_stone_path .. "stone_urine",
        level = 1,
        category = "elemental",
    },
    ["unstableTeleportStone"] = {
        path = elemental_stone_path .. "stone_unstable_teleport",
        level = 1,
        category = "elemental",
    },

    ["teleportStone"] = {
        path = elemental_stone_path .. "stone_teleport",
        level = 5,
        category = "elemental",
    },
    ["hasteStone"] = {
        path = elemental_stone_path .. "stone_haste",
        level = 5,
        category = "elemental",
    },
    ["explosionStone"] = {
        path = elemental_stone_path .. "stone_explosion",
        level = 5,
        category = "elemental",
    },

    ["poisonStone"] = {
        path = elemental_stone_path .. "stone_poison",
        level = 7,
        category = "elemental",
    },
    ["bonesStone"] = {
        path = elemental_stone_path .. "stone_bones",
        level = 7,
        category = "elemental",
    },

    ["lavaStone"] = {
        path = elemental_stone_path .. "stone_lava",
        level = 9,
        category = "elemental",
    },
    ["bloodStone"] = {
        path = elemental_stone_path .. "stone_blood",
        level = 9,
        category = "elemental",
    },
    ["manaStone"] = {
        path = elemental_stone_path .. "stone_mana",
        level = 9,
        category = "elemental",
    },

    ["wormBloodStone"] = {
        path = elemental_stone_path .. "stone_worm_blood",
        level = 9,
        category = "elemental",
    },

    ["polyStone"] = {
        path = elemental_stone_path .. "stone_poly",
        level = 11,
        category = "elemental",
    },
    ["healthStone"] = {
        path = elemental_stone_path .. "stone_health",
        level = 11,
        category = "elemental",
    },
    ["ambrosiaStone"] = {
        path = elemental_stone_path .. "stone_ambrosia",
        level = 11,
        category = "elemental",
    },
    ["loveStone"] = {
        path = elemental_stone_path .. "stone_love",
        level = 10,
        category = "elemental",
    },

    -- Vanilla Stones
    ["brimstone"] = {
        path = vanilla_stone_path .. "brimstone",
        level = 1,
        category = "vanilla",
    },
    ["thunderstone"] = {
        path = vanilla_stone_path .. "thunderstone",
        level = 1,
        category = "vanilla",
    },
    ["stonestone"] = {
        path = vanilla_stone_path .. "stonestone",
        level = 5,
        category = "vanilla",
    },
    ["waterstone"] = {
        path = vanilla_stone_path .. "waterstone",
        level = 5,
        category = "vanilla",
    },
    ["poopstone"] = {
        path = vanilla_stone_path .. "poopstone",
        level = 5,
        category = "vanilla",
    },
    ["sunseed"] = {
        path = vanilla_stone_path .. "sun/sunseed",
        level = 9,
        category = "vanilla",
    },
    ["wandstone"] = {
        path = vanilla_stone_path .. "wandstone",
        level = 9,
        category = "vanilla",
    },
    ["shinyOrb"] = {
        path = vanilla_stone_path .. "physics_gold_orb",
        level = 1,
        category = "vanilla",
    },

    -- Books

    ["reforgedBookInfuse"] = {
        path = book_path .. "reforged_book_infuse",
        level = 0,
        category = "book",
    },
    ["reforgedBookPurity"] = {
        path = book_path .. "reforged_book_purity",
        level = 0,
        category = "book",
    },
    ["reforgedBookMagnumOpus"] = {
        path = book_path .. "reforged_book_magnum_opus",
        level = 0,
        category = "book",
    },
    ["bookGodsSecrets"] = {
        path = book_path .. "book_gods_secrets",
        level = 0,
        category = "book",
    },
}

-- ============================================================================
-- MESSAGES
-- ============================================================================

local STONE_MESSAGES = {
-- Magnum Opus
    ["lapis_philosophorum"] = {
        success = "$text_blankstone_lapis_philosophorum_success",
        fail    = "$text_blankstone_lapis_philosophorum_fail",
    },
    ["nigredo"] = {
        success = "$text_blankstone_nigredo_success_craft",
        fail    = "$text_blankstone_nigredo_fail_craft",
    },
    ["albedo"] = {
        success = "$text_blankstone_albedo_success_craft",
        fail    = "$text_blankstone_albedo_fail_craft",
    },
    ["citrinitas"] = {
        success = "$text_blankstone_citrinitas_success_craft",
        fail    = "$text_blankstone_citrinitas_fail_craft",
    },
    ["rubedo"] = {
        success = "$text_blankstone_rubedo_success_craft",
        fail    = "$text_blankstone_rubedo_fail_craft",
    },
-- Pierres spéciales
    ["quintessence"] = {
        success = "$text_blankstone_quintessence_unleash_title",
        fail    = "$text_blankstone_missing_knowledge",
    },
    ["goldStone"] = {
        success = "$text_blankstone_goldstone_success",
        fail    = "$text_blankstone_goldstone_fail",
    },
    ["honeyStone"] = {
        success = "$text_blankstone_honey_success_craft",
    },
-- Pierres avec messages custom
    ["lavaStone"] = {
        success = "$text_blankstone_lavastone_success",
        fail    = "$text_blankstone_lavastone_fail",
    },
    ["bloodStone"] = {
        success = "$text_blankstone_bloodstone_success",
        fail    = "$text_blankstone_bloodstone_fail",
    },
    ["teleportStone"] = {
        fail = "$text_blankstone_missing_knowledge",
    },
    ["poisonStone"] = {
        fail = "$text_blankstone_missing_lot_knowledge",
    },
    ["hasteStone"] = {
        fail = "$text_blankstone_missing_knowledge",
    },
    ["explosionStone"] = {
        fail = "$text_blankstone_missing_lot_knowledge",
    },
    ["polyStone"] = {
        success = "$text_blankstone_poly_success_craft",
        fail    = "$text_blankstone_poly_fail_craft",
    },
    ["healthStone"] = {
        success = "$text_blankstone_healthstone_success",
        fail    = "$text_blankstone_missing_all_knowledge",
    },
    ["ambrosiaStone"] = {
        fail = "$text_blankstone_missing_all_knowledge",
    },
    ["loveStone"] = {
        success = "$text_blankstone_lovestone_success",
        fail    = "$text_blankstone_lovestone_fail",
    },
    ["bonesStone"] = {
        success = "$text_blankstone_bonestone_success",
        fail    = "$text_blankstone_bonestone_fail",
    },
    ["whiskeyStone"] = {
        success = "$text_blankstone_whiskeystone_success",
        fail    = "$text_blankstone_whiskeystone_fail",
    },
    ["stonestone"] = {
        fail = "$text_blankstone_missing_knowledge",
    },
    ["waterstone"] = {
        fail = "$text_blankstone_missing_knowledge",
    },
    ["poopstone"] = {
        fail = "$text_blankstone_missing_knowledge",
    },
    ["sunseed"] = {
        fail = "$text_blankstone_missing_lot_knowledge",
    },
    ["wandstone"] = {
        fail = "$text_blankstone_missing_lot_knowledge",
    },
-- A bit of trolling
    ["shinyOrb"] = {
        success = "$text_blankstone_shinyorb_anticlimax",
    },
}

local DEFAULT_MESSAGES = {
    success = "$text_blankstone_default_success",
    fail    = "$text_blankstone_default_fail",
}

-- ============================================================================
-- VFX (effets visuels)
-- ============================================================================

-- Définitions des VFX réutilisables
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

-- Mapping pierre → VFX
local STONE_VFX_MAPPING = {
    ["lapis_philosophorum"] = "magnum_opus_ultimate",
    ["nigredo"] = "magnum_opus_standard",
    ["albedo"] = "magnum_opus_standard",
    ["citrinitas"] = "magnum_opus_standard",
    ["rubedo"] = "magnum_opus_standard",
    ["quintessence"] = "quintessence_unleash",
}

-- ============================================================================
-- CONDITIONS
-- ============================================================================

-- persistant > run

local STONE_CONDITIONS = {
    ["citrinitas"] = {
        flags = {{run = "progress_sun", persistant = "secret_hat"}}
    },
    ["nigredo"] = {
        flags = {{run = "progress_darksun", persistant = "secret_hat"}}
    },
    default = {
    },
}

local LEVEL_CONDITIONS = {
    [5]  = { orbs = 1 },
    [7]  = { orbs = 3 },
    [9]  = { orbs = 5 },
    [10] = { orbs = 11 },
    [11] = { orbs = 11, purity = true },
}

local function deduceConditions(level)
    return LEVEL_CONDITIONS[level] or {}
end

-- ============================================================================
-- PREPROCESS : Too specific change
-- ============================================================================
-- Call BEFORE spawn, but AFTER conditions check
-- Input : data
-- Output : new_data

local STONE_PREPROCESS = {
    ["shinyOrb"] = function(data)
        if GameHasFlagRun("greed_curse") and not GameHasFlagRun("greed_curse_gone") then
            data.path = "data/entities/items/pickup/physics_gold_orb_greed.xml"
        end
        return data
    end,
}

-- ============================================================================
-- POSTPROCESS : Callback
-- ============================================================================
-- Call AFTER spawn stone + VFX
-- Input : stone entity id
-- Output : void

local STONE_POSTPROCESS = {
}

-- ============================================================================
-- BUILDER : Construit STONE_REGISTRY dans le format attendu
-- ============================================================================

local function buildStoneRegistry()
    local registry = {}
    
    for stone_key, stone_data in pairs(STONE_DATA) do
        -- Messages
        local messages = STONE_MESSAGES[stone_key] or {}
        local message_success = messages.success or DEFAULT_MESSAGES.success
        local message_fail = messages.fail or DEFAULT_MESSAGES.fail
        
        -- VFX
        local vfx_preset = STONE_VFX_MAPPING[stone_key] or "default"
        local vfx = VFX_PRESETS[vfx_preset]
        
        -- Conditions
        local conditions =
            STONE_CONDITIONS[stone_key]
            or deduceConditions(stone_data.level)
            or STONE_CONDITIONS.default
        
        -- Callbacks
        local preprocess = STONE_PREPROCESS[stone_key] or function(data) return data end
        local postprocess = STONE_POSTPROCESS[stone_key] or function(id) end
        
        -- Construire l'entrée
        registry[stone_key] = {
            path = stone_data.path .. ".xml",
            level = stone_data.level,
            message = message_success,
            message_fail = message_fail,
            vfx = vfx,
            conditions = conditions,

            preprocess = preprocess,
            postprocess = postprocess,
        }
    end

    return registry
end

local STONE_REGISTRY = buildStoneRegistry()

return STONE_REGISTRY
