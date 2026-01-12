local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local MODID = "BlankStone"
local flag = MODID .. "_HONEY_SECRET"
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

local honey_book = "mods/blankStone/files/entities/items/books/book_honey.xml"

if not GameHasFlagRun(flag) then
    GameAddFlagRun(flag)
    GamePrintImportant("$text_blankstone_honey_secret_title","$text_blankstone_honey_secret_desc")
    EntityLoad(honey_book,x,y)
else
    GamePrintImportant("$text_blankstone_honey_nosecret_title","$text_blankstone_honey_nosecret_desc")
end

utils.changeDescription(entity_id, "$stone_blankstone_honeyStone_desc2")
