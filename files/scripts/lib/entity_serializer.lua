-- Sérialisation/désérialisation générique d'entité, appuyée sur le
-- mécanisme de polymorph du jeu (GameEffectComponent.mSerializedData)
-- plutôt que sur une liste de composants gérés à la main.
--
-- IMPORTANT : chaque script exécuté via LuaComponent.script_source_file a
-- son propre état Lua isolé - une table ou variable Lua définie ici n'est
-- PAS visible depuis un script attaché à une autre entité, même si les deux
-- viennent du même dofile_once("...entity_serializer.lua"). Vérifié
-- empiriquement (une table "pending" indexée par sentinelle échouait
-- systématiquement) et cohérent avec le reste du mod : l'ancien système de
-- rattachement différé (lab_stone_attach_deferred.lua, historique git)
-- lisait déjà ses données en attente via EntityGetWithTag plutôt que via une
-- table Lua, pour la même raison.
--
-- Toute donnée nécessaire à la résolution (position cible, nombre de
-- tentatives, résultat) est donc stockée SUR L'ENTITÉ builder elle-même, via
-- VariableStorageComponent - jamais dans une table Lua de module. Ce fichier
-- reste volontairement générique (il ne connaît ni parent, ni inventaire, ni
-- rattachement) : cf lab_stone_io.lua pour l'orchestration de l'arbre
-- (attente des enfants, rattachement, auto-pickup), pilotée elle aussi
-- entièrement par composants (cf lab_stone_builder_tick.lua).

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local POLY_FILE = "mods/blankStone/files/entities/misc/poly.xml" -- cf CREDIT.txt

-- Tag posé sur TOUTES les entités de bookkeeping internes (placeholder,
-- ge_entity, builder) pour pouvoir les exclure du scan dans tryResolve.
-- Nécessaire dès qu'on construit plusieurs noeuds en même temps (storageStone
-- imbriquées) : les plages d'ids de deux reconstructions en cours se
-- chevauchent, et un builder/placeholder d'une AUTRE reconstruction peut se
-- retrouver dans la fenêtre de scan d'une autre - seule une entité SANS ce
-- tag peut être la vraie cible recréée par le moteur.
local INTERNAL_TAG = "blankStone_poly_internal"

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

-- =============================================================================
-- Petits accesseurs VariableStorageComponent typés - le seul canal fiable
-- entre deux exécutions de script séparées (cf note en tête de fichier).
-- =============================================================================

local function getVarComp(entity_id, name)
    local comps = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    for _, comp in ipairs(comps or {}) do
        if ComponentGetValue2(comp, "name") == name then return comp end
    end
end

local function setVar(entity_id, name, field, value)
    local comp = getVarComp(entity_id, name)
    if not comp then
        comp = EntityAddComponent2(entity_id, "VariableStorageComponent", { name = name })
    end
    ComponentSetValue2(comp, field, value)
end

local function getVar(entity_id, name, field, default)
    local comp = getVarComp(entity_id, name)
    if not comp then return default end
    local v = ComponentGetValue2(comp, field)
    if v == nil then return default end
    return v
end

-- =============================================================================
-- Capture
-- =============================================================================

