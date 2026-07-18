local nxml = dofile_once("mods/blankStone/lib/nxml.lua")
local content = ModTextFileGetContent("data/biome/_pixel_scenes.xml")
local xml = nxml.parse(content)
local worldsize = ModTextFileGetContent("data/compatibilitydata/worldsize.txt") or 35840
local MAX_PW = 3

-- {x, y, file, mode}
-- mode : "main_only" | "pw_only" | "all"
local MOD_PATH = "mods/blankStone/files/"
local BASE_PATH = MOD_PATH .. "entities/items/books/"
local stuffs = {
    { x = -4920,  y =  900,   file = BASE_PATH .. "book_infuse.xml",      mode = "main_only"   }, -- Alchimist book
    { x = -1820,  y = -4640,  file = BASE_PATH .. "book_purity.xml",      mode = "main_only"   }, -- Mimicium book
    { x =  10030, y =  4365,  file = BASE_PATH .. "book_magnum_opus.xml", mode = "main_only"   }, -- Wand Tower book

    { x = -4920,  y =  900,   file = BASE_PATH .. "book_infuse_lies.xml",      mode = "pw_only"   }, -- False Alchimist book
    { x = -1820,  y = -4640,  file = BASE_PATH .. "book_purity_lies.xml",      mode = "pw_only"   }, -- False Mimicium book
    { x =  10030, y =  4365,  file = BASE_PATH .. "book_magnum_opus_lies.xml", mode = "pw_only"   }, -- False Wand Tower book

    { x = -14150,  y = 17300,   file = MOD_PATH .. "entities/progress/progress_scene.xml",          mode = "main_only"},  -- Progress under the Gold Room Lava
    { x = -14150,  y = 17300,   file = MOD_PATH .. "entities/progress/progress.xml",                mode = "main_only"},  -- Progress under the Gold Room Lava
    { x = -14150,  y = 17300,   file = MOD_PATH .. "entities/progress/progress_enter_trigger.xml",  mode = "main_only"},  -- Progress under the Gold Room Lava
    { x = -14335,  y = 17315,   file = MOD_PATH .. "entities/progress/progress_portal.xml",         mode = "main_only"},  -- Progress under the Gold Room Lava

    { x = -5030,  y = 910,   file = MOD_PATH .. "pixelscenes/alchemist_portal.xml",         mode = "main_only"},  -- Alchemist Portal to Progress
    { x = -5065,  y = 880,   file = MOD_PATH .. "entities/progress/alchemist_portal.xml",   mode = "main_only"},  -- Alchemist Portal to Progress

    -- HIDDEN TEXT

    { x = 0, y = 0, file = MOD_PATH .. "entities/hidden_message/hidden_alchemist.xml", mode = "main_only" }, -- Alchemist quintessence texte

}


local pixel_scenes = xml:first_of("mBufferedPixelScenes")

for _, stuff in ipairs(stuffs) do
    local offsets = {}
    if stuff.mode == "main_only" then
        offsets = { 0 }
    elseif stuff.mode == "pw_only" then
        for i = -MAX_PW, MAX_PW do
            if i ~= 0 then table.insert(offsets, i) end
        end
    elseif stuff.mode == "all" then
        for i = -MAX_PW, MAX_PW do
            table.insert(offsets, i)
        end
    end

    for _, world_i in ipairs(offsets) do
        pixel_scenes:add_child(nxml.parse(string.format(
            '<PixelScene pos_x="%d" pos_y="%d" just_load_an_entity="%s" />',
            stuff.x + worldsize * world_i,
            stuff.y,
            stuff.file
        )))
    end
end

ModTextFileSetContent("data/biome/_pixel_scenes.xml", tostring(xml))