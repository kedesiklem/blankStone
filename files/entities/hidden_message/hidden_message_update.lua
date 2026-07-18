local MOD_PATH = "mods/blankStone/files/"

local entity_id = GetUpdatedEntityID()
local U   = dofile_once(MOD_PATH .. "scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local TARGET_ID_VAR = "hidden_message_target_id"

CACHE = CACHE or {}
local cache = CACHE[entity_id]

if not cache then
    cache = { emitters = {}, active = false, target_id = nil }
    CACHE[entity_id] = cache

    local target_var = U.getVariable(entity_id, TARGET_ID_VAR)
    cache.target_id = U.getValue(target_var, "value_string")

    if not cache.target_id then
        log.error("hidden_message: aucune VariableStorageComponent '" .. TARGET_ID_VAR .. "' trouvee sur l'entite " .. tostring(entity_id))
    end

    for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "ParticleEmitterComponent") or {}) do
        table.insert(cache.emitters, comp)
    end
end

local item = U.getActiveItem(U.getPlayer())
local held_id = item and U.getEntityIdentifier(item) or nil

local shouldBeActive = cache.target_id ~= nil and held_id == cache.target_id

if shouldBeActive ~= cache.active then
    for _, comp in ipairs(cache.emitters) do
        EntitySetComponentIsEnabled(entity_id, comp, shouldBeActive)
    end
    cache.active = shouldBeActive
end