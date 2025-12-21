-- local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

function OnModPreInit() 

end

function OnModInit() 
end

function OnModPostInit() 

end

local function spawn_all_orb(player_entity)
    local pos_x, pos_y = EntityGetTransform( player_entity )
    for n=0, 11 do
        local orb_file = string.format("data/entities/items/orbs/orb_%02d.xml", n)
        EntityLoad(orb_file, pos_x + 10*n, pos_y - 10)
    end
end

function OnPlayerSpawned( player_entity ) 
    local pos_x, pos_y = EntityGetTransform( player_entity )
    
    --- FORGE TEST
    -- pos_x = 1500
    -- pos_y = 6050
    -- EntitySetTransform(player_entity, pos_x, pos_y)
    -- EntityLoad( "mods/blankStone/files/entities/blank_stone.xml", pos_x, pos_y )
    EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_unstable_teleport.xml", pos_x, pos_y )

    -- spawn_all_orb(player_entity)

    --- STONE TEST
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_gold.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_ambrosia.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_toxic.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_love.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_health.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_big.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_explosion.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_haste.xml", pos_x, pos_y )
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

-- based on Apotheosis
dofile_once("mods/blankStone/files/scripts/mod_compatibility/vanilla_appends.lua")
dofile_once("mods/blankStone/files/scripts/biomes/hint_spawn_list.lua")