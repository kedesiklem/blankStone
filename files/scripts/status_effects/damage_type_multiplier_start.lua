local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)

local variables = EntityGetComponent( entity_id, "VariableStorageComponent" )

if (variables ~= nil) then
    local damage_type = nil
    local damage_mult = nil
    local new_mult = nil
    
    for _, v in ipairs(variables) do
        local name = ComponentGetValue2(v, "name")
        
        if (name == "damage_type") then
            damage_type = ComponentGetValue2(v, "value_string")
            damage_mult = ComponentGetValue2(v, "value_float")
            ComponentSetValue2(v, "value_float", damage_mult)
        elseif (name == "new_mult") then
            new_mult = ComponentGetValue2(v, "value_float")
        end
    end
    
    if damage_type and damage_mult ~= nil and new_mult ~= nil then
        log.info("Applying damage_type protection: " .. damage_type .. " [" .. damage_mult .. " -> " .. new_mult .. "]")
        local comp = EntityGetFirstComponentIncludingDisabled( target, "DamageModelComponent" )
        if comp then
            ComponentObjectSetValue2(comp, "damage_multipliers", damage_type, new_mult)
        else
            log.error("No DamageModelComponent found for damage_type_multiplier_start")
        end
    end
end