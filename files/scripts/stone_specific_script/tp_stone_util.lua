local worldsize = ModTextFileGetContent("data/compatibilitydata/worldsize.txt") or 35840

local function tp_random()
	local player = EntityGetRootEntity(GetUpdatedEntityID())
    local pos_x, pos_y = EntityGetTransform(player)

    local rand_x = Random(-30.0,30.0)
    local rand_y = Random(-30.0,30.0)
    local dice_roll = Random(30000.0)

    -- Very small chance to tp to PW
    if(dice_roll <= 2)
    then rand_x = rand_x + worldsize
    elseif (dice_roll <= 4)
    then rand_x = rand_x - worldsize
    end

    EntitySetTransform(player, pos_x + rand_x, pos_y + rand_y)
end

local function tp_to_cursor()
    local player = EntityGetRootEntity(GetUpdatedEntityID())
    local sx,sy = DEBUG_GetMouseWorld()

    EntitySetTransform(player, sx, sy)
end

return {
    tp_random=tp_random,
    tp_to_cursor=tp_to_cursor
}