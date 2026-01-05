local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)

local variables = EntityGetComponent( entity_id, "VariableStorageComponent" )

if (variables ~= nil) then
    local material_name = nil
    local material_dmg = nil
    local new_dmg = nil
    
    for _, v in ipairs(variables) do
        local name = ComponentGetValue2(v, "name")
        
        if (name == "material") then
            material_name = ComponentGetValue2(v, "value_string")
            material_dmg = ComponentGetValue2(v, "value_float")
            ComponentSetValue2(v, "value_float", material_dmg)
        elseif (name == "new_material_dmg") then
            new_dmg = ComponentGetValue2(v, "value_float")
        end
    end
    
    if material_name and material_dmg ~= nil and new_dmg ~= nil then
        log.info("Applying material protection: " .. material_name .. " [" .. material_dmg .. " -> " .. new_dmg .. "]")
        EntitySetDamageFromMaterial(target, material_name, new_dmg)
    end
end