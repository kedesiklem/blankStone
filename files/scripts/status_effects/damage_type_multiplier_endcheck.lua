local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

dofile_once("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
if target == 0 then return end

local c_check = false

local instance_name = utils.getValue(utils.getVariable(entity_id, "instance_name"), "value_string")

local damage_type_info = utils.getVariable(entity_id, "damage_type")
local damage_type = utils.getValue(damage_type_info, "value_string")
local damage_mult = utils.getValue(damage_type_info, "value_float")

if instance_name then
    log.info("endcheck info : " .. instance_name .. "[damage_type:".. damage_type .."[".. damage_mult .."]]")
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
        local comp = EntityGetFirstComponentIncludingDisabled( target, "DamageModelComponent" )
        if comp then
            ComponentObjectSetValue2(comp, "damage_multipliers", damage_type, damage_mult)
        else
            log.error("No DamageModelComponent found for damage_type_multiplier_start")
        end
    end
end

EntityKill(entity_id)