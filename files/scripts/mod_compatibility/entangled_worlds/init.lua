-- Compatibility descriptor for Entangled Worlds (multiplayer, mod id "quant.ew").
--
-- Same shape as the other compat modules ({ mod_ids = {...}, <data> }), listed
-- in compat_loader.lua (the only place that names this mod). Each consumer
-- picks the fields it knows and ignores the others; this module only provides
-- `lab_storage`, read by buildings/lab/lab_state.lua.
--
-- lab_storage replaces the local ModSetting backend for permanent lab slots
-- while a multiplayer session is running, so that the HOST is the single
-- owner of their content. See lab_storage_host.lua for the why and the how.

return {
    mod_ids = { "quant.ew" },

    lab_storage = dofile_once("mods/blankStone/files/scripts/mod_compatibility/entangled_worlds/lab_storage_host.lua"),
}
