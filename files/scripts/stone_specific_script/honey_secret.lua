local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")

local MODID = "BlankStone"
local flag = MODID .. "_HONEY_SECRET"
local honey_book = "mods/blankStone/files/entities/items/books/book_honey.xml"

local function drop_bee_message()
    local entity_id = GetUpdatedEntityID()
    local x,y = EntityGetTransform(entity_id)
    if not GameHasFlagRun(flag) then
        GameAddFlagRun(flag)
        GamePrintImportant("$text_blankstone_honey_secret_title","$text_blankstone_honey_secret_desc")
        EntityLoad(honey_book,x,y)
    else
        GamePrintImportant("$text_blankstone_honey_nosecret_title","$text_blankstone_honey_nosecret_desc")
    end

    U.changeDescription(entity_id, "$stone_blankstone_honeyStone_desc2")
end

function kick( entity_who_kicked )
    drop_bee_message()
end