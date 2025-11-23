local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger


function material_area_checker_success(pos_x, pos_y)
	local entity_id    = GetUpdatedEntityID()
	log.info("purify")
	for _,id in pairs(EntityGetInRadiusWithTag(pos_x, pos_y, 70, "item_pickup")) do
		-- make sure item is not carried in inventory or wand
		if EntityGetRootEntity(id) == id then
			local x,y = EntityGetTransform(entity_id)
			EntityLoad("mods/blankStone/files/entities/blank_stone.xml", x, y - 5)
			EntityLoad("data/entities/projectiles/explosion.xml", x, y - 10)
			EntityKill(id)
		end
	end
end
