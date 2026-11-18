-- Lab storage backend: "permanent" storage on the local machine.
--
-- Content lives in a ModSetting (see permanent_id.lua), i.e. in this
-- machine's mod_settings.bin: outside of the run state, so it survives death
-- and "new game", but not the deletion of the save folder.
--
-- This is the default backend for permanent slots. It is only correct when
-- exactly one machine owns the world (single player). In multiplayer every
-- machine has its own mod_settings.bin, so a compatibility module may take
-- over (see lab_state.lua and mod_compatibility/compat_loader.lua).
--
-- Contract: see backend_run.lua.

local ids = dofile_once("mods/blankStone/files/scripts/buildings/lab/storage/permanent_id.lua")

local M = {}

function M.read(_, _, permanent_key)
    local raw = ModSettingGet(ids.settingId(permanent_key))
    if raw == nil or raw == "" then return nil end
    return raw
end

function M.write(_, _, permanent_key, raw)
    ModSettingSet(ids.settingId(permanent_key), raw)
end

function M.erase(_, _, permanent_key)
    ModSettingSet(ids.settingId(permanent_key), "")
end

return M
