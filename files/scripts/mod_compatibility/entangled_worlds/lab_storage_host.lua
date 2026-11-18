-- Lab storage backend for Entangled Worlds (EW): the HOST owns the content of
-- permanent lab slots.
--
-- WHY
--   Permanent slots store their content in a ModSetting, i.e. in the
--   mod_settings.bin of the machine that runs the code. In EW every player
--   has such a file, but the world (and therefore the lab) is shared: players
--   would see, write and take different contents for the same slot, items
--   written by a client would be lost when another machine hosts the next
--   session, and two machines could both "restore" the same item.
--
-- HOW (roles, published by ew_module.lua through Globals)
--   host    Reads/writes its own ModSettings (single source of truth) and
--           announces every change to the clients ("apply").
--   client  Never touches its own ModSettings for permanent slots. It reads a
--           replica of the host's state (kept in Globals) and sends requests
--           to the host:
--             set  = compare-and-set (the request carries the content the
--                    client believed was in the slot; the host refuses it if
--                    someone else changed the slot meanwhile and refunds the
--                    item),
--             take = the host removes the content and grants it to ONE peer,
--                    so an item can never be duplicated.
--   none    EW is enabled but the bridge is not running (not connected, or the
--           host runs a version without this module): isActive() is false and
--           lab_state falls back to the local backend, i.e. the previous
--           behaviour.
--
-- WHY GLOBALS AND NOT LUA TABLES
--   This file is loaded from two places: from the lab scripts (game context)
--   and from ew_module.lua (EW context, which owns the network RPCs). Noita
--   does not guarantee that both share the same Lua state, so every piece of
--   shared state goes through Globals, which is engine-level and per machine
--   (EW does not synchronise arbitrary Globals). Messages for the network are
--   queued in a Globals "outbox" that ew_module.lua drains every frame.
--
-- Backend contract: see storage/backend_run.lua.

local ids = dofile_once("mods/blankStone/files/scripts/buildings/lab/storage/permanent_id.lua")

local G_ROLE         = "blankStone_ew_role"          -- "host" | "client" | ""
local G_SYNCED       = "blankStone_ew_synced"        -- "1" once a client has the host's snapshot
local G_REPLICA      = "blankStone_ew_replica_"      -- + key => raw content ("" = empty)
local G_REPLICA_KEYS = "blankStone_ew_replica_keys"  -- comma separated list of known keys
local G_OUT          = "blankStone_ew_out_"          -- + n + "_" + field
local G_OUT_HEAD     = "blankStone_ew_out_head"      -- last popped message number
local G_OUT_TAIL     = "blankStone_ew_out_tail"      -- last pushed message number

local M = {}

-- =============================================================================
-- Role / bridge state (written by ew_module.lua)
-- =============================================================================

--- @return string role  "host", "client" or "" (bridge not running)
local function getRole()
    return GlobalsGetValue(G_ROLE, "")
end

--- @param role string "host" | "client"
function M.setRole(role)
    if GlobalsGetValue(G_ROLE, "") ~= role then
        GlobalsSetValue(G_ROLE, role)
    end
end

--- @return boolean
function M.isSynced()
    return GlobalsGetValue(G_SYNCED, "") == "1"
end

function M.setSynced()
    GlobalsSetValue(G_SYNCED, "1")
end

--- True when this backend must be used instead of the local one. A client is
--- only active once it has received the host's snapshot: before that (or if the
--- host never answers) it keeps using its local storage, so nothing it places
--- can be lost.
--- @return boolean
function M.isActive()
    local role = getRole()
    return role == "host" or (role == "client" and M.isSynced())
end

-- =============================================================================
-- Client replica of the host's state
-- =============================================================================

--- @param key string
--- @return string|nil raw
function M.getReplica(key)
    local raw = GlobalsGetValue(G_REPLICA .. key, "")
    if raw == "" then return nil end
    return raw
end

--- @param key string
--- @param raw string|nil  nil or "" = empty slot
function M.setReplica(key, raw)
    raw = raw or ""
    if raw ~= "" then
        local known = GlobalsGetValue(G_REPLICA_KEYS, "")
        local present = false
        for k in string.gmatch(known, "[^,]+") do
            if k == key then present = true break end
        end
        if not present then
            GlobalsSetValue(G_REPLICA_KEYS, known == "" and key or (known .. "," .. key))
        end
    end
    GlobalsSetValue(G_REPLICA .. key, raw)
end

--- @return table<string, string> key => raw, only non-empty slots
function M.replicaSnapshot()
    local out = {}
    for key in string.gmatch(GlobalsGetValue(G_REPLICA_KEYS, ""), "[^,]+") do
        local raw = M.getReplica(key)
        if raw then out[key] = raw end
    end
    return out
end

