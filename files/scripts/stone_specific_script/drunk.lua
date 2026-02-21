local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

-- BRUNK DOUBLE VISION EFFECT
effect_status.give_effect(player_id, "mods/blankStone/files/entities/misc/effect_double_vision.xml", "blankstone_doublevision_effect", true)

utils.convert_all_liquid(entity_id, "alcohol")