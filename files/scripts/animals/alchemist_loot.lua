local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")


local function lockPortal()
    GameAddFlagRun("blankstone_alchemist_present")
end

local function unlockPortal()
    GameRemoveFlagRun("blankstone_alchemist_present")
end

function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    local entity = GetUpdatedEntityID()
    local x, y = EntityGetTransform(entity)

    log.debug("spawn alchemist blankStone.")

    local stone = EntityLoad("mods/blankStone/files/entities/blank_stone.xml", x, y)

    U.changeDescription(stone,"$text_blankstone_alchemist_stone_desc")

    unlockPortal()
end

log.debug("alchemist spawn.")
lockPortal()