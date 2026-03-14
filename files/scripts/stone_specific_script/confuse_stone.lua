local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

-- confusion immunity

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

EntityRemoveStainStatusEffect(player_id,"CONFUSION",5)