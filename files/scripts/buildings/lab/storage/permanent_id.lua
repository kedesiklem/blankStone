-- Single source of truth for the ModSetting id of a lab "permanent" slot.
--
-- A permanent slot is identified by a short key ("slot_3", see
-- lab_factory.computePermanentKey). The ModSetting that stores its content is
-- PREFIX .. key. Every component that needs the *setting id* (the local
-- backend, and any compat module's backend) must go through this module so
-- that the on-disk format of existing saves never diverges.
--
-- NOTE: ModSettings live in <save>/save00/mod_settings.bin (per machine), not
-- in mod_config.xml (which only holds the mod list).

local PREFIX = "blankStone.lab_permanent_"

--- @param permanent_key string  e.g. "slot_3"
--- @return string setting_id    e.g. "blankStone.lab_permanent_slot_3"
local function settingId(permanent_key)
    return PREFIX .. permanent_key
end

return {
    PREFIX    = PREFIX,
    settingId = settingId,
}
