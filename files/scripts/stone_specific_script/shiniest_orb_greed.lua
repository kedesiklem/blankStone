local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local EFFECT_PATH = "mods/blankStone/files/entities/misc/effect_extra_money.xml"
local WATCHDOG_FRAMES = 30

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

if entity_id ~= player_id and player_id then
    local instance_id = utils.getOrCreateInstanceId(entity_id, "extra_money_instance_id")

    local greed_info = utils.getVariable(entity_id, "greed_count")
    local greed = greed_info and tonumber(utils.getValue(greed_info, "value_int")) or 1

    for i = 1, greed do
        effect_status.give_effect_watchdog(
            entity_id,
            player_id,
            EFFECT_PATH,
            "blankstone_extra_money_" .. instance_id .. "_" .. i,
            WATCHDOG_FRAMES,
            "shiniest_orb_greed"
        )
    end
end