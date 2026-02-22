local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

DEFAULT_STONE = "mods/blankStone/files/entities/blank_stone.xml"

local function load_purified_stone(entity_id,x,y)
	local purifyInto= utils.getVariable(entity_id, "purifyInto")
	local stone
	if (not purifyInto) then
		log.warn("Missing \"purifyInto\" variable")
		stone = DEFAULT_STONE
	else
		stone = utils.getValue(purifyInto,"value_string")
	end
	EntityLoad(stone, x, y - 5)
end

function material_area_checker_success(pos_x, pos_y)
	log.debug("Purify stone activated")
	local entity_id = GetUpdatedEntityID()
	log.debug("Entity ID: " .. tostring(entity_id))
	for _,id in pairs(EntityGetInRadiusWithTag(pos_x, pos_y, 10, "item_pickup")) do
		log.debug("Found item entity ID: " .. tostring(id))
		-- make sure item is not carried in inventory or wand
		if EntityGetRootEntity(id) == id then
			log.debug("EntityToPurify: " .. tostring(id))
			local x,y = EntityGetTransform(entity_id)
			load_purified_stone(entity_id,x,y)
			EntityLoad("data/entities/projectiles/explosion.xml", x, y - 10)
			EntityKill(id)
		end
	end
end
