local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local function apply_patch(filepath, pattern, replacement, label)
    local content = ModTextFileGetContent(filepath)
    local result, count = content:gsub(pattern, replacement)
    if count == 0 then
        log.tmp_warn("Patch [" .. label .. "] échoué sur " .. filepath .. " (Apotheosis mis à jour ?)")
        return false
    end
    ModTextFileSetContent(filepath, result)
    log.tmp_info("Patch [" .. label .. "] appliqué : " .. filepath)
    return true
end

local stones = {
    { id = "stone_unstable_teleport", perk = "TELEPORTITIS"            },
    { id = "stone_teleport",          perk = "TELEPORTITIS_DODGE"       },
    { id = "stone_big",               perk = "GENOME_MORE_HATRED"       },
    { id = "stone_love",              perk = "GENOME_MORE_LOVE"         },
    { id = "stone_blood",             perk = "VAMPIRISM"                },
    { id = "stone_bones",             perk = "PEACE_WITH_GODS"          },
    { id = "stone_explosion",         perk = "GLASS_CANNON"             },
    { id = "stone_gold",              perk = "GOLD_IS_FOREVER"          },
    { id = "stone_haste",             perk = "APOTHEOSIS_HASTE"         },
    { id = "stone_health",            perk = "SAVING_GRACE"             },
    { id = "stone_invisibility",      perk = "INVISIBILITY"             },
    { id = "stone_slime",             perk = "BLEED_SLIME"              },
    { id = "stone_toxic",             perk = "PROTECTION_RADIOACTIVITY" },
    { id = "stone_void",              perk = "APOTHEOSIS_VOID"          },
    { id = "stone_worm_blood",        perk = "REMOVE_FOG_OF_WAR"        },
}

local gfx_base    = "mods/blankStone/files/items_gfx/elemental_stone/"
local entity_base = "mods/blankStone/files/entities/elemental_stone/"

local function apply_patch_convert(new_inputs, new_outputs)
    local filepath = "mods/Apotheosis/files/scripts/misc/perk_creation_convert.lua"
    local content = ModTextFileGetContent(filepath)

    local result, c1 = content:gsub(
        '"mods/Apotheosis/files/items_gfx/goldnugget_01_alt_radar.png", %-%-Guiding Stone',
        '"mods/Apotheosis/files/items_gfx/goldnugget_01_alt_radar.png", --Guiding Stone\n' .. new_inputs
    )
    local result2, c2 = result:gsub(
        '"APOTHEOSIS_PLANE_RADAR",',
        '"APOTHEOSIS_PLANE_RADAR",\n' .. new_outputs
    )

    if c1 == 0 or c2 == 0 then
        log.tmp_warn("Patch [perk_creation_convert] échoué sur " .. filepath .. " (Apotheosis mis à jour ?)")
        return false
    end
    ModTextFileSetContent(filepath, result2)
    log.tmp_info("Patch [perk_creation_convert] appliqué : " .. filepath)
    return true
end

local function apply_reforge_tags(reforge_perks)
    for _, path in pairs(reforge_perks) do
        local content = ModTextFileGetContent(path .. ".xml")
        local xml = nxml.parse(content)
        local modified = false

        local root = xml
        if root.attr.tags then
            if not root.attr.tags:find("blankStone_perk_reforge") then
                root.attr.tags = root.attr.tags .. ",blankStone_perk_reforge"
                modified = true
            else
                log.tmp_warn("Tag blankStone_perk_reforge déjà présent : " .. path)
            end
        else
            root.attr.tags = "blankStone_perk_reforge"
            modified = true
        end

        if modified then
            ModTextFileSetContent(path .. ".xml", tostring(xml))
        end
    end
end

function ApplyApotheosisPatches()
    local new_inputs, new_outputs, reforge_perks = "", "", {}
    for _, stone in ipairs(stones) do
        new_inputs  = new_inputs  .. '    "' .. gfx_base .. stone.id .. '.png",\n'
        new_outputs = new_outputs .. '    "' .. stone.perk .. '",\n'
        table.insert(reforge_perks, entity_base .. stone.id)
    end

    apply_patch(
        "mods/Apotheosis/files/scripts/buildings/perk_creation_initial.lua",
        '"poopstone",',
        '"poopstone",\n"blankStone_perk_reforge",',
        "perk_creation_initial"
    )
    apply_patch(
        "mods/Apotheosis/files/scripts/buildings/perk_creation.lua",
        '"poopstone",',
        '"poopstone",\n"blankStone_perk_reforge",',
        "perk_creation"
    )
    apply_patch_convert(new_inputs, new_outputs)
    apply_reforge_tags(reforge_perks)
end

return { ApplyApotheosisPatches = ApplyApotheosisPatches }