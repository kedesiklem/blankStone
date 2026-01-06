local nxml = dofile_once("mods/blankStone/lib/nxml.lua")
local content = ModTextFileGetContent("data/biome/_pixel_scenes.xml")
local xml = nxml.parse(content)

-- Alchimist
xml:first_of("mBufferedPixelScenes"):add_child(nxml.parse([[
    <PixelScene pos_x="-4920" pos_y="900" just_load_an_entity="mods/blankStone/files/entities/items/books/book_infuse.xml" />
]]))

-- Mimicium
xml:first_of("mBufferedPixelScenes"):add_child(nxml.parse([[
    <PixelScene pos_x="-1820" pos_y="-4640" just_load_an_entity="mods/blankStone/files/entities/items/books/book_purity.xml" />
]]))

-- Wand Tower
xml:first_of("mBufferedPixelScenes"):add_child(nxml.parse([[
    <PixelScene pos_x="10030" pos_y="4365" just_load_an_entity="mods/blankStone/files/entities/items/books/book_opus_magnum.xml" />
]]))
ModTextFileSetContent("data/biome/_pixel_scenes.xml", tostring(xml))