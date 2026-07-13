local MOD_PATH = "mods/blankStone/"

local log = dofile_once(MOD_PATH .. "utils/logger.lua") ---@type logger
local C   = dofile_once(MOD_PATH .. "files/scripts/stone_factory/craft_registry/infuse_registry.lua")
local U   = dofile_once(MOD_PATH .. "files/scripts/utils.lua")
local P   = dofile_once(MOD_PATH .. "files/entities/progress/progress_utils.lua")

local function findOutput(potion_id, stoneKey)
    local material, material_tags = U.getPotionMaterial(potion_id)
    if not material then
        return nil
    end

    local stone_map = C[stoneKey]
    if not stone_map then return nil end

    if stone_map[material] then
        return stone_map[material]
    end

    for _, tag in ipairs(material_tags) do
        if stone_map[tag] then
            return stone_map[tag]
        end
    end
    return nil
end

local function getHoldMaterialRelatedStones(player)
    local item = U.getActiveItem(player)
    local inputKeys = {}
    local outputKeys = {}

    for key, _ in pairs(C) do
        local outKey = findOutput(item, key)
        if outKey ~= nil and outKey.stone_keys ~= nil then
            table.insert(inputKeys, key)
            for _, value in ipairs(outKey.stone_keys) do
                table.insert(outputKeys, value)
            end
        end
    end

    P.setActiveHints({ input = inputKeys, output = outputKeys })
end

getHoldMaterialRelatedStones(U.getPlayer())