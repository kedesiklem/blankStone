local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local MODID = ModTextFileGetContent("mods/blankStone/mod_id.txt")
local flag = MODID .. "_HONEY_SECRET"

local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

local honey_book = "mods/blankStone/files/entities/items/books/book_honey.xml"

local function changeDescription(entity, new_description)
    local info_ids = EntityGetComponentIncludingDisabled(entity,"ItemComponent")

    if not info_ids then log.error("can't change description without ItemComponent") return end

    for _, value in ipairs(info_ids) do
        ComponentSetValue2(value, "ui_description", new_description)
    end
end


if not GameHasFlagRun(flag) then
    GameAddFlagRun(flag)
    GamePrintImportant("$text_blankstone_honey_secret_title","$text_blankstone_honey_secret_desc")
    EntityLoad(honey_book,x,y)
else
    GamePrintImportant("$text_blankstone_honey_nosecret_title","$text_blankstone_honey_nosecret_desc")
end

changeDescription(entity_id, "$stone_blankstone_honeyStone_desc2")
