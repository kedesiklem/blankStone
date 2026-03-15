local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

local DEFAULT_WATCHDOG = 30

local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
local pos_x, pos_y = EntityGetTransform(target)

local c = EntityLoad("mods/blankStone/files/entities/misc/effect_custom_temporary_remove.xml", pos_x, pos_y)

local instance_name = EntityGetName(entity_id)

local custom_info = utils.getVariable(entity_id, "custom_id")
local custom_id = utils.getValue(custom_info, "value_string")

-- Lecture depuis le registre : fiable même quand l'entité est en train de mourir
local funcs = custom_id and D[custom_id]
local watchdog_frames = ( funcs and funcs.watchdog_frames ) or DEFAULT_WATCHDOG

if not instance_name then
    log.error("no instance_name for ending")
end

if custom_id then
    utils.setVariable(c, "custom_id", "value_string", custom_id)
else
    log.error("custom_id name not found")
end

utils.setVariable(c, "instance_name", "value_string", instance_name)

-- Configure temporary_remove en fonction du watchdog de cet effet
local effect_comp = EntityGetFirstComponentIncludingDisabled(c, "GameEffectComponent")
if effect_comp then
    ComponentSetValue2(effect_comp, "frames", watchdog_frames + 5)
end

local lua_comp = EntityGetFirstComponentIncludingDisabled(c, "LuaComponent")
if lua_comp then
    ComponentSetValue2(lua_comp, "execute_every_n_frame", watchdog_frames + 2)
    ComponentSetValue2(lua_comp, "mNextExecutionTime", GameGetFrameNum() + watchdog_frames + 2)
end

EntityAddChild(target, c)