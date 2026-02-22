-- =============================================================================
--  storage.lua
--  Couche données de la StorageStone.
--
--  Les items stockés sont des child-entities directes de la pierre.
--  Un item "stocké" est identifié par un VariableStorageComponent nommé
--  POSITION_VAR qui contient son indice de slot (1-based).
--
--  Aucune entité intermédiaire "inventory" n'est nécessaire ; Noita sauvegarde
--  la hiérarchie d'entités automatiquement, ce qui rend le stockage persistant.
-- =============================================================================

local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")


local POSITION_VAR    = "blankstone_storage_pos"    -- marqueur + position de slot
local CAPACITY_VAR    = "blankstone_storage_cap"    -- capacité overridable depuis le XML
local DEFAULT_CAPACITY = 8                          -- slots par défaut
local PICKUP_RADIUS    = 40                         -- pixels, touche G

-- Tags d'entités qu'on ne doit JAMAIS aspirer
local PICKUP_BLACKLIST = {
    "player_unit", "enemy", "boss_heart", "orb_stone", "projectile"
}

local Storage = {}

-- ---------------------------------------------------------------------------
--  Capacité
-- ---------------------------------------------------------------------------

--- Retourne la capacité du slot-storage de la pierre.
--- Peut être surchargée depuis le XML via un VariableStorageComponent nommé
--- "blankstone_storage_cap" avec un value_int.

function Storage.set_capacity(entity_id, new_cap)
    utils.setVariable(entity_id, CAPACITY_VAR, "value_int", new_cap)
end

function Storage.get_capacity(stone_id)
    local comp = utils.getVariable(stone_id, CAPACITY_VAR)
    if comp then
        local val = ComponentGetValue2(comp, "value_int")
        if val and val > 0 then return val end
    end
    return DEFAULT_CAPACITY
end


-- ---------------------------------------------------------------------------
--  Gestion des positions
-- ---------------------------------------------------------------------------

function Storage.get_item_position(entity_id)
    local comp = utils.getVariable(entity_id, POSITION_VAR)
    if comp then return ComponentGetValue2(comp, "value_int") end
    return nil
end

function Storage.set_item_position(entity_id, position)
    local comp = utils.getVariable(entity_id, POSITION_VAR)
    if comp then
        ComponentSetValue2(comp, "value_int", position)
    else
        EntityAddComponent2(entity_id, "VariableStorageComponent", {
            name      = POSITION_VAR,
            value_int = position,
        })
    end
end

function Storage.remove_item_position(entity_id)
    local comp = utils.getVariable(entity_id, POSITION_VAR)
    if comp then EntityRemoveComponent(entity_id, comp) end
end

-- ---------------------------------------------------------------------------
--  Inventaire de la pierre
-- ---------------------------------------------------------------------------

--- Retourne la liste des items stockés, triés par position de slot.
function Storage.get_items(stone_id)
    local children = EntityGetAllChildren(stone_id)
    if not children then return {} end

    local items = {}
    for _, child in ipairs(children) do
        -- Seuls les children avec POSITION_VAR sont des items stockés
        if EntityGetIsAlive(child) and Storage.get_item_position(child) ~= nil then
            table.insert(items, child)
        end
    end

    table.sort(items, function(a, b)
        local pa = Storage.get_item_position(a) or 9999
        local pb = Storage.get_item_position(b) or 9999
        return pa < pb
    end)
    return items
end

--- Retourne l'item au slot `position`, ou nil si vide.
function Storage.get_item_at_position(stone_id, position)
    local children = EntityGetAllChildren(stone_id)
    for _, child in ipairs(children or {}) do
        if EntityGetIsAlive(child) and Storage.get_item_position(child) == position then
            return child
        end
    end
    return nil
end

--- Retourne le premier slot libre (1-based), ou nil si plein.
function Storage.get_free_position(stone_id)
    local cap   = Storage.get_capacity(stone_id)
    local items = Storage.get_items(stone_id)
    local used  = {}
    for _, item in ipairs(items) do
        local p = Storage.get_item_position(item)
        if p then used[p] = true end
    end
    for i = 1, cap do
        if not used[i] then return i end
    end
    return nil
end

-- ---------------------------------------------------------------------------
--  Masquage / affichage (portage fidèle de BagOfMany)
-- ---------------------------------------------------------------------------

