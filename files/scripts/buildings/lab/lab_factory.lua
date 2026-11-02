-- based on Purgatory by Priskip

-- Point d'entrée unique du système lab
-- Rien d'autre ne devrait avoir besoin de dofile_once directement les
-- autres fichiers de lab/ (validator/state/item_io/display/feedback) :
-- tout passe par ici.

local utils      = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log         = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local validator    = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_validator.lua")
local state          = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_state.lua")
local item_io           = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_item_io.lua")
local display              = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_display.lua")
local feedback                = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_feedback.lua")

local MOD_PATH          = "mods/blankStone/files/"
local ROOT_PATH         = MOD_PATH .. "entities/lab/lab_root.xml"
local SLOT_PATH         = MOD_PATH .. "entities/lab/lab_slot.xml"
local SLOT_PERMA_PATH   = MOD_PATH .. "entities/lab/lab_slot_perma.xml"
local SLOT_CYCLE_PATH   = MOD_PATH .. "entities/lab/lab_slot_cycle.xml"
local CYCLE_BUTTON_PATH = MOD_PATH .. "entities/lab/lab_cycle_button.xml"
local TRASH             = MOD_PATH .. "entities/lab/lab_trash.xml"
local PORTAL_ALCHEMIST  = MOD_PATH .. "entities/buildings/progress2alchemist_portal.xml"
local PORTAL_DRAGON     = MOD_PATH .. "entities/buildings/progress2dragon_portal.xml"
local TRIGGER_ENTER     = MOD_PATH .. "entities/progress/progress_enter_trigger.xml"
local PROGRESS          = MOD_PATH .. "entities/progress/progress.xml"


local INSTANCE_ID_VAR   = "blankStoneLabInstanceId"
local SLOT_INDEX_VAR    = "blankStoneLabSlotIndex"
local SLOT_MODE_VAR     = "blankStoneLabSlotMode"
local SLOT_TAG          = "blankStone_lab_slot"
local SLOT_CYCLE_TAG    = "blankStone_lab_slot_cycle"

local CYCLE_BUTTON_RADIUS = 48 -- rayon de recherche du slot cycle depuis le bouton


-- Présent uniquement sur un slot "permanent" (cf lab_slot_permanent.xml).
-- Un simple booléen, pas une clé à choisir/rendre unique à la main : la clé
-- de stockage effective est dérivée automatiquement de slot_index (déjà
-- déterministe, cf restoreLab plus bas - tri par position, stable d'une
-- partie à l'autre car il ne dépend que de l'agencement RELATIF des slots
-- dans la pièce, pas de sa position absolue dans le monde généré). Un seul
-- lab_root.xml gère indifféremment des slots "run" et "permanent" mélangés :
-- rien à changer côté root, la distinction est entièrement portée par le slot.
local PERMANENT_FLAG_VAR = "blankStoneLabPermanent"

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

--- Slot permanent : même root, même famille de slots (SLOT_TAG identique),
--- seule la persistance change - cf PERMANENT_FLAG_VAR.
--- @param x number
--- @param y number
--- @return number entity_id
local function spawnSlotPerma(x, y)
    log.debug("lab_factory.spawnSlotPerma @ " .. x .. "," .. y)
    return EntityLoad(SLOT_PERMA_PATH, x, y)
end

