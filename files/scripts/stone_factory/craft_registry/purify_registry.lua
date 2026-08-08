local PURIFY_RECIPES = {

    ["nigredo" ]= {stone = {"albedo"}      },

    ["whiskeyStone" ]= {stone = {"honeyStone"}      },
    ["voidStone"    ]= {stone = {"urineStone"}      },
    ["polyStone"    ]= {stone = {"quintessence"}    },
    ["poisonStone"  ]= {stone = {"toxicStone"}      },
    ["manaStone"    ]= {stone = {"wandstone"}       },
    ["lavaStone"    ]= {stone = {"brimstone"}       },
    ["healthStone"  ]= {stone = {"quintessence"}    },
    ["forgeStone"   ]= {stone = {"quintessence"}    },
    ["brassStone"   ]= {stone = {"copperStone"}     },

    ["magicLiquidStone"] = {
        spells  = {"BLANKSTONE_STONE_FUSER"},
        message = {
            title = "$text_blankstone_repair_broken_stone_title",
            desc  = "$text_blankstone_repair_broken_stone_desc",
        }
    },

    -- ##ANCHOR_PURIFY_END##
}

return PURIFY_RECIPES
