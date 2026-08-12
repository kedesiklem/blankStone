dofile_once("data/scripts/lib/utilities.lua")

local self = GetUpdatedEntityID()
local portal = EntityGetRootEntity(self)

local dragon_flag = "blankstone_dragon_present"
local unlock_flag = "blankstone_unlock_portal"

if HasFlagPersistent(unlock_flag) and not GameHasFlagRun(dragon_flag) then
    EntitySetComponentsWithTagEnabled(portal, "enabled_by_liquid", true)
else
    EntitySetComponentsWithTagEnabled(portal, "enabled_by_liquid", false)
end
