local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )


for _,id in pairs(EntityGetInRadiusWithTag(pos_x, pos_y, 70, "item_pickup")) do
	-- make sure item is not carried in inventory or wand
	if EntityGetRootEntity(id) == id then
		local x,y = EntityGetTransform(entity_id)
		EntityLoad("mods/blankStone/files/entities/blank_stone.xml", x, y - 5)
		EntityLoad("data/entities/projectiles/explosion.xml", x, y - 10)
		EntityKill(id)
		converted = true
	end
end