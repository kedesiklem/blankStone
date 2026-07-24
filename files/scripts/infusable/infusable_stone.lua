local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local INFUSABLE_EFFECT_NAME = "blankstone_infusable"
local SUCK_EFFECT_NAME = "blankstone_liquid_suck"
local INFUSABLE_WATCHDOG_FRAMES = 20

local function applyInfusable()
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

function material_area_checker_success(pos_x, pos_y)
    applyInfusable()
end


local function applyInfuseSuck(entity_who_kicked)
    local stone_id = GetUpdatedEntityID()

    if EntityGetRootEntity(stone_id) ~= stone_id then
        log.debug("kick ignoré : la pierre n'est pas libre dans le monde (id=" .. tostring(stone_id) .. ")")
        return
    end

    local children = EntityGetAllChildren(stone_id)
    if children then
        for _, child in pairs(children) do
            if EntityGetName(child) == SUCK_EFFECT_NAME then
                log.debug("kick ignoré : une aspiration est déjà en cours sur " .. tostring(stone_id))
                return
            end
        end
    end

    log.info("Pierre " .. tostring(stone_id) .. " kickée par " .. tostring(entity_who_kicked) .. ", lancement d'une tentative d'aspiration de liquide")

    local pos_x, pos_y = EntityGetTransform(stone_id)
    local suck_id = EntityLoad("mods/blankStone/files/entities/misc/infusable_liquid_suck.xml", pos_x, pos_y)
    EntityAddChild(stone_id, suck_id)
    log.debug("Entité d'aspiration " .. tostring(suck_id) .. " créée sur " .. tostring(stone_id))
end

function kick(entity_who_kicked)
    applyInfuseSuck(entity_who_kicked)
end

function item_pickup(entity_item, entity_pickupper, item_name)
    local stone_id = GetUpdatedEntityID()
    local children = EntityGetAllChildren(stone_id) or {}
    for _, child in ipairs(children) do
        local name = EntityGetName(child)
        if name == INFUSABLE_EFFECT_NAME or name == SUCK_EFFECT_NAME then
            EntityKill(child)
        end
    end
end