local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")

local STONE_POOL = {
    { stone = STONE_REGISTRY["blankStone"],   weight = 30 },
    { stone = STONE_REGISTRY["toxicStone"],    weight = 5  },
    { stone = STONE_REGISTRY["acceleratiumStone"],    weight = 4  },
    { stone = STONE_REGISTRY["levitatiumStone"],    weight = 3  },
    { stone = STONE_REGISTRY["invisibilityStone"],    weight = 3  },
    { stone = STONE_REGISTRY["shieldStone"],   weight = 1  },
}

local function pickStone(pool)
    local total = 0
    for _, entry in ipairs(pool) do
        total = total + entry.weight
    end

    local roll = Random(1, total)
    local cumulative = 0
    for _, entry in ipairs(pool) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.stone
        end
    end
end

function init(entity_id)
    local x, y = EntityGetTransform(entity_id)
    SetRandomSeed(x, y)
    local stone = pickStone(STONE_POOL)
    factory.spawnStone(stone, x, y)
    EntityKill(entity_id)
end