local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local stone_base = "mods/blankstone/files/entities/abstract_stone.xml"

local function changeParent(entity, new_parent)
    local content = ModTextFileGetContent(entity)
    local xml = nxml.parse(content)

    local base = xml:first_of("Base")
    if base and base.attr then
        base.attr.file = new_parent
    else
        xml:add_child({ name = "Base", attr = { file = new_parent } })
    end

    ModTextFileSetContent(entity, tostring(xml))
end

local  vanilla_item_path = "data/entities/items/pickup/"
local vanilla_stone = {
    "waterstone",
    "brimstone",
    "thunderstone",
    "stonestone",
    "poopstone",
}

for _, value in pairs(vanilla_stone) do
    changeParent(vanilla_item_path .. value .. ".xml", stone_base)
end