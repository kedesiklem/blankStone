local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
local pos_x, pos_y = EntityGetTransform(target)

local c = EntityLoad("mods/blankStone/files/entities/misc/effect_protection_material_temporary_remove.xml", pos_x, pos_y)

local instance_name = EntityGetName(entity_id)

local material_info = utils.getVariable(entity_id, "material")
local material_name = utils.getValue(material_info, "value_string")
local material_dmg = utils.getValue(material_info, "value_float")

local new_dmg_info = utils.getVariable(entity_id, "new_material_dmg")
local new_dmg = utils.getValue(new_dmg_info, "value_float")

if not instance_name then
    log.error("no instance_name for ending")
end

-- data transfer
if material_name then
    utils.setVariable(c, "material", "value_string", material_name)
    utils.setVariable(c, "material", "value_float", material_dmg)
    utils.setVariable(c, "new_material_dmg", "value_float", new_dmg)
else
    log.error("material name not found")
end

utils.setVariable(c, "instance_name", "value_string", instance_name)

EntityAddChild(target, c)