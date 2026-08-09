dofile_once( "data/scripts/lib/utilities.lua" )
local Q = dofile_once("mods/blankStone/files/scripts/magic/quest_utils.lua")

local perk_pickup_original = perk_pickup
local perk_spawn_original = perk_spawn

function perk_pickup( entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks, no_perk_entity_ )

	perk_pickup_original( entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks, no_perk_entity_ )

	if ( entity_who_picked == nil ) or ( EntityGetIsAlive( entity_who_picked ) == false ) then
		return
	end

	if ( EntityHasTag( entity_who_picked, "player_unit" ) == false ) then
		return
	end

	if ( not Q.isBanned() ) then
		Q.banThroughPerk()
	end

end

function perk_spawn( x, y, perk_id, dont_remove_other_perks_ )
	local PERK_LESS = ModSettingGet("blankStone.perk_less")
	if PERK_LESS then return else
		perk_spawn_original(x, y, perk_id, dont_remove_other_perks_)
	end
end