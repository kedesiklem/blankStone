-- Lab storage backend: "run" (per-run) storage.
--
-- Content lives in the game Globals (GlobalsGetValue/GlobalsSetValue), keyed
-- by the lab_root instance id + slot index. The instance id is generated
-- randomly the first time it is read after each spawn of the lab_root
-- (utils.getOrCreateInstanceId), so the content is reset on every new run.
--
-- Backend contract (shared by every lab storage backend, see lab_state.lua):
--   read(instance_id, slot_index, permanent_key)  -> raw string | nil
--   write(instance_id, slot_index, permanent_key, raw)
--   erase(instance_id, slot_index, permanent_key)
--   take(...)  [optional] -> raw | nil, pending
--       Atomic "read then erase". Returns `nil, true` when the answer will
--       only arrive later (asynchronous, arbitrated backends).
-- `raw` is the string produced by utils.serializeData.

local RUN_PREFIX = "blankStone_lab_"

--- @param instance_id string
--- @param slot_index number
--- @return string
local function globalKey(instance_id, slot_index)
    return RUN_PREFIX .. instance_id .. "_" .. tostring(slot_index)
end

local M = {}

function M.read(instance_id, slot_index, _)
    local raw = GlobalsGetValue(globalKey(instance_id, slot_index), "")
    if raw == "" then return nil end
    return raw
end

function M.write(instance_id, slot_index, _, raw)
    GlobalsSetValue(globalKey(instance_id, slot_index), raw)
end

function M.erase(instance_id, slot_index, _)
    GlobalsSetValue(globalKey(instance_id, slot_index), "")
end

return M
