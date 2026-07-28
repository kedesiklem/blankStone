-- Adaptateur "pierre" au-dessus du sérialiseur d'entité générique
-- (lib/entity_serializer.lua). Ce fichier est la SEULE partie du système qui
-- sait ce qu'est une pierre blankStone : détection (isStone), profondeur de
-- nesting (computeNestingDepth), info d'affichage (getDisplayInfo), et -
-- point important - l'orchestration de la reconstruction d'une storageStone
-- et de son contenu.
--
-- Le polymorph (cf lib/entity_serializer.lua) éjecte les enfants porteurs
-- d'ItemComponent/tag item_pickup au moment de la conversion (même
-- comportement que lorsqu'une créature polymorphée lâche ce qu'elle tient
-- en main) : le contenu d'une storageStone n'est donc PAS capturé si on
-- polymorphe le bag directement avec ses items dedans. À la capture, on
-- détache et sérialise donc chaque enfant individuellement avant de
-- polymorpher le parent vidé.
--
-- À la reconstruction : il est impossible de lancer plusieurs polymorphs en
-- même temps et de savoir ensuite laquelle des entités recréées appartient à
-- quel noeud - même en excluant nos propres entités de bookkeeping par tag,
-- deux polymorphs en cours en même temps produisent chacun une entité "propre"
-- indiscernable de l'autre pour un scan par plage d'ids (vérifié
-- empiriquement : tous les noeuds d'un arbre lancés d'un coup convergeaient
-- vers la MÊME entité, la première apparue). La reconstruction d'un arbre se
-- fait donc en SÉQUENCE stricte, un noeud à la fois, dans l'ordre
-- parent-puis-enfants (pré-ordre) : à la fois pour éviter toute ambiguïté
-- (un seul polymorph en vol à la fois pour cet arbre) et parce que ça
-- garantit que le parent d'un enfant est déjà résolu (une simple donnée,
-- plus besoin de chaîner des références entre builders) au moment de le
-- rattacher.
--
-- L'arbre est donc d'abord aplati en file (flatten), encodée sur une entité
-- "runner" unique (cf rebuild/tickRunner), qui avance d'un item à la fois à
-- chaque frame via lab_stone_builder_tick.lua.

local log                = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils               = dofile_once("mods/blankStone/files/scripts/utils.lua")
local entity_serializer   = dofile_once("mods/blankStone/files/scripts/lib/entity_serializer.lua")

-- storage_stone/utils/inventory.lua ne retourne rien : il déclare ses
-- fonctions en global (is_storageStone, get_bag_items, get_inventory,
-- get_item_position, add_entity_to_inventory_bag...). dofile_once suffit à
-- les rendre disponibles.
dofile_once("mods/blankStone/files/scripts/storage_stone/utils/inventory.lua")

-- =============================================================================
-- Détection
-- =============================================================================

--- @param entity_id number|nil
--- @return boolean
local function isStone(entity_id)
    if not entity_id then return false end
    return utils.getVariable(entity_id, "blankStoneID") ~= nil
end

local MAX_DEPTH = 6 -- garde-fou anti récursion pathologique (storageStone imbriquées) - décision de design, indépendante du backend de sérialisation

--- Profondeur de nesting storageStone-dans-storageStone (0 si aucune, sinon
--- 1 + max des enfants). Sert à REFUSER à l'avance un item trop imbriqué
--- (lab_validator), avant même la capture.
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

--- item_name/sprite : préoccupation d'affichage (vitrine du slot), pas de
--- sérialisation - lues directement sur l'entité vivante, à côté du blob.
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

-- =============================================================================
-- Petits accesseurs VariableStorageComponent typés - canal de coordination
-- entre le runner et ses propres exécutions successives (aucun état Lua ne
-- traverse deux exécutions de script séparées - cf note dans
-- entity_serializer.lua).
-- =============================================================================

local function setVar(entity_id, name, field, value)
    local comp = get_var_storage_with_name(entity_id, name) or add_var_storage_with_name(entity_id, name)
    ComponentSetValue2(comp, field, value)
end

local function getVar(entity_id, name, field, default)
    local comp = get_var_storage_with_name(entity_id, name)
    if not comp then return default end
    local v = ComponentGetValue2(comp, field)
    if v == nil then return default end
    return v
end

