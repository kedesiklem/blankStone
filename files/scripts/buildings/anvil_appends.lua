local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")


local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)

-- convert items
local converted_blankStone = false

local forgables = EntityGetInRadiusWithTag(pos_x, pos_y, 70, "forgeable") or {}
for k=1,#forgables do
	local v = forgables[k]
	local x,y = EntityGetTransform(v)

    if v == EntityGetRootEntity(v) then
        if(stone_factory.forgeStone(v,x,y)) then
            EntityLoad("data/entities/projectiles/explosion.xml", x, y - 10)
            EntityKill(v)
        end
    end
end


if converted_blankStone then
	GameTriggerMusicFadeOutAndDequeueAll( 3.0 )
	GameTriggerMusicEvent( "music/oneshot/dark_01", true, pos_x, pos_y )
end