dofile_once( "data/scripts/lib/utilities.lua" )

local QUEST_FLAG_NAME = "blankstone_quest_no_perk_fail"

local function appliquer_effet_quete_brisee( entity_who_picked )

	GamePrintImportant( "$text_blankstone_quest_no_perk_fail_title", "$text_blankstone_quest_no_perk_fail_desc" )

end

local perk_pickup_original = perk_pickup

function perk_pickup( entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks, no_perk_entity_ )

	perk_pickup_original( entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks, no_perk_entity_ )

	if ( entity_who_picked == nil ) or ( EntityGetIsAlive( entity_who_picked ) == false ) then
		return
	end

	if ( EntityHasTag( entity_who_picked, "player_unit" ) == false ) then
		return
	end

	if ( GameHasFlagRun( QUEST_FLAG_NAME ) == false ) then
		GameAddFlagRun( QUEST_FLAG_NAME )
		appliquer_effet_quete_brisee( entity_who_picked )
	end

end