local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

dofile_once("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
if target == 0 then return end

local c_check = false

local instance_name = utils.getValue(utils.getVariable(entity_id, "instance_name"), "value_string")

local custom_info = utils.getVariable(entity_id, "custom_id")
local custom_id = utils.getValue(custom_info, "value_string")

if not instance_name then
    log.error("no instance_name endcheck")
end

local children = EntityGetAllChildren(target)
if children then
    for k=1,#children
    do local v = children[k]
        if EntityGetName(v) == instance_name then
            c_check = true
        end
    end
end

if c_check ~= true then
    if custom_id ~= nil then
        log.info(custom_id .. " effect removed")

        local funcs = D[custom_id]
        if funcs ~= nil then
            funcs.func_remove(target)
        else
            log.error(custom_id .. " custom effect missing function")
        end
    end
end

EntityKill(entity_id)