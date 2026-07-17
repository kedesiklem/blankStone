local PW = dofile_once("mods/blankStone/files/scripts/magic/pw_utils.lua")

local player = GetUpdatedEntityID()
if player == nil or player == 0 or not EntityGetIsAlive(player) then
	return
end

local BAN_THRESHOLD_FRAMES = 600
local COUNTER_KEY = "blankstone_pwn_security_out_frames"

if PW.inMainWorld() then
	GlobalsSetValue(COUNTER_KEY, "0")
	EntityRemoveComponent(player, GetUpdatedComponentID())
	return
end

local counter = tonumber(GlobalsGetValue(COUNTER_KEY, "0")) or 0

if counter == 0 then
	PW.warnPlayer()
end

if counter < BAN_THRESHOLD_FRAMES then
	counter = counter + 1
	GlobalsSetValue(COUNTER_KEY, tostring(counter))

	if counter == BAN_THRESHOLD_FRAMES then
		PW.banPlayer()
        EntityRemoveComponent(player, GetUpdatedComponentID())
	end
end