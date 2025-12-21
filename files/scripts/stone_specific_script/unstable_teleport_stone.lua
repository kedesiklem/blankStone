local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local worldsize = ModTextFileGetContent("data/compatibilitydata/worldsize.txt") or 35840

local function tp_random()
	local player = EntityGetRootEntity(GetUpdatedEntityID())
    local pos_x, pos_y = EntityGetTransform(player)

    local rand_x = Random(-30.0,30.0)
    local rand_y = Random(-30.0,30.0)
    local dice_roll = Random(30000.0)
    
    if(dice_roll <= 2)
    then rand_x = rand_x + worldsize
    elseif (dice_roll <= 4) 
    then rand_x = rand_x - worldsize
    end

    EntitySetTransform(player, pos_x + rand_x, pos_y + rand_y)
end

function kick()
    if (EntityGetComponent(GetUpdatedEntityID(), "LuaComponent", "enabled_in_hand"))
    then
        tp_random()
    end
end

if (EntityGetComponent(GetUpdatedEntityID(), "LuaComponent", "enabled_in_hand"))
then
    local dice_roll = Random(100.0)
    if (dice_roll <= 50) then
        tp_random()
    end
end