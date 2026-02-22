-- =============================================================================
--  controller.lua
--  Point d'entrée du système StorageStone.
--  Appelé chaque frame depuis OnWorldPostUpdate() dans init.lua.
-- =============================================================================

local input   = dofile_once("mods/blankStone/files/scripts/storage_stone/input.lua")
local storage = dofile_once("mods/blankStone/files/scripts/storage_stone/storage.lua")
local gui     = dofile_once("mods/blankStone/files/scripts/storage_stone/gui.lua")

local Controller = {}

-- ---------------------------------------------------------------------------
--  Helpers privés
-- ---------------------------------------------------------------------------

local function is_storage_stone(entity_id)
    if not entity_id or entity_id == 0 then return false end
    local comps = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    for _, comp in ipairs(comps or {}) do
        if ComponentGetValue2(comp, "name") == "blankStoneStorage" then
            return true
        end
    end
    return false
end

local function get_active_item(player_id)
    local inv_comp = EntityGetFirstComponentIncludingDisabled(player_id, "Inventory2Component")
    if not inv_comp then return nil end
    local item = ComponentGetValue2(inv_comp, "mActiveItem")
    if not item or item == 0 then return nil end
    return EntityGetIsAlive(item) and item or nil
end

local function is_inventory_open(player_id)
    local comp = EntityGetFirstComponentIncludingDisabled(player_id, "InventoryGuiComponent")
    if comp then return ComponentGetValue2(comp, "mActive") end
    return false
end

-- ---------------------------------------------------------------------------
--  Masquage défensif des items stockés
--
--  Problème : quand Noita tient un item en main, il active récursivement les
--  composants tagués "enabled_in_hand" sur l'item ET tous ses children.
--  Les items stockés (children de la pierre) reçoivent ce traitement et se
--  réaffichent partiellement.
--
--  Solution : re-appliquer hide_entity() sur tous les items stockés à chaque
--  frame où la pierre est tenue. Le coût est minimal — dans la quasi-totalité
--  des frames rien ne change (setEnabled sur un composant déjà disabled est
--  un no-op côté moteur).
-- ---------------------------------------------------------------------------

local function rehide_stored_items(stone_id)
    for _, item in ipairs(storage.get_items(stone_id)) do
        storage.hide_entity(item)
    end
end

-- ---------------------------------------------------------------------------
--  Update — appelé depuis OnWorldPostUpdate()
-- ---------------------------------------------------------------------------

function Controller.update()
    local players = EntityGetWithTag("player_unit")
    if not players then return end

    for _, player_id in ipairs(players) do
        if not EntityGetIsAlive(player_id) then goto continue end

        local active_item = get_active_item(player_id)
        local stone_id    = (active_item and is_storage_stone(active_item))
                            and active_item or nil

        if stone_id then
            -- Re-masque les items que Noita aurait partiellement réactivés
            -- via le mécanisme "enabled_in_hand" appliqué aux children
            rehide_stored_items(stone_id)

            -- Pickup via touche configurable (G par défaut)
            if input.is_pickup_just_pressed() then
                storage.pickup_nearest(player_id, stone_id)
            end
        end

        -- GUI (s'affiche uniquement si inventaire ouvert + pierre en main)
        gui.draw(player_id, stone_id, is_inventory_open(player_id))

        ::continue::
    end
end

return Controller