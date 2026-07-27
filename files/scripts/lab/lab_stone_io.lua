-- Adaptateur "pierre" au-dessus du sérialiseur d'entité générique
-- (lib/entity_serializer.lua). Ce fichier est la SEULE partie du système qui
-- sait ce qu'est une pierre blankStone : détection (isStone), profondeur de
-- nesting autorisée pour une storageStone (computeNestingDepth, une décision
-- de design, pas une contrainte du sérialiseur), résolution d'un chemin de
-- spawn depuis un blankStoneID capturé, et la logique Bags-of-Many
-- nécessaire pour rattacher un objet retrouvé dans une storageStone.
--
-- La capture/reconstruction de l'arbre d'entités elle-même (composants,
-- enfants, récursion) ne vit pas ici : voir lib/entity_serializer.lua.

local log             = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils            = dofile_once("mods/blankStone/files/scripts/utils.lua")
local entity_serializer  = dofile_once("mods/blankStone/files/scripts/lib/entity_serializer.lua")
local stone_registry        = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local spawn_executor            = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/spawn_executor.lua")

-- storage_stone/utils/inventory.lua ne retourne rien : il déclare ses
-- fonctions en global (is_storageStone, get_bag_items, add_bags_of_many_comps,
-- add_entity_to_inventory...). dofile_once suffit à les rendre disponibles.
dofile_once("mods/blankStone/files/scripts/storage_stone/utils/inventory.lua")

local MAX_DEPTH = 6 -- garde-fou anti récursion pathologique (storageStone imbriquées) - une décision de design, distincte du garde-fou générique d'entity_serializer

-- =============================================================================
-- Détection
-- =============================================================================

--- @param entity_id number|nil
--- @return boolean
local function isStone(entity_id)
    if not entity_id then return false end
    return utils.getVariable(entity_id, "blankStoneID") ~= nil
end

--- Profondeur de nesting storageStone-dans-storageStone (0 si aucune,
--- sinon 1 + max des enfants). Sert à REFUSER à l'avance un item trop
--- imbriqué (lab_validator), plutôt que de silencieusement tronquer son
--- contenu au moment du dump.
--- @param entity_id number
--- @return number
local function computeNestingDepth(entity_id)
    if not is_storageStone(entity_id) then return 0 end
    local max_child_depth = 0
    for _, child_id in ipairs(get_bag_items(entity_id) or {}) do
        local d = computeNestingDepth(child_id)
        if d > max_child_depth then max_child_depth = d end
    end
    return 1 + max_child_depth
end

-- =============================================================================
-- Résolveur de spawn + hook d'attache (fournis à entity_serializer)
-- =============================================================================

--- @param node table  noeud capturé par entity_serializer (name, vars, children)
--- @return string|nil
local function findVarValue(node, var_name)
    for _, v in ipairs(node.vars) do
        if v.name == var_name then return v.value_string end
    end
end

-- Une storageStone peut contenir des sorts, baguettes, potions et objets
-- génériques, pas seulement des pierres (cf is_allowed_in_universal_bag dans
-- storage_stone/utils/inventory.lua). Le résolveur doit donc aussi savoir
-- reconstruire une potion/un sac de poudre - même chemins que ceux utilisés
-- par lab_item_io.lua pour le cas "potion posée seule dans un slot". Dupliqué
-- ici plutôt qu'importé (lab_item_io.lua dépend déjà de lab_stone_io.lua :
-- une dépendance dans l'autre sens créerait un cycle).
local PICKUP_PATH = {
    potion       = "data/entities/items/pickup/potion.xml",
    powder_stash = "data/entities/items/pickup/powder_stash.xml",
}

--- @param tags string|nil  chaîne de tags séparés par des virgules (EntityGetTags)
--- @param tag string
--- @return boolean
local function hasTag(tags, tag)
    for t in (tags or ""):gmatch("[^,]+") do
        if t == tag then return true end
    end
    return false
end

--- Comment entity_serializer doit spawn un noeud pour lequel il n'a trouvé
--- aucun enfant pré-existant correspondant chez le parent : lit blankStoneID
--- (un var capturé comme un autre, entity_serializer n'en sait rien) et le
--- résout via stone_registry, ou à défaut les tags capturés pour une potion/
--- un sac de poudre.
--- @param node table
--- @return string|nil path
local function resolveSpawnPath(node)
    local blank_stone_id = findVarValue(node, "blankStoneID")
    if blank_stone_id then
        local def = stone_registry[blank_stone_id]
        if not def then
            log.error("lab_stone_io.resolveSpawnPath: blankStoneID inconnu du registre '" .. blank_stone_id .. "'")
            return nil
        end
        return def.path
    end

    if hasTag(node.tags, "potion") then
        return PICKUP_PATH.potion
    end
    if hasTag(node.tags, "powder_stash") then
        return PICKUP_PATH.powder_stash
    end

    -- Pas grave en soi pour un enfant structurel (ex: inventory_full), qui ne
    -- devrait jamais atteindre cette fonction puisqu'il doit être retrouvé
    -- parmi les enfants déjà présents du parent. Pour un vrai objet stocké,
    -- ça signifie un type non supporté (sort, baguette, objet générique) :
    -- ni pierre, ni potion, ni sac de poudre n'ont de logique de
    -- reconstruction pour l'instant.
    log.error("lab_stone_io.resolveSpawnPath: noeud '" .. tostring(node.name) .. "' non reconnu (ni blankStoneID, ni potion, ni powder_stash)")
    return nil
end

--- Rattache un objet à l'inventaire de sa storageStone parente. Appelée
--- depuis lab_stone_attach_deferred.lua, AU MOINS UNE FRAME après le spawn
--- (cf entity_serializer.processPendingAttachments) - jamais dans le même
--- appel synchrone que EntityLoad. bags_of_many_item_position est déjà posé
--- sur l'entité à cet instant (applyVars tourne en phase 1, seul le
--- rattachement est différé), donc lu directement dessus plutôt que sur un
--- noeud capturé.
--- @param entity_id number
--- @param parent_id number
local function attachToBag(entity_id, parent_id)
    local position = 0
    for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent") or {}) do
        if ComponentGetValue2(comp_id, "name") == "bags_of_many_item_position" then
            position = ComponentGetValue2(comp_id, "value_int") or 0
            break
        end
    end

    add_bags_of_many_comps(entity_id, position)
    add_entity_to_inventory(entity_id, parent_id)

    for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
        EntitySetComponentIsEnabled(entity_id, comp_id, false)
    end
