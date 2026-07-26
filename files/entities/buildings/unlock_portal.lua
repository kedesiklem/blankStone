local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
dofile_once("data/scripts/lib/utilities.lua")

local self = GetUpdatedEntityID()

local unlock_flag = "blankstone_unlock_portal"

if not HasFlagPersistent(unlock_flag) then
    local x,y = EntityGetTransform(self)
    local r = 15
    local result = U.getFirstOutofInventory(U.EntityGetInRadiusWithName(x,y,r,"quintessence"))
    if result~= nil then
        AddFlagPersistent(unlock_flag)
    end
end
