
function OnModPreInit() 

end

function OnModInit() 

end

function OnModPostInit() 

end

function OnPlayerSpawned( player_entity ) 
    local pos_x, pos_y = EntityGetTransform( player_entity )
    EntityLoad( "mods/blankStone/files/entities/stone_toxic.xml", pos_x, pos_y )
    EntityLoad( "mods/blankStone/files/entities/blank_stone.xml", pos_x, pos_y )
    print( "blankStone: spawned stone_fire for player" )
end

function OnPlayerDied( player_entity ) 

end

function OnWorldInitialized() 

end

function OnWorldPreUpdate() 

end

function OnWorldPostUpdate() 

end

function OnBiomeConfigLoaded() 

end

function OnMagicNumbersAndWorldSeedInitialized() 

end

function OnPausedChanged( is_paused, is_inventory_pause ) 

end

function OnModSettingsChanged() 

end

function OnPausePreUpdate() 

end
	
ModLuaFileAppend( "data/scripts/item_spawnlists.lua", "mods/blankStone/files/scripts/inject_stones.lua")
print( "blankStone: injected stones into item spawnlists" )