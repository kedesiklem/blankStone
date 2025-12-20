-- Mapping material to keys in STONE_REGISTRY
local STONE_TO_MATERIAL_TO_STONE = {
    ["blankStone"] = {
        -- Vanilla Stones --
        -------------------------
        ["[hot]"] = "brimstone",
        ["diamond"] =           "thunderstone",
        ["spark_electric"] =    "thunderstone",
        ["rock_static"] = "stonestone",
        ["water"] = "waterstone",
        ["poo"] = "poopstone",
        ["blood_worm"] = "sunseed",
        ["magic_liquid_mana_regeneration"] = "wandstone",
        -------------------------
        ["[radioactive]"] = "toxicStone",
        ["magic_liquid_berserk"] = "bigStone",
        ["magic_liquid_faster_levitation"] = "levitatiumStone",
        ["magic_liquid_movement_faster"] = "acceleratiumStone",
        ["magic_liquid_faster_levitation_and_movement"] = "hasteStone",
    },
    ["hasteStone"] = {
        ["[slime]"] = "explosionStone",
    },
    ["levitatiumStone"] = {
        ["magic_liquid_movement_faster"] = "hasteStone",
        ["[slime]"] = "explosionStone",
    },
    ["acceleratiumStone"] = {
        ["magic_liquid_faster_levitation"] = "hasteStone",
        ["[slime]"] = "explosionStone",
    },
    ["bigStone"] = {
        ["material_confusion"] = "loveStone",
    },

    ["quintessence"] = {
        ["[regenerative]"] = "healthStone",
        ["magic_liquid_protection_all"] = "ambrosiaStone",
        ["[magic_polymorph]"] = "polyStone",
    }
}

return STONE_TO_MATERIAL_TO_STONE