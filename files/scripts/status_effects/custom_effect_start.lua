local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)

local variables = EntityGetComponent( entity_id, "VariableStorageComponent" )

if (variables ~= nil) then
    local custom_id = nil
    
    for _, v in ipairs(variables) do
        local name = ComponentGetValue2(v, "name")
        
        if (name == "custom_id") then
            custom_id = ComponentGetValue2(v, "value_string")
        end
    end
    
    if custom_id ~= nil then
        local funcs = D[custom_id]
        if funcs ~= nil then
            funcs.func(target)
        else
            log.error(custom_id .. " custom effect missing function")
        end
    end
end