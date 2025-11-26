--- Mod Compatibility: Change vanilla stone items to be purifiable stones

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local T = dofile_once("mods/blankStone/files/scripts/tools.lua")

local stone_base = "mods/blankstone/files/entities/abstract_stone.xml"

local function changeParent(entity, new_parent)
    local xml = T.getXML(entity)
    local old_parent = T.changeParent(xml, new_parent)
    T.setXML(entity, xml)
    return old_parent
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

local old_parents = {}
for _, value in pairs(vanilla_stone) do
    old_parents[value] =
        changeParent(vanilla_item_path .. value .. ".xml", stone_base)
end

if T.all_equal(old_parents) then
    -- Make sure to keep hierarchy consistent, only possible if all original parents are the same as in vanilla
    changeParent(stone_base, old_parents[vanilla_stone[1]])
else
    log.error("Cannot maintain hierarchy consistency, original parents differ!")
end