end

local REBUILD_OPTS = {
    resolveSpawn = resolveSpawnPath,
    deferAttach  = true, -- cf entity_serializer.lua : deux crashs moteur distincts observés en rattachant/désactivant des composants dans la même frame que le spawn
}

local ATTACH_SCHEDULER_TAG = "blankStone_stone_attach_scheduler"
local ATTACH_SCRIPT = "mods/blankStone/files/scripts/buildings/lab/lab_stone_attach_deferred.lua"

-- =============================================================================
-- API publique
-- =============================================================================

--- item_name (clé de traduction) et sprite (image_file) : préoccupations
--- d'affichage, pas de sérialisation - lues directement sur l'entité vivante,
--- à côté du blob générique, pas dedans. entity_serializer ne les connaît pas.
--- @param entity_id number
--- @return string item_name, string sprite
local function getDisplayInfo(entity_id)
    local item_name = ""
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        item_name = ComponentGetValue2(item_comp, "item_name") or ""
    end

    local sprite = ""
    for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
        local image_file = ComponentGetValue2(comp_id, "image_file")
        if image_file and image_file ~= "" then
            sprite = image_file
            break
        end
    end

    return item_name, sprite
end

--- @param entity_id number
--- @return string|nil data, string|nil item_name_b64, string|nil sprite_b64
local function serialize(entity_id)
    if not isStone(entity_id) then return nil end

    local data = entity_serializer.serialize(entity_id)
    local item_name, sprite = getDisplayInfo(entity_id)

    return data, entity_serializer.b64Encode(item_name), entity_serializer.b64Encode(sprite)
end

local PICKUP_FINALIZE_SCRIPT = "mods/blankStone/files/scripts/buildings/lab/lab_pickup_finalize.lua"

--- Parité avec createLiquidPickup (lab_item_io.lua) : sans ça, l'entité
--- apparaît dans le monde mais rien ne la fait rejoindre la main du joueur
--- automatiquement.
---
--- lab_pickup_finalize.lua (déjà existant dans le mod, utilisé par les
--- potions) remet auto_pickup à false une fois l'objet réellement ramassé -
--- sans ça, auto_pickup resterait true pour toujours, et reposer la pierre
--- au sol la ferait revenir dans l'inventaire dès qu'on s'en approche.
--- @param entity_id number
local function setAutoPickup(entity_id)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        ComponentSetValue2(item_comp, "auto_pickup", true)
        ComponentSetValue2(item_comp, "next_frame_pickable", GameGetFrameNum())
    end

    EntityAddComponent2(entity_id, "LuaComponent", {
        remove_after_executed = true,
        script_item_picked_up = PICKUP_FINALIZE_SCRIPT,
    })
end

--- @param data string
--- @param x number
--- @param y number
--- @return number|nil entity_id
local function rebuild(data, x, y)
    local node = entity_serializer.deserialize(data)
    local entity_id, has_pending = entity_serializer.rebuild(node, x, y, REBUILD_OPTS)
    if not entity_id then return nil end

    if has_pending then
        -- Au moins un objet stocké a besoin d'être rattaché à son inventaire
        -- parent - reporté d'au moins une frame (cf entity_serializer et
        -- lab_stone_attach_deferred.lua). auto_pickup n'est PAS posé ici :
        -- si le joueur récupère l'objet avant que le rattachement n'ait eu
        -- lieu (et que les LuaComponent périodiques cessent de s'exécuter
        -- une fois l'objet dans l'inventaire, hypothèse retenue pour le
        -- contenu qui restait au sol), le rattachement ne se ferait jamais.
        -- C'est lab_stone_attach_deferred.lua qui appelle setAutoPickup, une
        -- fois tout le contenu effectivement rattaché.
        EntityAddComponent2(entity_id, "LuaComponent", {
            _tags = ATTACH_SCHEDULER_TAG,
            script_source_file = ATTACH_SCRIPT,
            execute_every_n_frame = 1,
        })
    else
        setAutoPickup(entity_id)
    end

    return entity_id
end

return {
    isStone                    = isStone,
    computeNestingDepth        = computeNestingDepth,
    MAX_DEPTH                  = MAX_DEPTH,
    serialize                  = serialize,
    rebuild                    = rebuild,
    b64Decode                  = entity_serializer.b64Decode,
    attachToBag                = attachToBag,
    setAutoPickup               = setAutoPickup,
    processPendingAttachments  = entity_serializer.processPendingAttachments,
    ATTACH_SCHEDULER_TAG       = ATTACH_SCHEDULER_TAG,
}
