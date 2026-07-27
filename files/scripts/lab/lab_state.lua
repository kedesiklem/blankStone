-- based on Purgatory by Priskip

-- Persistance du contenu d'un slot. Deux backends :
--
--   - "run"       (comportement d'origine) : GlobalsGetValue/SetValue, clé =
--     préfixe + instance_id du lab_root (généré une fois via
--     utils.getOrCreateInstanceId, aléatoire, régénéré à chaque nouveau spawn
--     du lab_root) + index du slot. Réinitialisé à chaque nouvelle partie
--     (documenté ainsi par le wiki de modding Noita).
--
--   - "permanent" (nouveau) : ModSettingGet/ModSettingSet, clé = préfixe +
--     un identifiant FIXE porté par le slot lui-même (VariableStorageComponent
--     blankStoneLabPermanentKey, cf lab_slot_permanent.xml). Stocké dans
--     mod_config.xml, à l'intérieur du dossier de sauvegarde (save00/) mais
--     EN DEHORS de l'état de la partie en cours : survit à la mort, à un
--     "new game", ne survit PAS à une suppression du dossier de sauvegarde.
--
-- Pourquoi une clé fixe et pas instance_id pour le backend permanent :
-- instance_id est généré aléatoirement à la première lecture après CHAQUE
-- spawn du lab_root (cf utils.getOrCreateInstanceId). Un lab qui réapparaît
-- dans une nouvelle partie obtient un nouvel instance_id : l'utiliser comme
-- clé de stockage permanent ferait qu'on ne retrouverait jamais le contenu
-- d'une partie précédente. La clé permanente doit donc être écrite en dur
-- dans le slot lui-même (au niveau de l'entité/XML), pas calculée à l'exécution.
--
-- ModSettingGet/Set acceptent n'importe quel id string sans déclaration
-- préalable dans settings.lua (cette déclaration n'est nécessaire que pour
-- les réglages exposés dans le menu Mod Settings) : à vérifier en jeu une
-- fois si un doute subsiste, mais c'est l'usage établi pour du stockage
-- clé/valeur ad-hoc dans les mods Noita.

local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log   = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local RUN_PREFIX       = "blankStone_lab_"
local PERMANENT_PREFIX = "blankStone.lab_permanent_"

--- @param instance_id string
--- @param slot_index number
--- @return string
local function runKey(instance_id, slot_index)
    return RUN_PREFIX .. instance_id .. "_" .. tostring(slot_index)
end

--- @param permanent_key string
--- @return string
local function permanentKey(permanent_key)
    return PERMANENT_PREFIX .. permanent_key
end

-- Garde-fou (mémoire du process uniquement, pas persisté) : avertit si deux
-- slots permanents différents utilisent la même clé dans la même session -
-- erreur de configuration facile (copier-coller d'un lab_slot_permanent.xml
-- sans changer la clé) et silencieuse sinon (les deux slots partageraient le
-- même contenu sans que rien ne le signale).
local seen_permanent_keys = {}

--- @param permanent_key string
--- @param slot_id number
local function warnIfDuplicateKey(permanent_key, slot_id)
    local seen_by = seen_permanent_keys[permanent_key]
    if seen_by and seen_by ~= slot_id then
        log.error("lab_state: DEUX slots permanents utilisent la même clé '" .. permanent_key ..
            "' (" .. seen_by .. " et " .. slot_id .. ") - ils partagent le même contenu, c'est presque sûrement un bug de configuration (clé pas rendue unique dans le XML)")
    end
    seen_permanent_keys[permanent_key] = slot_id
end

--- @param instance_id string
--- @param slot_index number
--- @param permanent_key string|nil  si fourni (non-nil, non-vide), lit dans le
---        stockage permanent (ModSetting) sous cette clé fixe, sinon dans le
---        stockage par run (Globals) sous instance_id+slot_index.
--- @return table|nil content  nil si le slot est vide
local function getSlotContent(instance_id, slot_index, permanent_key)
    if permanent_key and permanent_key ~= "" then
        local raw = ModSettingGet(permanentKey(permanent_key))
        if raw == nil or raw == "" then return nil end
        return utils.deserializeData(raw)
    end

    local raw = GlobalsGetValue(runKey(instance_id, slot_index), "")
    if raw == "" then return nil end
    return utils.deserializeData(raw)
end

--- @param instance_id string
--- @param slot_index number
--- @param content table
--- @param permanent_key string|nil
local function setSlotContent(instance_id, slot_index, content, permanent_key)
    local raw = utils.serializeData(content)

    if permanent_key and permanent_key ~= "" then
        ModSettingSet(permanentKey(permanent_key), raw)
        log.debug("lab_state: slot permanent '" .. permanent_key .. "' rempli")
        return
    end

    GlobalsSetValue(runKey(instance_id, slot_index), raw)
    log.debug("lab_state: slot " .. slot_index .. " de " .. instance_id .. " rempli")
end

--- @param instance_id string
--- @param slot_index number
--- @param permanent_key string|nil
local function clearSlotContent(instance_id, slot_index, permanent_key)
    if permanent_key and permanent_key ~= "" then
        ModSettingSet(permanentKey(permanent_key), "")
        log.debug("lab_state: slot permanent '" .. permanent_key .. "' vidé")
        return
    end

    GlobalsSetValue(runKey(instance_id, slot_index), "")
    log.debug("lab_state: slot " .. slot_index .. " de " .. instance_id .. " vidé")
end

return {
    getSlotContent      = getSlotContent,
    setSlotContent      = setSlotContent,
    clearSlotContent    = clearSlotContent,
    warnIfDuplicateKey  = warnIfDuplicateKey,
}