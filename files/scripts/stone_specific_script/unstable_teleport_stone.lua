local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local tp = dofile_once("mods/blankStone/files/scripts/stone_specific_script/tp_stone_util.lua")


function kick()
    if (EntityGetComponent(GetUpdatedEntityID(), "LuaComponent", "enabled_in_hand"))
    then
        tp.tp_random()
    end
end

if (EntityGetComponent(GetUpdatedEntityID(), "LuaComponent", "enabled_in_hand"))
then
    local dice_roll = Random(100.0)
    if (dice_roll <= 50) then
        tp.tp_random()
    end
end