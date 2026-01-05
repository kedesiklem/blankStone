local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

dofile_once("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
if target == 0 then return end

local c_check = false

local instance_name = utils.getValue(utils.getVariable(entity_id, "instance_name"), "value_string")

local material_info = utils.getVariable(entity_id, "material")
local material_name = utils.getValue(material_info, "value_string")
local material_dmg = utils.getValue(material_info, "value_float")

if instance_name then
    log.info("endcheck info : " .. instance_name .. "[material:".. material_name .."[".. material_dmg .."]]")
else
    log.error("no instance_name endcheck")
end

local children = EntityGetAllChildren(target)
if children then
    for k=1,#children
    do v = children[k]
        if EntityGetName(v) == instance_name then
            c_check = true
        end
    end
end

if c_check ~= true then
    if target ~= nil then
        log.info("protection removed")
        EntitySetDamageFromMaterial( target, material_name, material_dmg)
    end
end

EntityKill(entity_id)