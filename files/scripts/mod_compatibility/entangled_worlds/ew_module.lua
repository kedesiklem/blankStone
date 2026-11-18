-- Entangled Worlds (EW) module of blankStone: network side of the
-- host-authoritative lab storage (see lab_storage_host.lua for the design).
--
-- Registered by entangled_worlds_appends.lua through
--   ModLuaFileAppend("mods/quant.ew/files/api/extra_modules.lua", <this file>)
-- and therefore executed by EW as a module, in EW's Lua context (`ctx` is
-- available, and so are the game APIs). Only the hooks listed at the bottom
-- are called by EW.
--
-- Message flow (all RPCs are reliable, i.e. ordered and delivered once):
--
--   client --request_set(key, prev, raw)--> host   compare-and-set
--   client --request_take(key)------------> host   atomic take
--   host   --apply(key, raw)--------------> clients  new authoritative content
--   host   --grant(peer, key, raw)--------> clients  item for ONE peer (take
--                                                    result, or refund of a
--                                                    placement that lost a race)
--   client --request_snapshot()-----------> host
--   host   --snapshot(entries)------------> clients  full state, on connection
--
-- EW delivers an RPC to every other peer, so each handler first checks that it
-- is the intended receiver (ctx.is_host, or the target peer id).

local ew_api = dofile_once("mods/quant.ew/files/api/ew_api.lua")

local utils       = dofile_once("mods/blankStone/files/scripts/utils.lua")
local lab_factory = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_factory.lua")
local storage     = dofile_once("mods/blankStone/files/scripts/mod_compatibility/entangled_worlds/lab_storage_host.lua")

local SNAPSHOT_RETRY_FRAMES = 300 -- a client asks again every 5s until it gets one

-- RPC order defines the message ids: it MUST be identical on every peer.
local rpc = ew_api.new_rpc_namespace("bsLab")

-- -----------------------------------------------------------------------------
-- Client -> host
-- -----------------------------------------------------------------------------

rpc.opts_reliable()
--- @param key string
--- @param prev_raw string  content the client believed the slot held ("" = empty)
--- @param raw string       content the client wants to store
function rpc.request_set(key, prev_raw, raw)
    if not ctx.is_host then return end
    local sender = ctx.rpc_peer_id

    local ok, current = storage.authority.compareAndSet(key, prev_raw, raw)
    if not ok and prev_raw == "" and raw ~= "" then
        -- The client placed an item in a slot that was filled in the meantime:
        -- its item is already gone from its hands, give it back.
        rpc.grant(sender, key, raw)
    end

    rpc.apply(key, current)
    lab_factory.refreshPermanentSlots(key)
end

rpc.opts_reliable()
--- @param key string
function rpc.request_take(key)
    if not ctx.is_host then return end
    local sender = ctx.rpc_peer_id

    local raw = storage.authority.take(key)
    if raw then
        rpc.grant(sender, key, raw)
    end

    rpc.apply(key, "")
    lab_factory.refreshPermanentSlots(key)
end

rpc.opts_reliable()
function rpc.request_snapshot()
    if not ctx.is_host then return end
    rpc.snapshot(storage.authority.listAll())
end

-- -----------------------------------------------------------------------------
-- Host -> clients
-- -----------------------------------------------------------------------------

rpc.opts_reliable()
--- @param key string
--- @param raw string  authoritative content ("" = empty)
function rpc.apply(key, raw)
    if ctx.is_host then return end

    local old = storage.getReplica(key) or ""
    if old == raw then return end -- e.g. the echo of our own optimistic update

    storage.setReplica(key, raw)
    lab_factory.refreshPermanentSlots(key)
end

rpc.opts_reliable()
--- @param target_peer string  peer that receives the item
--- @param key string
--- @param raw string
function rpc.grant(target_peer, key, raw)
    if ctx.my_id ~= target_peer then return end
    lab_factory.grantPickup(key, utils.deserializeData(raw))
end

rpc.opts_reliable()
--- @param entries table<string, string>  key => raw, non-empty slots only
function rpc.snapshot(entries)
    if ctx.is_host then return end

    local first = not storage.isSynced()
    local known = storage.replicaSnapshot()
    local changed = {}

    for key, raw in pairs(entries) do
        if known[key] ~= raw then
            storage.setReplica(key, raw)
            changed[key] = true
        end
    end
    for key in pairs(known) do
        if entries[key] == nil then
            storage.setReplica(key, "")
            changed[key] = true
        end
    end
    storage.setSynced()

    if first then
        -- Slots were restored from the local storage before we were synced.
        lab_factory.refreshPermanentSlots(nil)
    else
        for key in pairs(changed) do
            lab_factory.refreshPermanentSlots(key)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Hooks
-- -----------------------------------------------------------------------------

local module = {}

--- ctx.my_id and ctx.host_id are filled in by two separate messages from the
--- proxy (net_handling.proxy.peer_id / .host_id), and ctx.is_host is recomputed
--- each time one of them arrives. Until both are known, ctx.is_host can be nil
--- or a wrong `false` (even on the real host), so we do not claim any role yet:
--- the lab keeps using its local storage meanwhile.
--- @return boolean
local function identityKnown()
    return ctx.my_id ~= nil and ctx.host_id ~= nil and ctx.host_id ~= 0
end

--- Every frame: publish our role, send what the lab scripts queued, and make
--- sure a client eventually gets the host's snapshot.
function module.on_world_update()
    if not identityKnown() then return end

    local is_host = ctx.is_host == true
    storage.setRole(is_host and "host" or "client")

    while true do
        local msg = storage.popOutbox()
        if not msg then break end

        if msg.op == "apply" then
            rpc.apply(msg.key, msg.raw)
        elseif msg.op == "set" then
            rpc.request_set(msg.key, msg.prev, msg.raw)
        elseif msg.op == "take" then
            rpc.request_take(msg.key)
        end
    end

    if not is_host and not storage.isSynced() and GameGetFrameNum() % SNAPSHOT_RETRY_FRAMES == 0 then
        rpc.request_snapshot()
    end
end

--- Called when we connect, or when somebody else connects: the host (re)sends
--- the full state. Idempotent for clients that already have it.
function module.on_should_send_updates()
    if ctx.is_host then
        rpc.snapshot(storage.authority.listAll())
    end
end

--- A client asks for the state as soon as its player exists (messages received
--- before EW is ready are dropped, so the host's welcome snapshot may be lost).
function module.on_local_player_spawn()
    if not ctx.is_host then
        rpc.request_snapshot()
    end
end

return module
