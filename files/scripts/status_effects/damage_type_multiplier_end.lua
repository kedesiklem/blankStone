local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
local pos_x, pos_y = EntityGetTransform(target)

local c = EntityLoad("mods/blankStone/files/entities/misc/effect_damage_type_multiplier_temporary_remove.xml", pos_x, pos_y)

local instance_name = EntityGetName(entity_id)

local material_info = utils.getVariable(entity_id, "damage_type")
local type = utils.getValue(material_info, "value_string")
local damage_mult = utils.getValue(material_info, "value_float")

local new_dmg_info = utils.getVariable(entity_id, "new_mult")
local new_mult = utils.getValue(new_dmg_info, "value_float")

if instance_name then
else
    log.error("no instance_name for ending")
end

-- data transfer
if type then
    utils.setVariable(c, "damage_type", "value_string", type)
    utils.setVariable(c, "damage_type", "value_float", damage_mult)
else
    log.error("damage_type name not found")
end

utils.setVariable(c, "instance_name", "value_string", instance_name)

EntityAddChild(target, c)