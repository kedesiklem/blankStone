local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
local pos_x, pos_y = EntityGetTransform(target)

local c = EntityLoad("mods/blankStone/files/entities/misc/effect_custom_temporary_remove.xml", pos_x, pos_y)

local instance_name = EntityGetName(entity_id)

local custom_info = utils.getVariable(entity_id, "custom_id")
local custom_id = utils.getValue(custom_info, "value_string")

if not instance_name then
    log.error("no instance_name for ending")
end

-- data transfer
if custom_id then
    utils.setVariable(c, "custom_id", "value_string", custom_id)
else
    log.error("custom_id name not found")
end

utils.setVariable(c, "instance_name", "value_string", instance_name)

EntityAddChild(target, c)