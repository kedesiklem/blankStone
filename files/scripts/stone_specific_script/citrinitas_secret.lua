local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local MODID = "BlankStone"
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local SF = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local SR = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")

local function redning()
    local entity_id = GetUpdatedEntityID()
    local x,y = EntityGetTransform(entity_id)

    local R = SF.createStone(SR["rubedo"],x,y)
    EntityKill(entity_id)
    return R
end

function kick( entity_who_kicked )
    redning()
end

function interacting( entity_who_interacted, entity_interacted, interactable_name )
    redning()
end

function item_pickup( entity_item, entity_pickupper, item_name )
    local R = redning()
    GamePickUpInventoryItem(entity_pickupper, R)
end