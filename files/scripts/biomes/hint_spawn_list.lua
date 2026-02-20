local nxml = dofile_once("mods/blankStone/lib/nxml.lua")
local content = ModTextFileGetContent("data/biome/_pixel_scenes.xml")
local xml = nxml.parse(content)
local worldsize = ModTextFileGetContent("data/compatibilitydata/worldsize.txt") or 35840
local MAX_PW = 3

-- {x, y, file, mode}
-- mode : "main_only" | "pw_only" | "all"
local books = {
    { x = -4920,  y =  900,   file = "book_infuse.xml",      mode = "main_only"   }, -- Alchimist book
    { x = -1820,  y = -4640,  file = "book_purity.xml",      mode = "main_only"   }, -- Mimicium book
    { x =  10030, y =  4365,  file = "book_magnum_opus.xml", mode = "main_only"   }, -- Wand Tower book

    { x = -4920,  y =  900,   file = "book_infuse_lies.xml",      mode = "pw_only"   }, -- False Alchimist book
    { x = -1820,  y = -4640,  file = "book_purity_lies.xml",      mode = "pw_only"   }, -- False Mimicium book
    { x =  10030, y =  4365,  file = "book_magnum_opus_lies.xml", mode = "pw_only"   }, -- False Wand Tower book
}

local BASE_PATH = "mods/blankStone/files/entities/items/books/"
local pixel_scenes = xml:first_of("mBufferedPixelScenes")

for _, book in ipairs(books) do
    local offsets = {}
    if book.mode == "main_only" then
        offsets = { 0 }
    elseif book.mode == "pw_only" then
        for i = -MAX_PW, MAX_PW do
            if i ~= 0 then table.insert(offsets, i) end
        end
    elseif book.mode == "all" then
        for i = -MAX_PW, MAX_PW do
            table.insert(offsets, i)
        end
    end

    for _, world_i in ipairs(offsets) do
        pixel_scenes:add_child(nxml.parse(string.format(
            '<PixelScene pos_x="%d" pos_y="%d" just_load_an_entity="%s" />',
            book.x + worldsize * world_i,
            book.y,
            BASE_PATH .. book.file
        )))
    end
end

ModTextFileSetContent("data/biome/_pixel_scenes.xml", tostring(xml))