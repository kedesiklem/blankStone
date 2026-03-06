local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local tp = dofile_once("mods/blankStone/files/scripts/stone_specific_script/tp_stone_util.lua")

function kick()
    -- Check if the LuaComponent is disable to prevent tp when stone in_inventory
    local stone = GetUpdatedEntityID()
    if not(EntityGetComponent(stone, "LuaComponent", "enabled_in_hand")) then return end
    tp.tp_to_cursor()
end