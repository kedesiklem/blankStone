local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local material_info = utils.getVariable(entity_id, "protected_material")
local materials_str = utils.getValue(material_info, "value_string")

local new_dmg_info = utils.getVariable(entity_id, "new_material_dmg")
local new_dmgs_str
if new_dmg_info then
    new_dmgs_str = utils.getValue(new_dmg_info, "value_string")
end

-- Cache original damage, created dynamically if absent
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

local function change_material_damage(id, material, original_dmg, new_dmg, check)
    local effect_path = "mods/blankStone/files/entities/misc/effect_protection_material.xml"
    local effect_name = "blankstone_protection_" .. material

    if check then
        local children = EntityGetAllChildren(id) or {}
        for _, child_id in ipairs(children) do
            local name = EntityGetName(child_id)
            if name == effect_name then
                return
            end
        end
    end

    local x, y = EntityGetTransform(id)
    local effect_id = EntityLoad(effect_path, x, y)

    utils.setVariable(effect_id, "material", "value_string", material)
    utils.setVariable(effect_id, "material", "value_float", original_dmg)
    utils.setVariable(effect_id, "new_material_dmg", "value_float", new_dmg)

    EntityAddChild(id, effect_id)
    EntitySetName(effect_id, effect_name)
end

if(entity_id ~= player_id) then
    if not materials_str then
        log.error("protected_material manquant")
        return
    end

    local materials = split(materials_str, ",")
    local new_dmgs  = new_dmgs_str and split(new_dmgs_str, ",") or {}

    -- Missing new_dmg values filled in with 0
    for i = #new_dmgs + 1, #materials do
        new_dmgs[i] = "0"
    end

    -- Reading or initializing the original damage cache
    local cached_dmgs = cache_str and split(cache_str, ",") or {}
    local cache_dirty = false

    for i, material_name in ipairs(materials) do
        if not cached_dmgs[i] or tonumber(cached_dmgs[i]) == 0 then
            cached_dmgs[i] = tostring(utils.EntityGetDamageFromMaterial(player_id, material_name))
            cache_dirty = true
        end
    end

    -- Save cache on stone entity if updated
    if cache_dirty and cache_info then
        utils.setValue(cache_info, "value_string", table.concat(cached_dmgs, ","))
    end

    for i, material_name in ipairs(materials) do
        local original_dmg = tonumber(cached_dmgs[i]) or 0
        local new_dmg      = tonumber(new_dmgs[i])   or 0

        change_material_damage(player_id, material_name, original_dmg, new_dmg, true)
    end
end