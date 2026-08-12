dofile_once("data/scripts/lib/utilities.lua")

local self = GetUpdatedEntityID()
local portal = EntityGetRootEntity(self)

local unlock_flag = "blankstone_unlock_portal"
local alchemist_flag = "blankstone_alchemist_present"

if HasFlagPersistent(unlock_flag) and not GameHasFlagRun(alchemist_flag) then
    EntitySetComponentsWithTagEnabled(portal, "enabled_by_liquid", true)
else
    EntitySetComponentsWithTagEnabled(portal, "enabled_by_liquid", false)
end
