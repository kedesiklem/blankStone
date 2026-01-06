local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local damage_type_info = utils.getVariable(entity_id, "protected_damage_type")
local damage_type = utils.getValue(damage_type_info, "value_string")
local damage_mult = utils.getValue(damage_type_info, "value_float")

local new_dmg_info = utils.getVariable(entity_id, "new_mult")
local new_damage_mult
if new_dmg_info then
    new_damage_mult = utils.getValue(new_dmg_info, "value_float") -- Utiliser value_float
else
    new_damage_mult = 0
end

local function change_damage_type_multiplier(id, type, original_mult, new_dmg, check)
    local effect_path = "mods/blankStone/files/entities/misc/effect_damage_type_multiplier.xml"
    local effect_name = "blankstone_damage_type_protection_" .. type

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

    utils.setVariable(effect_id, "damage_type", "value_string", type)
    utils.setVariable(effect_id, "damage_type", "value_float", original_mult)
    utils.setVariable(effect_id, "new_damage_mult", "value_float", new_dmg) -- Variable séparée


    EntityAddChild(id, effect_id)
    EntitySetName(effect_id, effect_name)

end

if(entity_id ~= player_id) then
    if damage_mult == 0 then
        local comp = EntityGetFirstComponentIncludingDisabled( player_id, "DamageModelComponent" )
        if comp then
            damage_mult = ComponentObjectGetValue2(comp, "damage_multipliers", damage_type)
        else
            log.error("No DamageModelComponent found for damage_type_multiplier_stone")
        end
        utils.setValue(damage_type_info, "value_float", damage_mult)
    end

    change_damage_type_multiplier(player_id, damage_type, damage_mult, new_damage_mult, true)
end