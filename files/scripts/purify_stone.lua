local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")

--- Called by the MaterialAreaCheckerComponent of a purifiable entity
--- (see purifiable.xml) when purifying_powder is detected in its check
--- area. The Lua/MaterialAreaChecker components live on the purifiable
--- entity itself (not on a child), so GetUpdatedEntityID() always refers
--- to the exact stone being purified: no radius scan needed, and no risk
--- of one stone's "purifyInto" being applied to a neighbouring item.
function material_area_checker_success(pos_x, pos_y)
    local entity_id = GetUpdatedEntityID()

    -- Ignore entities currently held in an inventory or wand slot.
    if EntityGetRootEntity(entity_id) ~= entity_id then
        return
    end

    local x, y = EntityGetTransform(entity_id)
    log.debug("Purify stone activated on entity " .. tostring(entity_id))

    if stone_factory.purifyStone(entity_id, x, y) then
        -- Trigger-site VFX, same convention as the anvil (see anvil_appends.lua):
        -- the generic "conversion" explosion is independent from whatever
        -- VFX the produced stone itself has (see spawn_executor.lua).
        EntityLoad("data/entities/projectiles/explosion.xml", x, y - 10)
        EntityKill(entity_id)
    end
end
