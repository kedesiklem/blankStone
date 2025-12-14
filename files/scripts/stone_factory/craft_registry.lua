-- Mapping material to keys in STONE_REGISTRY
local STONE_TO_MATERIAL_TO_STONE = {
    ["blankStone"] = {
        -- Vanilla Stones --
        -------------------------
        ["blood_worm"] = "sunseed",
        ["magic_liquid_mana_regeneration"] = "wandstone",
        ["spark_electric"] = "thunderstone",
        ["[hot]"] = "brimstone",
        ["rock_static"] = "stonestone",
        ["water"] = "waterstone",
        ["poo"] = "poopstone",
        -------------------------
        ["[radioactive]"] = "toxicStone",
        ["magic_liquid_berserk"] = "bigStone",
        ["magic_liquid_faster_levitation"] = "levitatiumStone",
        ["magic_liquid_movement_faster"] = "acceleratiumStone",
        ["magic_liquid_faster_levitation_and_movement"] = "hasteStone",

        ["[regenerative]"] = "healthStone",
        ["magic_liquid_protection_all"] = "ambrosiaStone",
        ["[magic_polymorph]"] = "polyStone",

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
}

return STONE_TO_MATERIAL_TO_STONE