-- =============================================================================
-- Encodage générique "champs préfixés par leur longueur" - utilisé à la fois
-- pour l'arbre capturé (cf encodeTree/decodeTree) et pour la file aplatie
-- envoyée au runner (cf encodeQueue/decodeQueue). Aucun caractère - y
-- compris '|' - n'a besoin d'être échappé, quel que soit le contenu.
-- =============================================================================

local function writeField(buf, s)
    table.insert(buf, tostring(#s))
    table.insert(buf, ":")
    table.insert(buf, s)
end

local function readField(s, pos)
    local colon = s:find(":", pos, true)
    local len = tonumber(s:sub(pos, colon - 1))
    local start = colon + 1
    return s:sub(start, start + len - 1), start + len
end

-- --- arbre capturé : { self=<b64>, children={ {position, is_bag, data} } }

local function encodeNode(node, buf)
    writeField(buf, node.self)
    writeField(buf, tostring(#node.children))
    for _, child in ipairs(node.children) do
        writeField(buf, tostring(child.position))
        writeField(buf, child.is_bag and "1" or "0")
        if child.is_bag then
            local sub = {}
            encodeNode(child.data, sub)
            writeField(buf, table.concat(sub))
        else
            writeField(buf, child.data)
        end
    end
end

local function encodeTree(node)
    local buf = {}
    encodeNode(node, buf)
    return table.concat(buf)
end

local function decodeNode(s, pos)
    local node = { children = {} }
    node.self, pos = readField(s, pos)

    local count_s
    count_s, pos = readField(s, pos)

    for _ = 1, tonumber(count_s) do
        local position_s, is_bag_s, data_s
        position_s, pos = readField(s, pos)
        is_bag_s, pos = readField(s, pos)
        data_s, pos = readField(s, pos)

        local is_bag = is_bag_s == "1"
        table.insert(node.children, {
            position = tonumber(position_s),
            is_bag   = is_bag,
            data     = is_bag and (decodeNode(data_s, 1)) or data_s,
        })
    end

    return node, pos
end

local function decodeTree(s)
    return (decodeNode(s, 1))
end

-- --- file aplatie : liste de { b64, parent_index (0=racine), position }

local function flattenNode(node, parent_index, position, queue)
    local index = #queue + 1
    table.insert(queue, { b64 = node.self, parent_index = parent_index, position = position })
    for _, child in ipairs(node.children) do
        if child.is_bag then
            flattenNode(child.data, index, child.position, queue)
        else
            table.insert(queue, { b64 = child.data, parent_index = index, position = child.position })
        end
    end
end

--- @param tree table  produit par decodeTree
--- @return table  liste ordonnée en pré-ordre (parent toujours avant ses enfants)
local function flatten(tree)
    local queue = {}
    flattenNode(tree, 0, 0, queue)
    return queue
end

local function encodeQueue(queue)
    local buf = {}
    writeField(buf, tostring(#queue))
    for _, item in ipairs(queue) do
        writeField(buf, item.b64)
        writeField(buf, tostring(item.parent_index))
        writeField(buf, tostring(item.position))
    end
    return table.concat(buf)
end

local function decodeQueue(s)
    local pos = 1
    local count_s
    count_s, pos = readField(s, pos)

    local queue = {}
    for _ = 1, tonumber(count_s) do
        local b64, parent_index_s, position_s
        b64, pos = readField(s, pos)
        parent_index_s, pos = readField(s, pos)
        position_s, pos = readField(s, pos)
        table.insert(queue, { b64 = b64, parent_index = tonumber(parent_index_s), position = tonumber(position_s) })
    end
    return queue
end

-- --- liste des entités déjà résolues, dans l'ordre - stockée comme une
-- simple liste d'entiers séparés par des virgules (indexée par position pour
-- que resolved[item.parent_index] retrouve l'entité du parent)

local function appendResolved(runner_id, entity_id)
    local current = getVar(runner_id, "bstone_resolved", "value_string", "")
    setVar(runner_id, "bstone_resolved", "value_string", (current == "" and tostring(entity_id) or (current .. "," .. entity_id)))
end

local function getResolvedList(runner_id)
    local s = getVar(runner_id, "bstone_resolved", "value_string", "")
    local list = {}
    if s == "" then return list end
    for numstr in s:gmatch("[^,]+") do
        table.insert(list, tonumber(numstr))
    end
    return list
end

-- =============================================================================
-- Capture
-- =============================================================================

--- Capture récursive d'un noeud : détache et capture d'abord ses enfants un
--- par un, PUIS capture le noeud lui-même une fois vidé - sinon le
--- polymorph du parent éjecterait silencieusement tout ce qu'il contient.
--- @param entity_id number
--- @return table  { self=b64, children={ {position=int, is_bag=bool, data=(table|b64 string)} } }
local function serializeNode(entity_id)
    local is_bag = is_storageStone(entity_id)
    log.debug("lab_stone_io.serializeNode: entité " .. entity_id .. " is_storageStone=" .. tostring(is_bag))

    local children = {}

    if is_bag then
        local items = get_bag_items(entity_id)
        log.debug("lab_stone_io.serializeNode: " .. #items .. " enfant(s) trouvé(s) dans le bag " .. entity_id)

        for _, child_id in ipairs(items) do
            local position = get_item_position(child_id)
            local child_is_bag = is_storageStone(child_id)
            log.debug("lab_stone_io.serializeNode: capture enfant " .. child_id .. " (position=" .. tostring(position) .. ", is_bag=" .. tostring(child_is_bag) .. ")")

            local data = child_is_bag and serializeNode(child_id) or entity_serializer.serialize(child_id)
            table.insert(children, { position = position, is_bag = child_is_bag, data = data })

            EntityKill(child_id)
        end
    end

    local self_data = entity_serializer.serialize(entity_id)
    log.debug("lab_stone_io.serializeNode: noeud " .. entity_id .. " capturé, self=" .. #self_data .. " octet(s) b64, " .. #children .. " enfant(s)")

    return { self = self_data, children = children }
end

--- @param entity_id number
--- @return string|nil data, string|nil item_name_b64, string|nil sprite_b64
local function serialize(entity_id)
    if not isStone(entity_id) then
        log.debug("lab_stone_io.serialize: entité " .. tostring(entity_id) .. " n'est pas une pierre blankStone, ignorée")
        return nil
    end

    log.debug("lab_stone_io.serialize: début capture racine " .. entity_id)
    local item_name, sprite = getDisplayInfo(entity_id)
    local data = encodeTree(serializeNode(entity_id))
    log.debug("lab_stone_io.serialize: capture terminée, arbre encodé = " .. #data .. " octet(s)")

    return data, entity_serializer.b64Encode(item_name), entity_serializer.b64Encode(sprite)
end

-- =============================================================================
-- Restitution
-- =============================================================================

--- Parité avec createLiquidPickup (lab_item_io.lua) : sans ça, l'entité
--- apparaît dans le monde mais rien ne la fait rejoindre la main du joueur
--- automatiquement.
---
--- Le blob capturé (cf entity_serializer.serialize) reproduit fidèlement
--- l'état activé/désactivé de chaque composant au moment de la capture -
--- l'item étant stocké depuis l'inventaire du joueur, ItemComponent y est
--- désactivé, et le reste avec (comportement normal de l'inventaire, pas un
--- bug de la sérialisation). Il suffit de réactiver ItemComponent pour que
--- auto_pickup puisse s'appliquer ; une fois ramassé, le jeu se charge du
--- reste normalement.
--- @param entity_id number
local function setAutoPickup(entity_id)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        EntitySetComponentIsEnabled(entity_id, item_comp, true)
        ComponentSetValue2(item_comp, "auto_pickup", true)
        ComponentSetValue2(item_comp, "next_frame_pickable", GameGetFrameNum())
    end

    EntityAddComponent2(entity_id, "LuaComponent", {
        remove_after_executed = true,
        script_item_picked_up = "mods/blankStone/files/scripts/buildings/lab/lab_pickup_finalize.lua",
    })
    log.debug("lab_stone_io.setAutoPickup: ItemComponent réactivé + auto_pickup posé sur " .. entity_id)
end

--- @param data string  produit par serialize()
--- @param x number
--- @param y number
local function rebuild(data, x, y)
    local tree = decodeTree(data)
    local queue = flatten(tree)
    log.debug("lab_stone_io.rebuild: " .. #queue .. " noeud(s) à reconstruire en séquence, cible (" .. x .. "," .. y .. ")")

    local runner = EntityCreateNew()
    setVar(runner, "bstone_queue", "value_string", encodeQueue(queue))
    setVar(runner, "bstone_x", "value_float", x)
    setVar(runner, "bstone_y", "value_float", y)
    setVar(runner, "bstone_current_index", "value_int", 0)
    setVar(runner, "bstone_current_builder", "value_int", 0)
    setVar(runner, "bstone_resolved", "value_string", "")

    EntityAddComponent2(runner, "LuaComponent", {
        script_source_file    = "mods/blankStone/files/scripts/buildings/lab/lab_stone_builder_tick.lua",
        execute_every_n_frame = 1,
    })

    log.debug("lab_stone_io.rebuild: runner=" .. runner)
end

--- Appelée à chaque frame par lab_stone_builder_tick.lua sur le runner d'un
--- rebuild() en cours. Fait avancer la reconstruction d'une étape : démarre
--- l'item suivant de la file si aucun n'est en vol, ou fait progresser/
--- finalise celui en cours (rattachement au parent déjà résolu, ou
--- auto-pickup pour la racine) avant de passer au suivant. Se tue une fois
--- la file épuisée.
--- @param runner_id number
local function tickRunner(runner_id)
    local builder = getVar(runner_id, "bstone_current_builder", "value_int", 0)
    local index = getVar(runner_id, "bstone_current_index", "value_int", 0)
    local queue = decodeQueue(getVar(runner_id, "bstone_queue", "value_string", ""))

    if builder == 0 then
        index = index + 1
        if index > #queue then
            log.debug("lab_stone_io.tickRunner: runner " .. runner_id .. " terminé (" .. #queue .. " noeud(s))")
            EntityKill(runner_id)
            return
        end

        local x = getVar(runner_id, "bstone_x", "value_float", 0)
        local y = getVar(runner_id, "bstone_y", "value_float", 0)
        local item = queue[index]

        builder = entity_serializer.beginDeserialize(item.b64, x, y)
        setVar(runner_id, "bstone_current_index", "value_int", index)
        setVar(runner_id, "bstone_current_builder", "value_int", builder)
        log.debug("lab_stone_io.tickRunner: runner " .. runner_id .. " démarre noeud " .. index .. "/" .. #queue .. " (builder=" .. builder .. ")")
        return -- laisse la résolution se faire sur les frames suivantes
    end

    local phase = entity_serializer.getPhase(builder)
    if phase == "resolving" then
        entity_serializer.tryResolve(builder)
        phase = entity_serializer.getPhase(builder)
    end

    if phase == "resolving" then
        return -- pas encore prêt, on retentera à la prochaine frame
    end

    if phase == "failed" then
        log.error("lab_stone_io.tickRunner: runner " .. runner_id .. " noeud " .. index .. " a échoué à se résoudre, abandon du reste de la file")
        EntityKill(builder)
        EntityKill(runner_id)
        return
    end

    -- phase == "resolved"
    local resolved_entity = entity_serializer.getResolvedEntity(builder)
    local item = queue[index]
    log.debug("lab_stone_io.tickRunner: runner " .. runner_id .. " noeud " .. index .. " résolu -> " .. resolved_entity)

    if item.parent_index == 0 then
        setAutoPickup(resolved_entity)
    else
        local resolved_list = getResolvedList(runner_id)
        local parent_entity = resolved_list[item.parent_index]
        if not parent_entity then
            log.error("lab_stone_io.tickRunner: runner " .. runner_id .. " noeud " .. index .. " : parent d'index " .. item.parent_index .. " pas encore résolu (ne devrait pas arriver, ordre pré-ordre)")
        else
            local inventory = get_inventory(parent_entity)
            if not inventory then
                log.error("lab_stone_io.tickRunner: inventory_full introuvable sur " .. parent_entity .. ", enfant " .. resolved_entity .. " perdu")
            else
                log.debug("lab_stone_io.tickRunner: rattachement de " .. resolved_entity .. " à l'inventaire " .. inventory .. " (position=" .. item.position .. ")")
                add_entity_to_inventory_bag(item.position, inventory, resolved_entity)
            end
        end
    end

    appendResolved(runner_id, resolved_entity)
    EntityKill(builder) -- entièrement exploité : sa résolution est déjà copiée dans bstone_resolved
    setVar(runner_id, "bstone_current_builder", "value_int", 0) -- prêt pour le noeud suivant à la prochaine frame
end

return {
    isStone             = isStone,
    computeNestingDepth = computeNestingDepth,
    MAX_DEPTH           = MAX_DEPTH,
    serialize           = serialize,
    rebuild             = rebuild,
    tickRunner          = tickRunner,
    b64Decode           = entity_serializer.b64Decode,
    setAutoPickup       = setAutoPickup,
}