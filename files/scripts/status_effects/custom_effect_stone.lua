local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local custom_info = utils.getVariable(entity_id, "custom_id")
local custom_id = utils.getValue(custom_info, "value_string")

local DEFAULT_WATCHDOG = 30

if entity_id ~= player_id and custom_id then
    local funcs = D[custom_id]
    local watchdog_frames = (funcs and funcs.watchdog_frames) or DEFAULT_WATCHDOG

    effect_status.give_effect_watchdog(
        entity_id,
        player_id,
        "mods/blankStone/files/entities/misc/effect_custom.xml",
        "blankstone_custom_" .. custom_id,
        watchdog_frames,
        "custom_effect_stone",
        function(effect_id)
            utils.setVariable(effect_id, "custom_id", "value_string", custom_id)
        end
    )
end