local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

D = {
    ["UNLIMITED_SPELLS"] = {
        func = function( entity_who_hold )
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
    }
}

return D