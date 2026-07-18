local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)

local custom_id = utils.getValue(utils.getVariable(entity_id, "custom_id"), "value_string")
local data_str  = utils.getValue(utils.getVariable(entity_id, "data"), "value_string")

if custom_id ~= nil then
    local funcs = D[custom_id]
    if funcs ~= nil then
        funcs.func(target, utils.deserializeData(data_str))
    else
        log.error(custom_id .. " custom effect missing function")
    end
end