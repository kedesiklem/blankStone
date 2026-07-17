local PW = dofile_once("mods/blankStone/files/scripts/magic/quest_utils.lua")

local player = GetUpdatedEntityID()
if player == nil or player == 0 or not EntityGetIsAlive(player) then
	return
end

if PW.isBanned() then
	EntityRemoveComponent(player, GetUpdatedComponentID())
	return
end

local SECURITY_TAG = "pwn_security"

local function ensure_security_component(player)
	local existing = EntityGetComponent(player, "LuaComponent", SECURITY_TAG)
	if existing and #existing > 0 then
		return
	end

	EntityAddComponent2(player, "LuaComponent", {
		script_source_file = "mods/blankStone/files/scripts/magic/pw_security_check.lua",
		execute_every_n_frame = 1,
		execute_times = -1,
		remove_after_executed = false,
		_tags = SECURITY_TAG,
	})
end


if not PW.inMainWorld() then
	ensure_security_component(player)
end