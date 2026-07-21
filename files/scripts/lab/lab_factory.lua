-- based on Purgatory by Priskip

-- Point d'entrée unique du système lab
-- Rien d'autre ne devrait avoir besoin de dofile_once directement les
-- autres fichiers de lab/ (validator/state/item_io/display/feedback) :
-- tout passe par ici.

local utils      = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log         = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local validator    = dofile_once("mods/blankStone/files/scripts/lab/lab_validator.lua")
local state          = dofile_once("mods/blankStone/files/scripts/lab/lab_state.lua")
local item_io           = dofile_once("mods/blankStone/files/scripts/lab/lab_item_io.lua")
local display              = dofile_once("mods/blankStone/files/scripts/lab/lab_display.lua")
local feedback                = dofile_once("mods/blankStone/files/scripts/lab/lab_feedback.lua")

local MOD_PATH          = "mods/blankStone/files/"
local ROOT_PATH         = MOD_PATH .. "entities/lab/lab_root.xml"
local SLOT_PATH         = MOD_PATH .. "entities/lab/lab_slot.xml"
local TRASH             = MOD_PATH .. "entities/lab/lab_trash.xml"
local PORTAL            = MOD_PATH .. "entities/buildings/progress_portal.xml"
local TRIGGER_ENTER     = MOD_PATH .. "entities/progress/progress_enter_trigger.xml"
local PROGRESS          = MOD_PATH .. "entities/progress/progress.xml"


local INSTANCE_ID_VAR   = "blankStoneLabInstanceId"
local SLOT_INDEX_VAR    = "blankStoneLabSlotIndex"
local SLOT_MODE_VAR     = "blankStoneLabSlotMode"
local SLOT_TAG          = "blankStone_lab_slot"

local SLOT_SEARCH_RADIUS = 200 -- doit couvrir la scène la plus large

