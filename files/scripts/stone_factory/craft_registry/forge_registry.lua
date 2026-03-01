BOOK_PATH = "mods/blankStone/files/entities/items/books/"

local LIES_MESSAGE = {
    title = "$text_blankstone_unmask_book_title",
    desc  = "$text_blankstone_unmask_book_desc",
}

local REPAIR_MESSAGE = {
    title = "$text_blankstone_repair_book_title",
    desc  = "$text_blankstone_repair_book_desc",
}

local FORGE_RECIPES = {
    ["magicLiquidStone"] = {
        spells  = {"BLANKSTONE_STONE_FUSER"},
        message = {
            title = "$text_blankstone_repair_broken_stone_title",
            desc  = "$text_blankstone_repair_broken_stone_desc",
        }
    },
    ["voidStone"] = {items = {"mods/blankStone/files/entities/stone_storage.xml"}},
    ["book_infuse"]      = { items = {BOOK_PATH .. "reforged_book_infuse.xml"},      message = REPAIR_MESSAGE },
    ["book_purity"]      = { items = {BOOK_PATH .. "reforged_book_purity.xml"},      message = REPAIR_MESSAGE },
    ["book_magnum_opus"] = { items = {BOOK_PATH .. "reforged_book_magnum_opus.xml"}, message = REPAIR_MESSAGE },
    ["book_gods_secrets"]= { items = {BOOK_PATH .. "reforged_book_gods_secrets.xml"},message = REPAIR_MESSAGE },
    ["book_honey"]       = { items = {BOOK_PATH .. "reforged_book_honey.xml"},       message = REPAIR_MESSAGE },

    ["book_infuse_lies"]      = { items = {BOOK_PATH .. "tome_of_lies.xml"}, message = LIES_MESSAGE },
    ["book_purity_lies"]      = { items = {BOOK_PATH .. "tome_of_lies.xml"}, message = LIES_MESSAGE },
    ["book_magnum_opus_lies"] = { items = {BOOK_PATH .. "tome_of_lies.xml"}, message = LIES_MESSAGE },
}

return FORGE_RECIPES