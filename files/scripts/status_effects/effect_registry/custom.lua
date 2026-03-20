local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
dofile_once("data/scripts/lib/utilities.lua")

D = {
    ["UNLIMITED_SPELLS"] = {
        func = function( entity_who_hold )
			-- Skip if perk
			if GameHasFlagRun("PERK_PICKED_UNLIMITED_SPELLS") then return end

			local world_entity_id = GameGetWorldStateEntity()
			if( world_entity_id ~= nil ) then
				local comp_worldstate = EntityGetFirstComponent( world_entity_id, "WorldStateComponent" )
				if( comp_worldstate ~= nil ) then
					if ComponentGetValue2(comp_worldstate, "perk_infinite_spells") then return end
					ComponentSetValue( comp_worldstate, "perk_infinite_spells", "1" )
				end
			end

			-- this goes through the items player is holding and sets their uses_remaining to -1
			GameRegenItemActionsInPlayer( entity_who_hold )

			-- UI refreshing, for some reason the uses_remaining remains somewhere
			-- This selects the current wand again, which seems to fix the uses_remaining remaining in various uses
			local inventory2_comp = EntityGetFirstComponent( entity_who_hold, "Inventory2Component" )
			if( inventory2_comp ) then
				ComponentSetValue( inventory2_comp, "mActualActiveItem", "0" )
			end
		end,
		func_remove = function( entity_who_hold )
			-- Skip if perk
			if GameHasFlagRun("PERK_PICKED_UNLIMITED_SPELLS") then return end

			local world_entity_id = GameGetWorldStateEntity()
			if( world_entity_id ~= nil ) then
				local comp_worldstate = EntityGetFirstComponent( world_entity_id, "WorldStateComponent" )
				if( comp_worldstate ~= nil ) then
					ComponentSetValue( comp_worldstate, "perk_infinite_spells", "0" )
				end
			end

			-- this goes through the items player is holding and sets their uses_remaining to -1
			GameRegenItemActionsInPlayer( entity_who_hold )

			-- UI refreshing, for some reason the uses_remaining remains somewhere
			-- This selects the current wand again, which seems to fix the uses_remaining remaining in various uses
			local inventory2_comp = EntityGetFirstComponent( entity_who_hold, "Inventory2Component" )
			if( inventory2_comp ) then
				ComponentSetValue( inventory2_comp, "mActualActiveItem", "0" )
			end
		end,
    },
	["PEACE_WITH_GODS"] = {
		func = function( entity_who_picked )
			if GameHasFlagRun("PERK_PICKED_PEACE_WITH_GODS") then return end

			if(GlobalsGetValue("TEMPLE_PEACE_WITH_GODS") == "1") then return end

			GlobalsSetValue( "TEMPLE_PEACE_WITH_GODS", "1" )
			if( GlobalsGetValue( "TEMPLE_SPAWN_GUARDIAN" ) == "1" ) then
				GlobalsSetValue( "TEMPLE_SPAWN_GUARDIAN", "0" )
			end
			-- necromancer_shop
			local steves = EntityGetWithTag( "necromancer_shop" )
			if( steves ~= nil ) then
				for index,entity_steve in ipairs(steves) do
					GetGameEffectLoadTo( entity_steve, "CHARM", true )
				end
			end
		end,
		func_remove = function( entity_who_picked )
			if GameHasFlagRun("PERK_PICKED_PEACE_WITH_GODS") then return end

			GlobalsSetValue( "TEMPLE_PEACE_WITH_GODS", "0" )
			GlobalsSetValue( "TEMPLE_SPAWN_GUARDIAN", "1" )
			if( GlobalsGetValue( "TEMPLE_SPAWN_GUARDIAN" ) == "1" ) then
				GlobalsSetValue( "TEMPLE_SPAWN_GUARDIAN", "0" )
			end
		end,
	},
	["NO_MORE_SHUFFLE"] = {
		func = function( entity_who_picked )
			if GameHasFlagRun("PERK_PICKED_NO_MORE_SHUFFLE_WANDS") then return end
			if(GlobalsGetValue("PERK_NO_MORE_SHUFFLE_WANDS") == "1") then return end

			GlobalsSetValue( "PERK_NO_MORE_SHUFFLE_WANDS", "1" )
			
			local wands = EntityGetWithTag("wand")

			for i,wand in ipairs(wands) do
				local ability_comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
				if( ability_comp ~= nil ) then
					local shuffler = "0"
					ComponentObjectSetValue( ability_comp, "gun_config", "shuffle_deck_when_empty", shuffler )
				end
			end 
		end,
		func_remove = function( entity_who_picked )
			if GameHasFlagRun("PERK_PICKED_NO_MORE_SHUFFLE_WANDS") then return end
			GlobalsSetValue( "PERK_NO_MORE_SHUFFLE_WANDS", "0" )
		end,
	},
    ["NO_CLIP"] = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/creative_flight.lua"),
}

return D