-- =============================================================================
-- Spawns déclenchés par les marqueurs (appelés uniquement depuis lab_markers.lua)
-- =============================================================================

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnRoot(x, y)
    log.info("lab_factory.spawnRoot @ " .. x .. "," .. y)
    return EntityLoad(ROOT_PATH, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnSlot(x, y)
    log.debug("lab_factory.spawnSlot @ " .. x .. "," .. y)
    return EntityLoad(SLOT_PATH, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnTrash(x, y)
    log.debug("lab_factory.spawnTrash @ " .. x .. "," .. y)
    return EntityLoad(TRASH, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnPortal(x, y)
    log.debug("lab_factory.spawnPortal @ " .. x .. "," .. y)
    return EntityLoad(PORTAL, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnTriggerEnter(x, y)
    log.debug("lab_factory.spawnTriggerEnter @ " .. x .. "," .. y)
    return EntityLoad(TRIGGER_ENTER, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnProgress(x, y)
    log.debug("lab_factory.spawnProgress @ " .. x .. "," .. y)
    return EntityLoad(PROGRESS, x, y)
end
-- =============================================================================
-- Restauration au chargement (appelée depuis buildings/lab_restore_appends.lua)
-- =============================================================================

--- Trouve tous les slots orphelins autour d'un lab_root, leur assigne un index
--- stable et déterministe (tri par position - la scène étant statique, l'ordre
--- ne change jamais d'une partie à l'autre), les rattache au root, puis
--- restaure le contenu sauvegardé de chacun.
--- @param root_entity number
local function restoreLab(root_entity)
    local x, y = EntityGetTransform(root_entity)
    local instance_id = utils.getOrCreateInstanceId(root_entity, INSTANCE_ID_VAR)

    local nearby = EntityGetInRadiusWithTag(x, y, SLOT_SEARCH_RADIUS, SLOT_TAG) or {}

    -- Tri déterministe : lecture haut-bas puis gauche-droite
    table.sort(nearby, function(a, b)
        local ax, ay = EntityGetTransform(a)
        local bx, by = EntityGetTransform(b)
        if ay ~= by then return ay < by end
        return ax < bx
    end)

    if #nearby == 0 then
        log.warn("lab_factory.restoreLab: aucun slot trouvé autour du lab " .. instance_id)
        return
    end

    for i, slot_id in ipairs(nearby) do
        local slot_index = i - 1

        -- Nettoyage défensif : tue une éventuelle vitrine déjà présente (rechargement)
        display.killDisplay(slot_id)

        utils.setVariable(slot_id, SLOT_INDEX_VAR, "value_int", slot_index)
        EntityAddChild(root_entity, slot_id)

        local content = state.getSlotContent(instance_id, slot_index)
        if content then
            display.spawnDisplay(slot_id, content)
            utils.setVariable(slot_id, SLOT_MODE_VAR, "value_string", "pick_up")
            feedback.onSlotFilled(slot_id, content)
        else
            utils.setVariable(slot_id, SLOT_MODE_VAR, "value_string", "place")
            feedback.onSlotEmptied(slot_id)
        end
    end

    log.info("lab_factory.restoreLab: " .. #nearby .. " slot(s) restauré(s) pour " .. instance_id)
end

-- =============================================================================
-- Interaction joueur (appelée depuis buildings/lab_slot_interact.lua et lab_slot_collision.lua)
-- =============================================================================

--- @param slot_id number
--- @return number root_id, string instance_id, number slot_index, string mode
local function getSlotContext(slot_id)
    local root_id = EntityGetRootEntity(slot_id)
    local instance_id = utils.getOrCreateInstanceId(root_id, INSTANCE_ID_VAR)
    local slot_index = utils.getValue(utils.getVariable(slot_id, SLOT_INDEX_VAR), "value_int") or 0
    local mode = utils.getValue(utils.getVariable(slot_id, SLOT_MODE_VAR), "value_string") or "place"
    return root_id, instance_id, slot_index, mode
end

--- Appelée quand le joueur appuie sur la touche d'interaction sur un slot.
--- @param slot_id number
local function interactSlot(slot_id)
    local root_id, instance_id, slot_index, mode = getSlotContext(slot_id)

    if mode == "place" then
        local held = utils.getActiveItem(utils.getPlayer())
        local ok, reason = validator.canStore(held)
        if not ok then
            feedback.onInvalidItem(slot_id, reason)
            return
        end

        local content = item_io.readContent(held)
        if not content then
            feedback.onInvalidItem(slot_id, "unreadable")
            return
        end

        state.setSlotContent(instance_id, slot_index, content)
        display.spawnDisplay(slot_id, content)
        EntityKill(held)

        utils.setVariable(slot_id, SLOT_MODE_VAR, "value_string", "pick_up")
        feedback.onSlotFilled(slot_id, content)

    elseif mode == "pick_up" then
        if not validator.hasFreeInventorySlot() then
            feedback.onInventoryFull(slot_id)
            return
        end

        local content = state.getSlotContent(instance_id, slot_index)
        if not content then
            log.warn("lab_factory.interactSlot: mode pick_up sans contenu sauvegardé (slot " .. slot_index .. ")")
            return
        end

        local x, y = EntityGetTransform(slot_id)
        item_io.createPickupEntity(content, x, y)
        display.killDisplay(slot_id)
        state.clearSlotContent(instance_id, slot_index)

        utils.setVariable(slot_id, SLOT_MODE_VAR, "value_string", "place")
        feedback.onSlotEmptied(slot_id)
    end
end

--- Appelée en continu tant que le joueur est au contact d'un slot (texte d'aide).
--- @param slot_id number
local function updateSlotHint(slot_id)
    local _, _, _, mode = getSlotContext(slot_id)

    if mode == "place" then
        local held = utils.getActiveItem(utils.getPlayer())
        local ok = validator.canStore(held)
        feedback.onHintPlace(slot_id, ok)
    else
        feedback.onHintPickup(slot_id, validator.hasFreeInventorySlot())
    end
end

return {
    spawnRoot           = spawnRoot,
    spawnSlot           = spawnSlot,
    spawnTrash          = spawnTrash,
    spawnPortal         = spawnPortal,
    spawnTriggerEnter   = spawnTriggerEnter,
    spawnProgress       = spawnProgress,
    restoreLab          = restoreLab,
    interactSlot        = interactSlot,
    updateSlotHint      = updateSlotHint,
}
