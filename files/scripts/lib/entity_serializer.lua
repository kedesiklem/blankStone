-- IMPORTANT : jamais de ModTextFileSetContent/GetContent (indisponibles hors
-- de l'init du mod). Toute reconstruction passe par EntityLoad sur un
-- template statique (résolu par l'appelant) suivi d'une réapplication des
-- VariableStorageComponent capturés via l'API composant classique.

local log  = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local DEFAULT_MAX_DEPTH = 40 -- garde-fou générique anti arbre pathologique/corrompu

-- =============================================================================
-- Base64 (encode/decode minimal, sans dépendance à bit/bit32)
-- =============================================================================

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

--- @param data string
--- @return string
local function b64Encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local b1, b2, b3 = data:byte(i, i + 2)
        b2 = b2 or 0
        b3 = b3 or 0
        local n = b1 * 65536 + b2 * 256 + b3

        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64

        table.insert(out, table.concat({
            B64_CHARS:sub(c1 + 1, c1 + 1),
            B64_CHARS:sub(c2 + 1, c2 + 1),
            (i + 1 <= #data) and B64_CHARS:sub(c3 + 1, c3 + 1) or "=",
            (i + 2 <= #data) and B64_CHARS:sub(c4 + 1, c4 + 1) or "=",
        }))
    end
    return table.concat(out)
end

--- @param data string
--- @return string
local function b64Decode(data)
    local rev = {}
    for i = 1, #B64_CHARS do
        rev[B64_CHARS:sub(i, i)] = i - 1
    end

    data = data:gsub("[^" .. B64_CHARS:gsub("%+", "%%+") .. "=]", "")

    local out = {}
    for i = 1, #data, 4 do
        local c1 = rev[data:sub(i, i)] or 0
        local c2 = rev[data:sub(i + 1, i + 1)] or 0
        local s3 = data:sub(i + 2, i + 2)
        local s4 = data:sub(i + 3, i + 3)
        local c3 = rev[s3]
        local c4 = rev[s4]

        local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)

        table.insert(out, string.char(math.floor(n / 65536) % 256))
        if s3 ~= "=" and c3 then
            table.insert(out, string.char(math.floor(n / 256) % 256))
        end
        if s4 ~= "=" and c4 then
            table.insert(out, string.char(n % 256))
        end
    end
    return table.concat(out)
end

--- lib/nxml.lua n'échappe aucun caractère spécial XML lors de la
--- sérialisation (pas de gestion de ", <, & dans les attributs). Toute
--- valeur texte arbitraire doit donc être encodée avant d'être posée en
--- attribut, sous peine de document XML mal formé.
--- @param v string|nil
--- @return string
local function safeAttr(v)
    return b64Encode(tostring(v or ""))
end

--- @param v string|nil
--- @return string
local function unsafeAttr(v)
    if not v or v == "" then return "" end
    return b64Decode(v)
end

-- =============================================================================
-- Capture
-- =============================================================================

--- @param entity_id number
--- @return table[] { {name=, value_string=, value_int=, value_float=, value_bool=}, ... }
local function dumpVars(entity_id)
    local out = {}
    for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent") or {}) do
        table.insert(out, {
            name         = ComponentGetValue2(comp_id, "name"),
            value_string = ComponentGetValue2(comp_id, "value_string"),
            value_int    = ComponentGetValue2(comp_id, "value_int"),
            value_float  = ComponentGetValue2(comp_id, "value_float"),
            value_bool   = ComponentGetValue2(comp_id, "value_bool"),
        })
    end
    return out
end

--- Composition en matériaux d'une entité, SI elle a un MaterialInventoryComponent
--- (potions, sacs de poudre, et plus généralement tout conteneur de liquide -
--- pas une notion "pierre"). Rien de spécifique au domaine : n'importe quelle
--- entité Noita avec ce composant est concernée.
--- @param entity_id number
--- @return table[]|nil { {material=, amount=}, ... }, nil si pas de MaterialInventoryComponent
local function dumpMaterials(entity_id)
    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if not mat_inv_comp then return nil end

    local count_per_material_type = ComponentGetValue2(mat_inv_comp, "count_per_material_type")
    if not count_per_material_type then return {} end

    local out = {}
    for i, amount in ipairs(count_per_material_type) do
        if amount ~= 0 then
            table.insert(out, { material = CellFactory_GetName(i - 1), amount = amount })
        end
    end
    return out
end

--- @param entity_id number
--- @return number|nil  nil si pas de MaterialSuckerComponent
local function dumpBarrelSize(entity_id)
    local sucker_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    if not sucker_comp then return nil end
    return ComponentGetValue2(sucker_comp, "barrel_size")
end

--- Le nom "affiché" d'une entité n'est PAS EntityGetName (un identifiant
--- interne, cf name plus haut) : ce sont trois champs distincts
--- (ItemComponent.item_name, UIInfoComponent.ui_name, AbilityComponent.ui_name),
--- que ce mod mute en texte littéral (plus une clé de traduction) au fil des
--- améliorations - cf utils.changeName, storage_upgrade_effect.lua. Capturés
--- séparément d'EntityGetName car rien ne garantit qu'ils soient identiques
--- (le cas d'usage exact qui casse si on ne capture que l'un des deux).
--- @param entity_id number
--- @return string itemName, string uiInfoName, string abilityName  (chaîne vide si le composant est absent)
local function dumpDisplayName(entity_id)
    local item_name = ""
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then item_name = ComponentGetValue2(item_comp, "item_name") or "" end

    local ui_info_name = ""
    local ui_info_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "UIInfoComponent")
    if ui_info_comp then ui_info_name = ComponentGetValue2(ui_info_comp, "ui_name") or "" end

    local ability_name = ""
    local ability_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
    if ability_comp then ability_name = ComponentGetValue2(ability_comp, "ui_name") or "" end

    return item_name, ui_info_name, ability_name
end

--- Dump récursif et générique d'une entité et de ses enfants.
---
--- Un enfant n'est conservé que s'il porte au moins un VariableStorageComponent,
--- au moins un matériau, OU au moins un descendant qui en porte un (calculé
--- récursivement : un enfant totalement vide - ni var, ni matériau, ni
--- descendant utile - est omis). Ce n'est PAS un filtre spécifique aux
--- pierres : n'importe quelle entité légitime dans ce mod porte au moins un
--- var, ou une composition en matériaux (potion, sac de poudre), ou sert de
--- structure à des descendants qui en portent (inventory_full n'a lui-même
--- ni var ni matériau mais ses enfants réels en ont). Un enfant sans aucune
--- trace d'état est très probablement une entité que le moteur attache
--- lui-même (effet visuel, ancrage interne...) et jamais prévue comme
--- "contenu à restaurer" - la tenter respawn a provoqué un crash moteur
--- (assert dans inventory2_system.cpp) sur une entité de ce genre, sans nom
--- et sans blankStoneID, que le résolveur ne pouvait évidemment pas retrouver.
--- @param entity_id number
--- @param depth number|nil
--- @param max_depth number|nil
--- @return table|nil node
local function dumpEntity(entity_id, depth, max_depth)
    depth = depth or 0
    max_depth = max_depth or DEFAULT_MAX_DEPTH

    if depth > max_depth then
        log.error("entity_serializer.dumpEntity: profondeur max (" .. max_depth .. ") dépassée, arbre tronqué")
        return nil
    end

    local item_name, ui_info_name, ability_name = dumpDisplayName(entity_id)

    local node = {
        name         = EntityGetName(entity_id) or "",
        tags         = EntityGetTags(entity_id) or "",
        itemName     = item_name,
        uiInfoName   = ui_info_name,
        abilityName  = ability_name,
        vars         = dumpVars(entity_id),
        materials    = dumpMaterials(entity_id),
        barrelSize   = dumpBarrelSize(entity_id),
        children     = {},
    }

    for _, child_id in ipairs(EntityGetAllChildren(entity_id) or {}) do
        local child_node = dumpEntity(child_id, depth + 1, max_depth)
        if child_node and (#child_node.vars > 0 or (child_node.materials and #child_node.materials > 0) or #child_node.children > 0) then
            table.insert(node.children, child_node)
        end
    end

    return node
end

-- =============================================================================
-- Sérialisation nxml <-> table
-- =============================================================================

--- @param node table
--- @return table xml (element nxml)
local function nodeToXml(node)
    local xml = nxml.new_element("entity", {
        name        = safeAttr(node.name),
        tags        = safeAttr(node.tags),
        itemName    = safeAttr(node.itemName),
        uiInfoName  = safeAttr(node.uiInfoName),
        abilityName = safeAttr(node.abilityName),
        barrelSize  = node.barrelSize or "",
    })

    for _, v in ipairs(node.vars) do
        xml:add_child(nxml.new_element("var", {
            name         = safeAttr(v.name),
            value_string = safeAttr(v.value_string),
            value_int    = v.value_int or 0,
            value_float  = v.value_float or 0,
            value_bool   = v.value_bool and "1" or "0",
        }))
    end

    if node.materials then
        for _, m in ipairs(node.materials) do
            xml:add_child(nxml.new_element("material", {
                name   = safeAttr(m.material),
                amount = m.amount or 0,
            }))
        end
    end

    for _, child in ipairs(node.children) do
        xml:add_child(nodeToXml(child))
    end

    return xml
end

--- @param xml table (element nxml)
--- @return table node
local function xmlToNode(xml)
    local node = {
        name        = unsafeAttr(xml:get("name")),
        tags        = unsafeAttr(xml:get("tags")),
        itemName    = unsafeAttr(xml:get("itemName")),
        uiInfoName  = unsafeAttr(xml:get("uiInfoName")),
        abilityName = unsafeAttr(xml:get("abilityName")),
        barrelSize  = tonumber(xml:get("barrelSize")),
        vars        = {},
        materials   = {},
        children    = {},
    }

    for var_xml in xml:each_of("var") do
        table.insert(node.vars, {
            name         = unsafeAttr(var_xml:get("name")),
            value_string = unsafeAttr(var_xml:get("value_string")),
            value_int    = tonumber(var_xml:get("value_int")) or 0,
            value_float  = tonumber(var_xml:get("value_float")) or 0,
            value_bool   = var_xml:get("value_bool") == "1",
        })
    end

    for mat_xml in xml:each_of("material") do
        table.insert(node.materials, {
            material = unsafeAttr(mat_xml:get("name")),
            amount   = tonumber(mat_xml:get("amount")) or 0,
        })
    end

    for child_xml in xml:each_of("entity") do
        table.insert(node.children, xmlToNode(child_xml))
    end

    return node
end

--- @param entity_id number
--- @param max_depth number|nil
--- @return string b64
local function serialize(entity_id, max_depth)
    local node = dumpEntity(entity_id, 0, max_depth)
    -- tostring(xml) indente avec tabulations/retours à la ligne (cf __tostring
    -- de nxml.lua -> nxml.tostring(self, false)) : inutilement volumineux une
    -- fois passé en base64. nxml.tostring(xml, true) est compact.
    return b64Encode(nxml.tostring(nodeToXml(node), true))
end

--- @param b64 string
--- @return table node
local function deserialize(b64)
    return xmlToNode(nxml.parse(b64Decode(b64)))
end

-- =============================================================================
-- Reconstruction
-- =============================================================================

--- @param entity_id number
--- @param vars table
local function applyVars(entity_id, vars)
    for _, v in ipairs(vars) do
        local existing_comp = nil
        for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent") or {}) do
            if ComponentGetValue2(comp_id, "name") == v.name then
                existing_comp = comp_id
                break
            end
        end

        if existing_comp then
            ComponentSetValue2(existing_comp, "value_string", v.value_string or "")
            ComponentSetValue2(existing_comp, "value_int", v.value_int or 0)
            ComponentSetValue2(existing_comp, "value_float", v.value_float or 0)
            ComponentSetValue2(existing_comp, "value_bool", v.value_bool or false)
        else
            EntityAddComponent2(entity_id, "VariableStorageComponent", {
                name         = v.name,
                value_string = v.value_string or "",
                value_int    = v.value_int or 0,
                value_float  = v.value_float or 0,
                value_bool   = v.value_bool or false,
            })
        end
    end
end

--- Réapplique une composition en matériaux capturée. Vide d'abord tout ce
--- que le template respawné aurait pu préremplir par défaut (même précaution
--- que lab_item_io.createLiquidPickup pour une potion posée seule).
--- @param entity_id number
--- @param materials table[]|nil
local function applyMaterials(entity_id, materials)
    if not materials then return end

    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if mat_inv_comp then
        local existing = ComponentGetValue2(mat_inv_comp, "count_per_material_type")
        if existing then
            for i, amount in ipairs(existing) do
                if amount ~= 0 then
                    AddMaterialInventoryMaterial(entity_id, CellFactory_GetName(i - 1), 0)
                end
            end
        end
    end

    for _, m in ipairs(materials) do
        AddMaterialInventoryMaterial(entity_id, m.material, m.amount)
    end
end

--- @param entity_id number
--- @param barrel_size number|nil
local function applyBarrelSize(entity_id, barrel_size)
    if not barrel_size then return end
    local sucker_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    if sucker_comp then
        ComponentSetValue2(sucker_comp, "barrel_size", barrel_size)
    end
end

--- Réapplique le nom "affiché" capturé (cf dumpDisplayName). N'écrase que
--- les champs effectivement capturés (non vides) : un template n'a pas
--- forcément les trois composants (ex: un objet sans AbilityComponent), et
--- une chaîne capturée vide ne doit pas écraser la valeur par défaut du
--- template fraîchement spawné.
--- @param entity_id number
--- @param item_name string
--- @param ui_info_name string
--- @param ability_name string
local function applyDisplayName(entity_id, item_name, ui_info_name, ability_name)
    if item_name and item_name ~= "" then
        local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
        if item_comp then ComponentSetValue2(item_comp, "item_name", item_name) end
    end
    if ui_info_name and ui_info_name ~= "" then
        local ui_info_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "UIInfoComponent")
        if ui_info_comp then ComponentSetValue2(ui_info_comp, "ui_name", ui_info_name) end
    end
    if ability_name and ability_name ~= "" then
        local ability_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
        if ability_comp then ComponentSetValue2(ability_comp, "ui_name", ability_name) end
    end
end

--- Retire et renvoie le premier entity_id du pool dont le nom capturé
--- correspond, ou nil. Consommer (retirer) évite qu'un même enfant
--- pré-existant ne soit apparié deux fois si plusieurs entités partagent le
--- même nom.
--- @param pool table[]  liste mutable de {id=, name=}
--- @param name string
--- @return number|nil
local function findAndConsume(pool, name)
    for i, entry in ipairs(pool) do
        if entry.name == name then
            table.remove(pool, i)
            return entry.id
        end
    end
    return nil
end

-- =============================================================================
-- Rattachement différé
-- =============================================================================
--
-- Deux crashs moteur distincts (assert Box2D-like sur des composants
-- physiques, puis assert dans inventory2_system.cpp) ont été observés en
-- manipulant - réattacher à un parent, désactiver des composants - des
-- entités dans la MÊME frame que leur spawn. Le mode différé (opts.deferAttach)
-- sépare les deux : spawn immédiat (sûr, déjà utilisé pour les potions),
-- rattachement au moins une frame plus tard.
--
-- Un enfant en attente n'est PAS gardé en mémoire côté Lua (aucune garantie
-- qu'un contexte de script Noita survive telle quelle jusqu'au prochain
-- déclenchement) : il est marqué directement sur l'entité elle-même, via un
-- tag (retrouvable par EntityGetWithTag depuis n'importe quel script,
-- n'importe quand) et un VariableStorageComponent portant l'id du parent visé.
-- processPendingAttachments() est appelée plus tard (typiquement depuis un
-- script déclenché une frame après, cf lab_stone_attach_deferred.lua) pour
-- traiter tout ce qui est en attente, peu importe qui l'a marqué.

local PENDING_TAG  = "blankStone_deferred_attach_pending"
local PARENT_VAR   = "blankStoneDeferredAttachParent"

--- @param entity_id number
--- @param var_name string
--- @return number|nil comp_id
local function findVarComp(entity_id, var_name)
    for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent") or {}) do
        if ComponentGetValue2(comp_id, "name") == var_name then
            return comp_id
        end
    end
end

--- Traite tout ce qui est actuellement en attente de rattachement (peu
--- importe quel appel à rebuild() les a marqués). À appeler depuis un script
--- déclenché plus tard (au moins une frame après le spawn).
--- @param attachFn function(child_id, parent_id)  la logique de rattachement réelle (spécifique à l'appelant, ex: Bags-of-Many)
local function processPendingAttachments(attachFn)
    local pending = EntityGetWithTag(PENDING_TAG) or {}
    for _, child_id in ipairs(pending) do
        local parent_comp = findVarComp(child_id, PARENT_VAR)
        local parent_id = parent_comp and ComponentGetValue2(parent_comp, "value_int")

        if parent_id and parent_id > 0 then
            local ok, err = pcall(attachFn, child_id, parent_id)
            if not ok then
                log.error("entity_serializer.processPendingAttachments: attachFn a échoué pour " .. child_id .. " -> " .. parent_id .. " : " .. tostring(err))
            end
        else
            log.error("entity_serializer.processPendingAttachments: entité " .. child_id .. " marquée en attente mais sans parent valide")
        end

        EntityRemoveTag(child_id, PENDING_TAG)
        if parent_comp then
            EntityRemoveComponent(child_id, parent_comp)
        end
    end
end

--- @param node table
--- @param x number
--- @param y number
--- @param opts table  {
---     resolveSpawn = function(node) -> path|nil,
---     onAttach     = function(child_id, parent_id, node)|nil  (ignoré si deferAttach)
---     deferAttach  = boolean|nil  si vrai, ne rattache jamais immédiatement -
---                    marque pour processPendingAttachments à la place.
--- }
--- @param parent_id number|nil
--- @param preexisting_pool table[]|nil  snapshot des enfants déjà présents sur parent_id, pris UNE fois par le parent
--- @return number|nil entity_id, boolean has_pending
local function rebuildEntity(node, x, y, opts, parent_id, preexisting_pool)
    local entity_id = nil
    local has_pending = false

    if preexisting_pool then
        entity_id = findAndConsume(preexisting_pool, node.name)
    end

    if not entity_id then
        local path = opts.resolveSpawn(node)
        if not path then
            log.error("entity_serializer.rebuildEntity: résolveur incapable de trouver un chemin pour '" .. tostring(node.name) .. "'")
            return nil, false
        end

        entity_id = EntityLoad(path, x, y)
        if not entity_id then
            log.error("entity_serializer.rebuildEntity: échec EntityLoad " .. tostring(path))
            return nil, false
        end

        if node.name ~= "" then
            EntitySetName(entity_id, node.name)
        end

        if parent_id then
            if opts.deferAttach then
                EntityAddTag(entity_id, PENDING_TAG)
                EntityAddComponent2(entity_id, "VariableStorageComponent", { name = PARENT_VAR, value_int = parent_id })
                has_pending = true
            elseif opts.onAttach then
                opts.onAttach(entity_id, parent_id, node)
            else
                EntityAddChild(parent_id, entity_id)
            end
        end
    end

    applyVars(entity_id, node.vars)
    applyMaterials(entity_id, node.materials)
    applyBarrelSize(entity_id, node.barrelSize)
    applyDisplayName(entity_id, node.itemName, node.uiInfoName, node.abilityName)

    if #node.children > 0 then
        local own_preexisting = {}
        for _, cid in ipairs(EntityGetAllChildren(entity_id) or {}) do
            table.insert(own_preexisting, { id = cid, name = EntityGetName(cid) or "" })
        end
        for _, child_node in ipairs(node.children) do
            local _, child_pending = rebuildEntity(child_node, x, y, opts, entity_id, own_preexisting)
            has_pending = has_pending or child_pending
        end
    end

    return entity_id, has_pending
end

--- @param node table
--- @param x number
--- @param y number
--- @param opts table
--- @return number|nil entity_id, boolean has_pending  vrai si des enfants ont été marqués pour rattachement différé (opts.deferAttach) - l'appelant doit alors programmer un appel à processPendingAttachments
local function rebuild(node, x, y, opts)
    return rebuildEntity(node, x, y, opts, nil, nil)
end

return {
    b64Encode                 = b64Encode,
    b64Decode                 = b64Decode,
    dumpEntity                = dumpEntity,
    serialize                 = serialize,
    deserialize               = deserialize,
    rebuild                   = rebuild,
    processPendingAttachments = processPendingAttachments,
}