--- Désactive tous les composants sauf ceux tagués "enabled_in_inventory".
--- Appliqué récursivement aux children.
function Storage.hide_entity(entity_id)
    for _, comp in ipairs(EntityGetAllComponents(entity_id) or {}) do
        if not ComponentHasTag(comp, "enabled_in_inventory") then
            EntitySetComponentIsEnabled(entity_id, comp, false)
        end
    end
    for _, child in ipairs(EntityGetAllChildren(entity_id) or {}) do
        Storage.hide_entity(child)
    end
end

--- Réactive les composants tagués "enabled_in_world".
--- Réactive aussi les SpriteParticleEmitterComponent tagués "enabled_in_world".
function Storage.show_entity(entity_id)
    -- Réactivation des comps standards tagués enabled_in_world
    for _, comp in ipairs(EntityGetAllComponents(entity_id) or {}) do
        if ComponentHasTag(comp, "enabled_in_world") then
            -- Pour les SpriteComponent : ne pas réactiver "unidentified.png"
            local comp_type = ComponentGetTypeName(comp)
            if comp_type == "SpriteComponent" then
                local f = ComponentGetValue2(comp, "image_file")
                if f and not string.find(f, "unidentified") then
                    EntitySetComponentIsEnabled(entity_id, comp, true)
                end
            else
                EntitySetComponentIsEnabled(entity_id, comp, true)
            end
        end
    end
    -- SpriteParticleEmitter séparé (comme dans BagOfMany)
    local spe = EntityGetComponentIncludingDisabled(entity_id, "SpriteParticleEmitterComponent")
    for _, comp in ipairs(spe or {}) do
        if ComponentHasTag(comp, "enabled_in_world") then
            EntitySetComponentIsEnabled(entity_id, comp, true)
        end
    end
    -- Récursion
    for _, child in ipairs(EntityGetAllChildren(entity_id) or {}) do
        Storage.show_entity(child)
    end
end

-- ---------------------------------------------------------------------------
--  Store / Drop
-- ---------------------------------------------------------------------------

--- Stocke `item_id` dans la pierre. Retourne true si réussi.
function Storage.store(stone_id, item_id)
    if not EntityGetIsAlive(item_id) then return false end

    -- Déjà possédé par quelqu'un ?
    local parent = EntityGetParent(item_id)
    if parent and parent ~= 0 then return false end

    local pos = Storage.get_free_position(stone_id)
    if not pos then return false end  -- plein

    Storage.hide_entity(item_id)
    Storage.set_item_position(item_id, pos)
    EntityRemoveFromParent(item_id)
    EntityAddChild(stone_id, item_id)

    -- Téléporte à la position de la pierre (évite les positions fantômes)
    local sx, sy = EntityGetTransform(stone_id)
    EntitySetTransform(item_id, sx, sy)

    return true
end

--- Stocke `item_id` dans la pierre à un slot précis `pos`.
--- Utilisé par le drag vanilla→pierre pour placer l'item exactement là
--- où l'utilisateur l'a déposé. L'item doit déjà être retiré de son parent.
function Storage.store_at_position(stone_id, item_id, pos)
    if not EntityGetIsAlive(item_id) then return false end
    if not pos then return Storage.store(stone_id, item_id) end

    -- Si le slot cible est occupé, libérer d'abord en déplaçant l'occupant
    local occupant = Storage.get_item_at_position(stone_id, pos)
    if occupant and occupant ~= item_id then
        local free = Storage.get_free_position(stone_id)
        if free then
            Storage.set_item_position(occupant, free)
        else
            return false  -- plein, pas de place
        end
    end

    Storage.hide_entity(item_id)
    Storage.set_item_position(item_id, pos)
    EntityAddChild(stone_id, item_id)
    local sx, sy = EntityGetTransform(stone_id)
    EntitySetTransform(item_id, sx, sy)
    return true
end

--- Retire `item_id` de la pierre et le pose dans le monde, à la position
--- de la racine de la pierre (= généralement le joueur quand elle est tenue).
function Storage.drop(stone_id, item_id)
    if not item_id or not EntityGetIsAlive(item_id) then return end

    -- La racine de la pierre = le joueur quand la pierre est en main
    local root    = EntityGetRootEntity(stone_id)
    local rx, ry  = EntityGetTransform(root)

    Storage.remove_item_position(item_id)
    EntityRemoveFromParent(item_id)
    EntityApplyTransform(item_id, rx, ry - 5)
    Storage.show_entity(item_id)

    -- Réactiver InheritTransformComponent (comme drop_item_from_parent de BagOfMany)
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(item_id, "InheritTransformComponent") or {}) do
        EntitySetComponentIsEnabled(item_id, comp, true)
    end
    -- Réactiver les comps enabled_in_inventory
    for _, comp in ipairs(EntityGetAllComponents(item_id) or {}) do
        if ComponentHasTag(comp, "enabled_in_inventory") then
            EntitySetComponentIsEnabled(item_id, comp, true)
        end
    end
