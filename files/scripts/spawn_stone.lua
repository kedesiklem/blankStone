local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local P = dofile_once("mods/blankStone/files/entities/progress/progress_utils.lua")

local STONE_POOL = {
    { stonekey = "blankStone",   weight = 30 },
    { stonekey = "mimicStone",   weight = 5 },
    { stonekey = "toxicStone",    weight = 5  },
    { stonekey = "acceleratiumStone",    weight = 4  },
    { stonekey = "levitatiumStone",    weight = 3  },
    { stonekey = "invisibilityStone",    weight = 3  },
    { stonekey = "shieldStone",   weight = 1  },
}

local function getUnlockedStone()
    local pool = {}
    for _, entry in ipairs(STONE_POOL) do
        if entry.stonekey == "blankStone" or P.isUnlock(entry.stonekey) then
            table.insert(pool, {
                stone = STONE_REGISTRY[entry.stonekey],
                weight = entry.weight,
            })
        end
    end
    return pool
end


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
    local pool = getUnlockedStone()
    local stone = pickStone(pool)
    factory.spawnStone(stone, x, y)
    EntityKill(entity_id)
end