--- @param entity_id number
--- @return string b64
local function serialize(entity_id)
    log.debug("entity_serializer.serialize: capture de l'entité " .. tostring(entity_id))

    local ge_entity = LoadGameEffectEntityTo(entity_id, POLY_FILE)
    local ge_comp = EntityGetFirstComponentIncludingDisabled(ge_entity, "GameEffectComponent")
    if not ge_comp then
        log.error("entity_serializer.serialize: pas de GameEffectComponent sur ge_entity " .. tostring(ge_entity))
        return b64Encode("")
    end

    local raw = ComponentGetValue2(ge_comp, "mSerializedData")
    log.debug("entity_serializer.serialize: " .. tostring(raw and #raw or 0) .. " octet(s) capturés")

    EntityKill(EntityGetRootEntity(ge_entity))

    return b64Encode(raw or "")
end

-- =============================================================================
-- Restitution - API à base de builder + composants, sans callback ni état
-- Lua partagé (cf note en tête de fichier)
-- =============================================================================

local SCAN_WINDOW = 64   -- marge d'ids scannés après le builder à chaque tentative - plus large que nécessaire pour une seule reconstruction, car il faut parfois sauter par-dessus les entités internes (taguées) d'autres reconstructions en cours en même temps (storageStone imbriquées)
local MAX_ATTEMPTS = 60  -- ~1s à 60 fps avant d'abandonner

--- Démarre la reconstruction d'une entité et retourne IMMÉDIATEMENT un
--- "builder" : une entité de suivi utilisable tout de suite (contrairement
--- à l'entité reconstruite, qui n'existe pas encore). L'appelant doit
--- appeler tryResolve(builder_id) à chaque frame (typiquement via un
--- LuaComponent programmé sur le builder lui-même) jusqu'à obtenir
--- bstone_phase == "resolved" ou "failed" (cf getPhase/getResolvedEntity).
--- @param b64 string  produit par serialize()
--- @param x number
--- @param y number
--- @return number builder_id
local function beginDeserialize(b64, x, y)
    local raw = b64Decode(b64)
    log.debug("entity_serializer.beginDeserialize: " .. #b64 .. " octet(s) b64 (" .. #raw .. " décodés), cible (" .. x .. "," .. y .. ")")

    local placeholder = EntityCreateNew()
    EntityAddTag(placeholder, INTERNAL_TAG)

    local ge_entity = LoadGameEffectEntityTo(placeholder, POLY_FILE)
    EntityAddTag(ge_entity, INTERNAL_TAG)

    local ge_comp = EntityGetFirstComponentIncludingDisabled(ge_entity, "GameEffectComponent")
    if not ge_comp then
        log.error("entity_serializer.beginDeserialize: pas de GameEffectComponent sur ge_entity " .. tostring(ge_entity))
    else
        ComponentSetValue2(ge_comp, "mSerializedData", raw)
    end

    local builder = EntityCreateNew()
    EntityAddTag(builder, INTERNAL_TAG)
    setVar(builder, "bstone_x", "value_float", x)
    setVar(builder, "bstone_y", "value_float", y)
    setVar(builder, "bstone_phase", "value_string", "resolving")
    setVar(builder, "bstone_attempts", "value_int", 0)
    setVar(builder, "bstone_root_entity", "value_int", 0)

    log.debug("entity_serializer.beginDeserialize: builder=" .. builder .. " (placeholder=" .. placeholder .. ", ge_entity=" .. ge_entity .. ")")

    return builder
end

--- @param builder_id number
--- @return string  "resolving" | "resolved" | "failed"
local function getPhase(builder_id)
    return getVar(builder_id, "bstone_phase", "value_string", "resolving")
end

--- Valide seulement une fois getPhase(builder_id) == "resolved".
--- @param builder_id number
--- @return number
local function getResolvedEntity(builder_id)
    return getVar(builder_id, "bstone_root_entity", "value_int", 0)
end

--- À appeler à chaque frame tant que getPhase(builder_id) == "resolving"
--- (cf lab_stone_builder_tick.lua). Scanne les ids juste après le builder ;
--- si l'entité reconstruite est trouvée, la positionne et passe la phase à
--- "resolved". Sinon incrémente le compteur de tentatives (stocké sur le
--- builder, PAS en local Lua - cf note en tête de fichier) et passe à
--- "failed" au-delà de MAX_ATTEMPTS.
--- @param builder_id number
local function tryResolve(builder_id)
    local x = getVar(builder_id, "bstone_x", "value_float", 0)
    local y = getVar(builder_id, "bstone_y", "value_float", 0)
    local attempts = getVar(builder_id, "bstone_attempts", "value_int", 0)

    local found = nil
    for id = builder_id + 1, builder_id + SCAN_WINDOW do
        if EntityGetIsAlive(id) and not EntityHasTag(id, INTERNAL_TAG) then
            found = id
            break
        end
    end

    log.debug("entity_serializer.tryResolve: builder " .. builder_id .. ", tentative " .. (attempts + 1) .. "/" .. MAX_ATTEMPTS .. ", scan [" .. (builder_id + 1) .. ".." .. (builder_id + SCAN_WINDOW) .. "] -> " .. tostring(found))

    if found then
        EntityApplyTransform(found, x, y)
        setVar(builder_id, "bstone_root_entity", "value_int", found)
        setVar(builder_id, "bstone_phase", "value_string", "resolved")
        log.debug("entity_serializer.tryResolve: builder " .. builder_id .. " résolu -> " .. found)
        return
    end

    attempts = attempts + 1
    setVar(builder_id, "bstone_attempts", "value_int", attempts)

    if attempts >= MAX_ATTEMPTS then
        log.error("entity_serializer.tryResolve: builder " .. builder_id .. " : entité désérialisée introuvable après " .. MAX_ATTEMPTS .. " tentatives (fenêtre de scan " .. SCAN_WINDOW .. ")")
        setVar(builder_id, "bstone_phase", "value_string", "failed")
    end
end

return {
    b64Encode         = b64Encode,
    b64Decode         = b64Decode,
    serialize         = serialize,
    beginDeserialize  = beginDeserialize,
    tryResolve        = tryResolve,
    getPhase          = getPhase,
    getResolvedEntity = getResolvedEntity,
}