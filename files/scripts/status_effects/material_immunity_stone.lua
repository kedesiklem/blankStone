local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local WATCHDOG_FRAMES = 30
local EFFECT_PATH = "mods/blankStone/files/entities/misc/effect_custom.xml"

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local material_info = utils.getVariable(entity_id, "protected_material")
local materials_str = utils.getValue(material_info, "value_string")

local new_dmg_info = utils.getVariable(entity_id, "new_material_dmg")
local new_dmgs_str = new_dmg_info and utils.getValue(new_dmg_info, "value_string")

local cache_info = utils.getVariable(entity_id, "protected_material_dmgs")
if not cache_info then
    cache_info = EntityAddComponent(entity_id, "VariableStorageComponent", {
        name = "protected_material_dmgs",
        value_string = ""
    })
end
local cache_str = utils.getValue(cache_info, "value_string")
if cache_str == "" then cache_str = nil end

local function split(str, sep)
    local result = {}
    for part in str:gmatch("[^" .. sep .. "]+") do
        table.insert(result, part:match("^%s*(.-)%s*$"))
    end
    return result
end

if entity_id ~= player_id then
    if not materials_str then
        log.error("protected_material manquant")
        return
    end

    local materials = split(materials_str, ",")
    local new_dmgs  = new_dmgs_str and split(new_dmgs_str, ",") or {}
    for i = #new_dmgs + 1, #materials do new_dmgs[i] = "0" end

    local cached_dmgs = cache_str and split(cache_str, ",") or {}
    local cache_dirty = false

    for i, material_name in ipairs(materials) do
        if not cached_dmgs[i] or tonumber(cached_dmgs[i]) == 0 then
            cached_dmgs[i] = tostring(utils.EntityGetDamageFromMaterial(player_id, material_name))
            cache_dirty = true
        end
    end

    if cache_dirty then
        utils.setValue(cache_info, "value_string", table.concat(cached_dmgs, ","))
    end

    for i, material_name in ipairs(materials) do
        local original_dmg = tonumber(cached_dmgs[i]) or 0
        local new_dmg       = tonumber(new_dmgs[i]) or 0

        effect_status.give_effect_watchdog(
            entity_id,
            player_id,
            EFFECT_PATH,
            "blankstone_protection_" .. material_name,
            WATCHDOG_FRAMES,
            "material_immunity_stone",
            function(effect_id)
                utils.setVariable(effect_id, "custom_id", "value_string", "MATERIAL_IMMUNITY")
                utils.setVariable(effect_id, "data", "value_string",
                    utils.serializeData({ material = material_name, original_dmg = original_dmg, new_dmg = new_dmg }))
            end
        )
    end
end