end

--- Déplace `item` vers `target_pos`, en swappant avec l'item qui s'y trouve.
function Storage.move_to_position(stone_id, item, target_pos)
    local occupant = Storage.get_item_at_position(stone_id, target_pos)
    if occupant and occupant ~= item then
        -- Swap
        local old_pos = Storage.get_item_position(item)
        Storage.set_item_position(occupant, old_pos)
        Storage.set_item_position(item, target_pos)
    else
        Storage.set_item_position(item, target_pos)
    end
end

-- ---------------------------------------------------------------------------
--  Sprite lookup (portage de get_sprite_file de BagOfMany)
-- ---------------------------------------------------------------------------

function Storage.get_sprite_file(entity_id)
    local fallback = "data/ui_gfx/gun_actions/unidentified.png"
    if not entity_id then return fallback end

    -- Spells / wands : SpriteComponent.image_file
    if EntityHasTag(entity_id, "card_action") then
        local comps = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
        if comps and comps[1] then
            local f = ComponentGetValue2(comps[1], "image_file")
            if f and f ~= "" then return f end
        end
    end

    -- Autres items : ItemComponent.ui_sprite (nos pierres utilisent ça)
    local item_comps = EntityGetComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comps and item_comps[1] then
        local ui_sprite = ComponentGetValue2(item_comps[1], "ui_sprite")
        if ui_sprite and ui_sprite ~= "" then return ui_sprite end
    end

    -- Fallback : SpriteComponent
    local sprite_comps = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
    if sprite_comps and sprite_comps[1] then
        local f = ComponentGetValue2(sprite_comps[1], "image_file")
        if f and f ~= "" and not string.find(f, "unidentified") then return f end
    end

    return fallback
end

--- Nom affiché (résout les clés "$...").
function Storage.get_item_name(entity_id)
    local comps = EntityGetComponentIncludingDisabled(entity_id, "ItemComponent")
    if comps and comps[1] then
        local name = ComponentGetValue2(comps[1], "item_name")
        if name and name ~= "" then
            return (name:sub(1,1) == "$") and (GameTextGet(name) or name) or name
        end
    end
    local uic = EntityGetFirstComponentIncludingDisabled(entity_id, "UIInfoComponent")
    if uic then
        local name = ComponentGetValue2(uic, "name")
        if name and name ~= "" then
            return (name:sub(1,1) == "$") and (GameTextGet(name) or name) or name
        end
    end
    return "?"
end

--- Description affichée (résout les clés "$...").
function Storage.get_item_desc(entity_id)
    local comps = EntityGetComponentIncludingDisabled(entity_id, "ItemComponent")
    if comps and comps[1] then
        local desc = ComponentGetValue2(comps[1], "ui_description")
        if desc and desc ~= "" then
            return (desc:sub(1,1) == "$") and (GameTextGet(desc) or desc) or desc
        end
    end
    return ""
end

-- ---------------------------------------------------------------------------
--  Pickup (touche G)
-- ---------------------------------------------------------------------------

function Storage.pickup_nearest(player_id, stone_id)
    if not Storage.get_free_position(stone_id) then return end  -- plein

    local px, py = EntityGetTransform(player_id)
    local candidates = EntityGetInRadiusWithTag(px, py, PICKUP_RADIUS, "item_physics")

    local best_id, best_dist = nil, math.huge
    for _, eid in ipairs(candidates or {}) do
        if not EntityGetIsAlive(eid) then goto skip end
        if eid == stone_id then goto skip end

        local skip_it = false
        for _, tag in ipairs(PICKUP_BLACKLIST) do
            if EntityHasTag(eid, tag) then skip_it = true; break end
        end
        if skip_it then goto skip end

        local parent = EntityGetParent(eid)
        if parent and parent ~= 0 then goto skip end

        local ex, ey = EntityGetTransform(eid)
        local dist = (ex - px)^2 + (ey - py)^2
        if dist < best_dist then best_dist = dist; best_id = eid end
        ::skip::
    end

    if best_id then Storage.store(stone_id, best_id) end
end

return Storage