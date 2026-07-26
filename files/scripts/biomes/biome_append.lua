local pixel_scene = dofile_once("mods/blankStone/files/scripts/lib/pixel_scene_injector.lua")
local worldsize = ModTextFileGetContent("data/compatibilitydata/worldsize.txt") or 35840
local MAX_PW = 3


-- mode : "main_only" | "pw_only" | "all"
local MOD_PATH = "mods/blankStone/files/"
local BASE_PATH = MOD_PATH .. "entities/items/books/"
local BIOME_IMPL_PATH = MOD_PATH .. "biome_impl/"
local stuffs = {
    { x = -4920,  y =  900,     file = BASE_PATH .. "book_infuse.xml",      mode = "main_only"   }, -- Alchimist book
    { x = -1820,  y = -4640,    file = BASE_PATH .. "book_purity.xml",      mode = "main_only"   }, -- Mimicium book
    { x =  2330, y =  7380,     file = BASE_PATH .. "book_magnum_opus.xml", mode = "main_only"   }, -- Dragon book

    { x = -4920,  y = 900,      file = BASE_PATH .. "book_infuse_lies.xml",      mode = "pw_only"   }, -- False Alchimist book
    { x = -1820,  y = -4640,    file = BASE_PATH .. "book_purity_lies.xml",      mode = "pw_only"   }, -- False Mimicium book
    { x =  2330,  y = 7380,     file = BASE_PATH .. "book_magnum_opus_lies.xml", mode = "pw_only"   }, -- False Dragon book

    { x = -1221, y = -4520,     file = "data/entities/misc/custom_cards/summon_rock.xml", mode = "main_only"   }, -- Rock Spell

    { -- Secret Beehive : progress & lab
        x = -14336, y = 17664,
        width = 1024, height = 512,
        material_filename    = BIOME_IMPL_PATH .. "secretbeehive/material%d.png",
        colors_filename      = BIOME_IMPL_PATH .. "secretbeehive/texture%d.png",
        background_filename  = BIOME_IMPL_PATH .. "secretbeehive/background%d.png",
        mode = "main_only",
    },

    { x = -5030,  y = 910,   file = MOD_PATH .. "pixelscenes/alchemist_portal.xml",         mode = "main_only"},  -- Alchemist Portal to Progress
    { x = -5065,  y = 880,   file = MOD_PATH .. "entities/buildings/alchemist_portal.xml",  mode = "main_only"},  -- Alchemist Portal to Progress

    { x = 2343,  y = 7473,   file = MOD_PATH .. "pixelscenes/dragon_portal.xml",  mode = "main_only"},   -- Dragon Portal to Progress
    { x = 2343,  y = 7473,   file = MOD_PATH .. "entities/buildings/dragon_portal.xml",  mode = "main_only"},   -- Dragon Portal to Progress

    -- HIDDEN TEXT


}

local function offsetsForMode(mode)
    if mode == "main_only" then
        return { 0 }
    elseif mode == "pw_only" then
        local offsets = {}
        for i = -MAX_PW, MAX_PW do
            if i ~= 0 then table.insert(offsets, i) end
        end
        return offsets
    elseif mode == "all" then
        local offsets = {}
        for i = -MAX_PW, MAX_PW do
            table.insert(offsets, i)
        end
        return offsets
    end
    return {}
end

local entries_xml = {}

for _, stuff in ipairs(stuffs) do
    for _, world_i in ipairs(offsetsForMode(stuff.mode)) do
        local x = stuff.x + worldsize * world_i
        local y = stuff.y

        if stuff.file then
            table.insert(entries_xml, pixel_scene.buildEntityScene(x, y, stuff.file))
        elseif stuff.width and stuff.height then
            local tiles = pixel_scene.buildTiledMaterialScene(
                x, y, stuff.width, stuff.height,
                stuff.material_filename, stuff.colors_filename, stuff.background_filename
            )
            for _, tile_xml in ipairs(tiles) do
                table.insert(entries_xml, tile_xml)
            end
        else
            table.insert(entries_xml, pixel_scene.buildMaterialScene(
                x, y, stuff.material_filename, stuff.colors_filename, stuff.background_filename
            ))
        end
    end
end

pixel_scene.inject(entries_xml)