local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local MODID = "BlankStone"
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")


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

local function spawn_all_stones(x,y, list, withgoldStone)
    log.debug("Spawn all stones")

    if not list then log.error("No stone to spawn") return end


    for key, value in pairs(list) do
        if key == "goldStone" and not withgoldStone then goto continue
        else
            log.debug("spawn stone [".. key .."] : ".. value.path)
            EntityLoad(value.path, x, y)
        end
        ::continue::
    end
end

local function on_player_first_spawned(player_id)

    local x, y = EntityGetTransform(player_id)
    local starter_blankstone = EntityLoad("mods/blankStone/files/entities/blank_stone.xml", x + 100, y - 50)
    utils.changeDescription(starter_blankstone,"$text_blankstone_starter_stone_desc")
end

function OnPlayerSpawned(player_entity)

    local flag = MODID .. "_PLAYER_SPAWNED"
    if not GameHasFlagRun(flag) then
        GameAddFlagRun(flag)
        on_player_first_spawned(player_entity)
    end

    -- =========== TEST ZONE ===================
    if BLANKSTONE_RELEASE then return end

    local pos_x, pos_y = EntityGetTransform( player_entity )

    local STONE_PATH = "mods/blankStone/files/entities/elemental_stone/"
    local BOOK_PATH = "mods/blankStone/files/entities/items/books/"

    -- EntityLoad( "mods/blankStone/files/entities/blank_stone.xml", pos_x, pos_y )
    -- spawn_all_stones(pos_x,pos_y, STONE_REGISTRY)

    --- FORGE TEST
    -- pos_x = 1500
    -- pos_y = 6050
    -- EntitySetTransform(player_entity, pos_x, pos_y)

    -- spawn_all_orb(player_entity)


    -- SPELL
    -- CreateItemActionEntity("BLANKSTONE_STONE_FUSER", pos_x, pos_y)

    -- MAGNUM OPUS 
    -- EntityLoad( "mods/blankStone/files/entities/quintessence_stone.xml", pos_x, pos_y )
    -- EntityLoad( "mods/blankStone/files/entities/magnum_opus/lapis_philosophorum.xml", pos_x, pos_y )

    --- STONE TEST

    -- EntityLoad( BOOK_PATH .."book_infuse.xml", pos_x, pos_y )
    -- EntityLoad( BOOK_PATH .."book_purity.xml", pos_x, pos_y )
    -- EntityLoad( BOOK_PATH .."book_magnum_opus.xml", pos_x, pos_y )


    -- EntityLoad( STONE_PATH .. "stone_honey.xml", pos_x, pos_y )
    -- EntityLoad( BOOK_PATH .."book_honey.xml", pos_x, pos_y )

    -- EntityLoad( STONE_PATH .. "stone_lava.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_poison_harmful.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_poison.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_whiskey.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_bones.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_magic_liquid.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_unstable_teleport.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_teleport.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_gold.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_ambrosia.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_toxic.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_love.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_health.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_big.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_explosion.xml", pos_x, pos_y )
    -- EntityLoad( STONE_PATH .. "stone_haste.xml", pos_x, pos_y )
    -- =========================================

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
ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/blankStone/files/actions.lua")
ModLuaFileAppend("data/scripts/status_effects/status_list.lua", "mods/blankStone/files/scripts/status_effects/status_effects.lua")

-- Translation
local translations = ModTextFileGetContent("data/translations/common.csv")
local new_translations = ModTextFileGetContent("mods/blankStone/translations.csv")
translations = translations .. "\n" .. new_translations .. "\n"
translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
ModTextFileSetContent("data/translations/common.csv", translations)