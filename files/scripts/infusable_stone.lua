local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local INFUSABLE_EFFECT_NAME = "blankstone_infusable"
local INFUSABLE_WATCHDOG_FRAMES = 20

function material_area_checker_success(pos_x, pos_y)
    local entity_id = GetUpdatedEntityID()
    local stone_id = EntityGetParent(entity_id)

    effect_status.give_effect_watchdog(
        stone_id,
        stone_id,
        "mods/blankStone/files/entities/misc/effect_infusable.xml",
        INFUSABLE_EFFECT_NAME,
        INFUSABLE_WATCHDOG_FRAMES,
        nil,
        nil
    )
end

function item_pickup(entity_item, entity_pickupper, item_name)
    local stone_id = GetUpdatedEntityID()
    local children = EntityGetAllChildren(stone_id) or {}
    for _, child in ipairs(children) do
        if EntityGetName(child) == INFUSABLE_EFFECT_NAME then
            EntityKill(child)
        end
    end
end