-- based on Purgatory by Priskip

-- Persistence of a lab slot's content: a thin dispatcher over storage backends.
--
-- lab_factory.lua only talks to this file. This file decides WHERE a slot's
-- content lives, and never touches Globals / ModSettings directly (that is the
-- job of the backends in storage/).
--
-- Backends (contract documented in storage/backend_run.lua):
--
--   - run       storage/backend_run.lua    - Globals. Reset on every new run.
--               Used by every non-permanent slot.
--
--   - local     storage/backend_local.lua  - ModSetting in this machine's
--               mod_settings.bin. Survives death and "new game", not the
--               deletion of the save folder. Default for permanent slots.
--
--   - compat    a lab_storage table exposed by a compat module
--               (mod_compatibility/<mod>/init.lua, listed in
--               compat_loader.lua). When the matching mod is
--               enabled AND the module reports isActive(), it replaces the
--               local backend for permanent slots (e.g. a multiplayer
--               compat module making one machine the owner).
--
-- A slot is "permanent" when it has a permanent_key (see
-- lab_factory.computePermanentKey); the key is FIXED by the slot itself, not
-- computed from instance_id: a lab respawned in a new run gets a new
-- instance_id, so it could never find a previous run's content with it.
--
-- Public API (unchanged by the backend split, except takeSlotContent which is
-- new):
--   getSlotContent(instance_id, slot_index, permanent_key)  -> table | nil
--   setSlotContent(instance_id, slot_index, content, permanent_key)
--   clearSlotContent(instance_id, slot_index, permanent_key)
--   takeSlotContent(instance_id, slot_index, permanent_key) -> table | nil, pending
--   warnIfDuplicateKey(permanent_key, slot_id)

local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log   = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local C     = dofile_once("mods/blankStone/files/scripts/mod_compatibility/compat_utils.lua")

local backend_run   = dofile_once("mods/blankStone/files/scripts/buildings/lab/storage/backend_run.lua")
local backend_local = dofile_once("mods/blankStone/files/scripts/buildings/lab/storage/backend_local.lua")

--- Compat modules, listed in one place (compat_loader.lua). This file never
--- names a specific mod: it only looks for a `lab_storage` field.
local COMPAT_MODULES = dofile_once("mods/blankStone/files/scripts/mod_compatibility/compat_loader.lua")

--- @param permanent_key string|nil
--- @return table backend
local function selectBackend(permanent_key)
    if not permanent_key or permanent_key == "" then
        return backend_run
    end

    for _, compat in ipairs(COMPAT_MODULES) do
        if compat.lab_storage
            and C.isAnyEnabled(compat.mod_ids)
            and compat.lab_storage.isActive() then
            return compat.lab_storage
        end
    end

    return backend_local
end

-- Safety net (process memory only, not persisted): warns if two different
-- permanent slots use the same key in the same session - an easy configuration
-- mistake (copy-pasting a permanent slot XML without changing the key) that
-- would otherwise be silent (both slots would share the same content).
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
--- @param permanent_key string|nil  non-empty => permanent storage, else per-run
--- @return table|nil content  nil if the slot is empty
local function getSlotContent(instance_id, slot_index, permanent_key)
    local raw = selectBackend(permanent_key).read(instance_id, slot_index, permanent_key)
    if raw == nil or raw == "" then return nil end
    return utils.deserializeData(raw)
end

--- @param instance_id string
--- @param slot_index number
--- @param content table
--- @param permanent_key string|nil
local function setSlotContent(instance_id, slot_index, content, permanent_key)
    selectBackend(permanent_key).write(instance_id, slot_index, permanent_key, utils.serializeData(content))
    log.debug("lab_state: slot " .. slot_index .. " (key=" .. tostring(permanent_key) .. ") filled")
end

--- @param instance_id string
--- @param slot_index number
--- @param permanent_key string|nil
local function clearSlotContent(instance_id, slot_index, permanent_key)
    selectBackend(permanent_key).erase(instance_id, slot_index, permanent_key)
    log.debug("lab_state: slot " .. slot_index .. " (key=" .. tostring(permanent_key) .. ") emptied")
end

--- Atomically reads AND empties a slot. This is the only safe way to hand the
--- content over to a player: with a shared world two players may try to take
--- the same item, and a separate get + clear would duplicate it.
---
--- Synchronous backends return `content, false`. An asynchronous, arbitrated
--- backend (e.g. a multiplayer client) returns `nil, true`: the request was
--- sent, and the content is delivered later by the backend's own module
--- (see lab_factory.grantPickup).
--- @param instance_id string
--- @param slot_index number
--- @param permanent_key string|nil
--- @return table|nil content, boolean pending
local function takeSlotContent(instance_id, slot_index, permanent_key)
    local backend = selectBackend(permanent_key)

    local raw, pending
    if backend.take then
        raw, pending = backend.take(instance_id, slot_index, permanent_key)
    else
        raw = backend.read(instance_id, slot_index, permanent_key)
        if raw ~= nil and raw ~= "" then
            backend.erase(instance_id, slot_index, permanent_key)
        end
    end

    if pending then return nil, true end
    if raw == nil or raw == "" then return nil, false end
    return utils.deserializeData(raw), false
end

return {
    getSlotContent      = getSlotContent,
    setSlotContent      = setSlotContent,
    clearSlotContent    = clearSlotContent,
    takeSlotContent     = takeSlotContent,
    warnIfDuplicateKey  = warnIfDuplicateKey,
}
