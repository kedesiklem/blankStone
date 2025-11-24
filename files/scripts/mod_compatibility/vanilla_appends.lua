local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local stone_base = "mods/blankstone/files/entities/abstract_stone.xml"

local function changeParent(entity, new_parent)
    local content = ModTextFileGetContent(entity)
    local xml = nxml.parse(content)
    local old_parent

    local base = xml:first_of("Base")
    if base and base.attr then
        old_parent = base.attr.file
        base.attr.file = new_parent
    else
        xml:add_child({ name = "Base", attr = { file = new_parent } })
    end

    ModTextFileSetContent(entity, tostring(xml))
    return old_parent
end

local function all_equal(t)
    if #t == 0 then return true end
    local first = t[1]
    for i = 2, #t do
        if t[i] ~= first then
            return false
        end
    end
    return true
end

local  vanilla_item_path = "data/entities/items/pickup/"
local vanilla_stone = {
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

if all_equal(old_parents) then
    -- Make sure to keep hierarchy consistent, only possible if all original parents are the same as in vanilla
    changeParent(stone_base, old_parents[vanilla_stone[1]])
else
    log.error("Cannot maintain hierarchy consistency, original parents differ!")
end