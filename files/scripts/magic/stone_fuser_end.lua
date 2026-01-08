dofile_once("data/scripts/lib/utilities.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )


-- Fonction principale à appeler
local function fuseCrafting()
    return stone_factory.tryAllFuse(x, y, craft.FUSE_RECIPES)
end

if(fuseCrafting()) then
    log.debug("Fuse success")
else
    log.debug("Fuse fail")
    GamePrint("$text_blankstone_fuse_fail")
end