--- Slot de transmutation (cf lab_slot_cycle.xml).
--- @param x number
--- @param y number
--- @return number entity_id
local function spawnSlotCycle(x, y)
    log.debug("lab_factory.spawnSlotCycle @ " .. x .. "," .. y)
    return EntityLoad(SLOT_CYCLE_PATH, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnCycleButton(x, y)
    log.debug("lab_factory.spawnCycleButton @ " .. x .. "," .. y)
    return EntityLoad(CYCLE_BUTTON_PATH, x, y)
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
local function spawnPortalAlchemist(x, y)
    log.debug("lab_factory.spawnPortalAlchemist @ " .. x .. "," .. y)
    return EntityLoad(PORTAL_ALCHEMIST, x, y)
end

--- @param x number
--- @param y number
--- @return number entity_id
local function spawnPortalDragon(x, y)
    log.debug("lab_factory.spawnPortalDragon @ " .. x .. "," .. y)
    return EntityLoad(PORTAL_DRAGON, x, y)
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

--- @param slot_id number
--- @param slot_index number
--- @return string|nil  nil si le slot n'est pas marqué permanent
local function computePermanentKey(slot_id, slot_index)
    local is_permanent = utils.getValue(utils.getVariable(slot_id, PERMANENT_FLAG_VAR), "value_bool")
    if not is_permanent then return nil end
    return "slot_" .. tostring(slot_index)
end

--- Trouve tous les slots orphelins autour d'un lab_root, leur assigne un index
--- stable et déterministe (tri par position - la scène étant statique, l'ordre
--- ne change jamais d'une partie à l'autre), les rattache au root, puis
--- restaure le contenu sauvegardé de chacun (permanent ou par run selon le slot).
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

        local permanent_key = computePermanentKey(slot_id, slot_index)
        if permanent_key then
            state.warnIfDuplicateKey(permanent_key, slot_id)
        end

        local content = state.getSlotContent(instance_id, slot_index, permanent_key)
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
--- @return number root_id, string instance_id, number slot_index, string mode, string|nil permanent_key
local function getSlotContext(slot_id)
    local root_id = EntityGetRootEntity(slot_id)
    local instance_id = utils.getOrCreateInstanceId(root_id, INSTANCE_ID_VAR)
    local slot_index = utils.getValue(utils.getVariable(slot_id, SLOT_INDEX_VAR), "value_int") or 0
    local mode = utils.getValue(utils.getVariable(slot_id, SLOT_MODE_VAR), "value_string") or "place"
    local permanent_key = computePermanentKey(slot_id, slot_index)
    return root_id, instance_id, slot_index, mode, permanent_key
end

--- mActualActiveItem reste sur un objet de l'inventaire même main vide (slot
--- vide sélectionné) : on ne considère l'objet tenu que si un de ses
--- composants propres à la main (tag enabled_in_hand sans enabled_in_inventory)
--- est actif.
--- @param item_entity number
--- @return boolean
local function isInHand(item_entity)
    for _, comp in ipairs(EntityGetAllComponents(item_entity) or {}) do
        if ComponentHasTag(comp, "enabled_in_hand")
            and not ComponentHasTag(comp, "enabled_in_inventory")
            and ComponentGetIsEnabled(comp) then
            return true
        end
    end
    return false
end

--- @return number|nil item  objet réellement tenu en main, nil si main vide
local function getHeldItem()
    local item = utils.getActiveItem(utils.getPlayer())
    if item and isInHand(item) then return item end
    return nil
end

--- Validateur selon le type de slot (cycle = transmutation, sinon standard).
--- @param slot_id number
--- @param held number|nil
--- @return boolean ok, string|nil reason
local function canStoreIn(slot_id, held)
    if EntityHasTag(slot_id, SLOT_CYCLE_TAG) then
        return validator.canStoreCycle(held)
    end
    return validator.canStore(held)
end

