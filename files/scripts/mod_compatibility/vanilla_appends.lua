--- Mod Compatibility: Change vanilla stone items to be purifiable stones

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local T = dofile_once("mods/blankStone/files/scripts/tools.lua")

local stone_base = "mods/blankStone/files/entities/purifiable.xml"

local function addPurifiable(entity, new_parent)
    local xml = T.getXML(entity)
    T.addComponent(xml, "Base", { file = new_parent })
    T.setXML(entity, xml)
end

local  vanilla_item_path = "data/entities/items/pickup/"
local vanilla_stone = {
    "sun/sunseed",
    "wandstone",
    "waterstone",
    "brimstone",
    "thunderstone",
    "stonestone",
    "poopstone",
}

for _, value in pairs(vanilla_stone) do
    addPurifiable(vanilla_item_path .. value .. ".xml", stone_base)
end
