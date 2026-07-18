local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
dofile_once("data/scripts/lib/utilities.lua")


local GOLDNUGGET_PATH = "data/entities/items/pickup/"
local GOLDNUGGET_PREFIX = "goldnugget_"

-- possible goldnuggets : 10 100 200 1000 10000 200000
local DROP_TABLE = {
    { min_greed = 1, weight = 11, nuggets = { "10", "10", "10" } },
    { min_greed = 1, weight = 9,  nuggets = { "100", "100" } },
    { min_greed = 1, weight = 1,  nuggets = { "200", "200" } },
    { min_greed = 1, weight = 1,  nuggets = { "100" } },

    { min_greed = 2, weight = 4,  nuggets = { "200" } },
    { min_greed = 2, weight = 2,  nuggets = { "1000" } },

    { min_greed = 4, weight = 3,  nuggets = { "1000", "1000" } },
    { min_greed = 4, weight = 1,  nuggets = { "10000" } },

    { min_greed = 7, weight = 2,  nuggets = { "10000", "10000" } },
    { min_greed = 7, weight = 1,  nuggets = { "200000" } },
}

local function pick_drop(greed)
    local eligible = {}
    local total_weight = 0

    for _, entry in ipairs(DROP_TABLE) do
        if greed >= entry.min_greed then
            total_weight = total_weight + entry.weight
            table.insert(eligible, entry)
        end
    end

    if total_weight == 0 then return nil end

    local roll = Random(1, total_weight)
    local acc = 0
    for _, entry in ipairs(eligible) do
        acc = acc + entry.weight
        if roll <= acc then
            return entry.nuggets
        end
    end
end

function drop()
    local entity_id = GetUpdatedEntityID()
    local parent     = EntityGetRootEntity(entity_id)

    if entity_id == parent then
        local x, y = EntityGetTransform(entity_id)

        SetRandomSeed(x + entity_id, y - GameGetFrameNum())

        local greed_info = U.getVariable(entity_id, "greed_count")
        local greed = greed_info and tonumber(U.getValue(greed_info, "value_int")) or 1

        local nuggets = pick_drop(greed)
        if nuggets then
            for _, nugget in ipairs(nuggets) do
                shoot_projectile(entity_id, GOLDNUGGET_PATH .. GOLDNUGGET_PREFIX .. nugget .. ".xml", x, y, Random(-40, 40), Random(-40, 40))
            end
        end
    end
end

function kick()
    drop()
end