--- Appelée quand le joueur appuie sur la touche d'interaction sur un slot.
--- @param slot_id number
local function interactSlot(slot_id)
    local root_id, instance_id, slot_index, mode, permanent_key = getSlotContext(slot_id)

    if mode == "place" then
        local held = getHeldItem()
        local ok, reason = canStoreIn(slot_id, held)
        if not ok then
            feedback.onInvalidItem(slot_id, reason)
            return
        end

        local content = item_io.readContent(held)
        if not content then
            feedback.onInvalidItem(slot_id, "unreadable")
            return
        end

        state.setSlotContent(instance_id, slot_index, content, permanent_key)
        display.spawnDisplay(slot_id, content)
        EntityKill(held)

        utils.setVariable(slot_id, SLOT_MODE_VAR, "value_string", "pick_up")
        feedback.onSlotFilled(slot_id, content)

    elseif mode == "pick_up" then
        if not validator.hasFreeInventorySlot() then
            feedback.onInventoryFull(slot_id)
            return
        end

        local content = state.getSlotContent(instance_id, slot_index, permanent_key)
        if not content then
            log.warn("lab_factory.interactSlot: mode pick_up sans contenu sauvegardé (slot " .. slot_index .. ")")
            return
        end

        local x, y = EntityGetTransform(slot_id)
        item_io.createPickupEntity(content, x, y)
        display.killDisplay(slot_id)
        state.clearSlotContent(instance_id, slot_index, permanent_key)

        utils.setVariable(slot_id, SLOT_MODE_VAR, "value_string", "place")
        feedback.onSlotEmptied(slot_id)
    end
end

--- Appelée en continu tant que le joueur est au contact d'un slot (texte d'aide).
--- @param slot_id number
local function updateSlotHint(slot_id)
    local root_id, instance_id, slot_index, mode = getSlotContext(slot_id)

    if mode == "place" then
        local held = getHeldItem()
        local ok, reason = canStoreIn(slot_id, held)
        feedback.onHintPlace(slot_id, ok, reason)
    else
        feedback.onHintPickup(slot_id, validator.hasFreeInventorySlot())
    end
end

-- =============================================================================
-- Transmutation (appelée depuis lab_cycle_button_interact.lua)
-- =============================================================================

--- @param button_id number
--- @return number|nil slot_id  slot cycle le plus proche du bouton
local function findCycleSlot(button_id)
    local bx, by = EntityGetTransform(button_id)
    local best, best_d2 = nil, math.huge
    for _, slot_id in ipairs(EntityGetInRadiusWithTag(bx, by, CYCLE_BUTTON_RADIUS, SLOT_CYCLE_TAG) or {}) do
        local sx, sy = EntityGetTransform(slot_id)
        local d2 = (sx - bx) ^ 2 + (sy - by) ^ 2
        if d2 < best_d2 then best, best_d2 = slot_id, d2 end
    end
    return best
end

--- Transforme le contenu du slot cycle lié au bouton en l'élément suivant
--- du cycle (potion vide -> bourse vide -> blank stone -> potion vide).
--- @param button_id number
local function pressCycleButton(button_id)
    local slot_id = findCycleSlot(button_id)
    if not slot_id then
        log.warn("lab_factory.pressCycleButton: aucun slot cycle dans un rayon de " .. CYCLE_BUTTON_RADIUS .. " autour du bouton " .. button_id)
        feedback.onCycleFailed("no_slot")
        return
    end

    local _, instance_id, slot_index, mode, permanent_key = getSlotContext(slot_id)
    local content = mode == "pick_up" and state.getSlotContent(instance_id, slot_index, permanent_key) or nil
    if not content then
        feedback.onCycleFailed("slot_empty")
        return
    end

    local next_content = item_io.nextCycleContent(content)
    state.setSlotContent(instance_id, slot_index, next_content, permanent_key)
    display.killDisplay(slot_id)
    display.spawnDisplay(slot_id, next_content)
    feedback.onSlotFilled(slot_id, next_content)
end

return {
    spawnRoot           = spawnRoot,
    spawnSlot           = spawnSlot,
    spawnSlotPerma      = spawnSlotPerma,
    spawnSlotCycle      = spawnSlotCycle,
    spawnCycleButton    = spawnCycleButton,
    spawnTrash          = spawnTrash,
    spawnPortalAlchemist= spawnPortalAlchemist,
    spawnPortalDragon   = spawnPortalDragon,
    spawnTriggerEnter   = spawnTriggerEnter,
    spawnProgress       = spawnProgress,
    restoreLab          = restoreLab,
    interactSlot        = interactSlot,
    updateSlotHint      = updateSlotHint,
    pressCycleButton    = pressCycleButton,
    }