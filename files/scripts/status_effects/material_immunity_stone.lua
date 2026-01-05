local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local material_info = utils.getVariable(entity_id, "protected_material")
local material_name = utils.getValue(material_info, "value_string")
local material_dmg = utils.getValue(material_info, "value_float")

local new_dmg_info = utils.getVariable(entity_id, "new_material_dmg")
local new_dmg_value
if new_dmg_info then
    new_dmg_value = utils.getValue(new_dmg_info, "value_float") -- Utiliser value_float
else
    new_dmg_value = 0
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
    utils.setVariable(effect_id, "new_material_dmg", "value_float", new_dmg) -- Variable séparée


    EntityAddChild(id, effect_id)
    EntitySetName(effect_id, effect_name)

    log.debug("status effect generated : " .. effect_id .. " [" .. material .. ": " .. original_dmg .. " -> " .. new_dmg .. "]")
end

if(entity_id ~= player_id) then
    if material_dmg == 0 then
        material_dmg = utils.EntityGetDamageFromMaterial(player_id, material_name)
        utils.setValue(material_info, "value_float", material_dmg)
    end

    change_material_damage(player_id, material_name, material_dmg, new_dmg_value, true)
end