local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local MODID = "blankStone"
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
dofile_once("data/scripts/lib/utilities.lua")

local self = GetUpdatedEntityID()
local portal = EntityGetRootEntity(self)


local flag = "blankstone_alchemist_portal"

if HasFlagPersistent(flag) then 
    EntitySetComponentsWithTagEnabled(portal, "enabled_by_liquid", true)
else
    local x,y = EntityGetTransform(self)
    local r = 15
    local result = U.getFirstOutofInventory(U.EntityGetInRadiusWithName(x,y,r,"quintessence"))

    if result~= nil then
        AddFlagPersistent(flag)
    end

    EntitySetComponentsWithTagEnabled(portal, "enabled_by_liquid", false)

end