-- =============================================================================
-- Outbox (game context pushes, ew_module.lua pops and sends over the network)
-- =============================================================================

local OUT_FIELDS = { "op", "key", "prev", "raw" }

local function getInt(global_name)
    return tonumber(GlobalsGetValue(global_name, "0")) or 0
end

--- @param op string    "apply" (host -> clients), "set" or "take" (client -> host)
--- @param key string   permanent key
--- @param prev string|nil  "set" only: content the client believed was there
--- @param raw string|nil   "apply"/"set": the new content ("" = empty)
local function push(op, key, prev, raw)
    local n = getInt(G_OUT_TAIL) + 1
    local base = G_OUT .. n .. "_"
    GlobalsSetValue(base .. "op", op)
    GlobalsSetValue(base .. "key", key)
    GlobalsSetValue(base .. "prev", prev or "")
    GlobalsSetValue(base .. "raw", raw or "")
    GlobalsSetValue(G_OUT_TAIL, tostring(n))
end

--- @return table|nil msg  { op, key, prev, raw }, nil when the outbox is empty
function M.popOutbox()
    local head, tail = getInt(G_OUT_HEAD), getInt(G_OUT_TAIL)
    if head >= tail then return nil end

    local n = head + 1
    local base = G_OUT .. n .. "_"
    local msg = {}
    for _, field in ipairs(OUT_FIELDS) do
        msg[field] = GlobalsGetValue(base .. field, "")
        GlobalsSetValue(base .. field, "")
    end

    if n >= tail then
        -- queue drained: restart numbering so the Globals keys get reused
        GlobalsSetValue(G_OUT_HEAD, "0")
        GlobalsSetValue(G_OUT_TAIL, "0")
    else
        GlobalsSetValue(G_OUT_HEAD, tostring(n))
    end
    return msg
end

-- =============================================================================
-- Authority (HOST ONLY): the ModSettings are the source of truth.
-- Called by the host's RPC handlers in ew_module.lua.
-- =============================================================================

local authority = {}
M.authority = authority

--- @param key string
--- @return string raw  "" when empty
function authority.get(key)
    local raw = ModSettingGet(ids.settingId(key))
    if raw == nil then return "" end
    return raw
end

--- Compare-and-set: writes `raw` only if the slot still holds `prev`.
--- @param key string
--- @param prev string  expected current content ("" = expected empty)
--- @param raw string   new content
--- @return boolean ok, string current  current = content after the call
function authority.compareAndSet(key, prev, raw)
    local current = authority.get(key)
    if current ~= (prev or "") then
        return false, current
    end
    ModSettingSet(ids.settingId(key), raw or "")
    return true, raw or ""
end

--- Atomic read + empty.
--- @param key string
--- @return string|nil raw  nil when the slot was already empty
function authority.take(key)
    local current = authority.get(key)
    if current == "" then return nil end
    ModSettingSet(ids.settingId(key), "")
    return current
end

--- @return table<string, string> key => raw, only non-empty slots
function authority.listAll()
    local out = {}
    local prefix_len = #ids.PREFIX
    for i = 0, ModSettingGetCount() - 1 do
        local setting_id = ModSettingGetAtIndex(i)
        if setting_id and setting_id:sub(1, prefix_len) == ids.PREFIX then
            local raw = ModSettingGet(setting_id)
            if raw ~= nil and raw ~= "" then
                out[setting_id:sub(prefix_len + 1)] = raw
            end
        end
    end
    return out
end

-- =============================================================================
-- Backend contract (called by lab_state.lua from the game context)
-- =============================================================================

function M.read(_, _, permanent_key)
    if getRole() == "host" then
        local raw = authority.get(permanent_key)
        if raw == "" then return nil end
        return raw
    end
    return M.getReplica(permanent_key)
end

function M.write(_, _, permanent_key, raw)
    if getRole() == "host" then
        ModSettingSet(ids.settingId(permanent_key), raw)
        push("apply", permanent_key, nil, raw)
        return
    end

    -- Client: update the replica optimistically (the interaction code shows the
    -- result right away) and let the host arbitrate.
    local prev = M.getReplica(permanent_key) or ""
    M.setReplica(permanent_key, raw)
    push("set", permanent_key, prev, raw)
end

function M.erase(instance_id, slot_index, permanent_key)
    M.write(instance_id, slot_index, permanent_key, "")
end

function M.take(_, _, permanent_key)
    if getRole() == "host" then
        local raw = authority.take(permanent_key)
        if raw then
            push("apply", permanent_key, nil, "")
        end
        return raw, false
    end

    -- Client: the host decides who gets the item. The answer comes back as a
    -- "grant" handled by ew_module.lua -> lab_factory.grantPickup.
    push("take", permanent_key)
    return nil, true
end

return M
