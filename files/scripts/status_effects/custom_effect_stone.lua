local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local custom_info = utils.getVariable(entity_id, "custom_id")
local custom_id = utils.getValue(custom_info, "value_string")

local function load_custom_effect(id, type, check)
    local effect_path = "mods/blankStone/files/entities/misc/effect_custom.xml"
    local effect_name = "blankstone_custom_" .. type

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

    utils.setVariable(effect_id, "custom_id", "value_string", type)

    EntityAddChild(id, effect_id)
    EntitySetName(effect_id, effect_name)
end

if(entity_id ~= player_id) then
    load_custom_effect(player_id, custom_id, true)
end