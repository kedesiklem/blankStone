local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local MODID = "BlankStone"
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local SF = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local SR = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")

local function redning()
    local entity_id = GetUpdatedEntityID()
    local x,y = EntityGetTransform(entity_id)

    local _ = SF.createStone(SR["rubedo"],x,y)
    EntityKill(entity_id)
end
redning()