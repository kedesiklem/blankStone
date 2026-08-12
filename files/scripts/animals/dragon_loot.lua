local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")

local function lockPortal()
    GameAddFlagRun("blankstone_dragon_present")
end

local function unlockPortal()
    GameRemoveFlagRun("blankstone_dragon_present")
end

function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    local entity = GetUpdatedEntityID()
    local x, y = EntityGetTransform(entity)

    log.debug("spawn dragon magic liquid stone.")

    local stone = EntityLoad("mods/blankStone/files/entities/elemental_stone/stone_magic_liquid.xml", x, y)

    unlockPortal()
end

log.debug("dragon spawn.")
lockPortal()