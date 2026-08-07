local MOD_PATH = "mods/blankStone/"

local log             = dofile_once(MOD_PATH .. "utils/logger.lua") ---@type logger
local craft            = dofile_once(MOD_PATH .. "files/scripts/stone_factory/craft_registry.lua")
local U                = dofile_once(MOD_PATH .. "files/scripts/utils.lua")
local P                = dofile_once(MOD_PATH .. "files/entities/progress/progress_utils.lua")

local INFUSE_RECIPES = craft.INFUSION_RECIPES
local FORGE_RECIPES  = craft.FORGE_RECIPES
local FUSE_RECIPES   = craft.FUSE_RECIPES
local PURIFY_RECIPES = craft.PURIFY_RECIPES

local active = {}
for role, _ in pairs(P.HINT_ROLES) do
    active[role] = {}
end

-- Defensive: if 'role' doesn't match a key initialized above (typo, or a
-- role removed/renamed in progress_utils.lua but not here), log an error
-- instead of crashing on table.insert(nil, ...). A crash here would abort
-- the whole script before P.setActiveHints(active) runs, silently breaking
-- every other hint computed earlier in the same pass.
local function addHint(role, stoneKey)
    if not stoneKey then return end
    if not active[role] then
        log.error("addHint: unknown hint role '" .. tostring(role) .. "' (check HINT_ROLES in progress_utils.lua)")
        return
    end
    table.insert(active[role], stoneKey)
end

-- === Infuse: active item read as a potion/material ==========================
-- stoneKey here is the vessel stone identity (never the held item itself),
-- so no need to exclude anything: the held item is a potion, the hinted
-- stone is a different entity entirely.

local function findInfuseOutput(potion_id, stoneKey)
    local material, material_tags = U.getPotionMaterial(potion_id)
    if not material then return nil end

    local stone_map = INFUSE_RECIPES[stoneKey]
    if not stone_map then return nil end

    if stone_map[material] then return stone_map[material] end

    for _, tag in ipairs(material_tags) do
        if stone_map[tag] then return stone_map[tag] end
    end
    return nil
end

local function scanInfuse(item_id)
    for stoneKey, _ in pairs(INFUSE_RECIPES) do
        local out = findInfuseOutput(item_id, stoneKey)
        if out and out.stone_keys then
            addHint("infuse_input", stoneKey)
            for _, key in ipairs(out.stone_keys) do
                addHint("infuse_output", key)
            end
        end
    end
end

-- === Infuse === 
local function scanInfuseStone(identifier)
    local stone_map = INFUSE_RECIPES[identifier]
    if not stone_map then return end

    for _, recipe in pairs(stone_map) do
        for _, key in ipairs(recipe.stone_keys or {}) do
            addHint("infuse_output", key)
        end
    end
end

-- === Forge ===
local function scanForgeInput(identifier)
    local recipe = FORGE_RECIPES[identifier]
    log.debug("scanForge: identifier=" .. tostring(identifier) .. " recipe_found=" .. tostring(recipe ~= nil))
    if not recipe then return end

    for _, key in ipairs(recipe.stone or {}) do
        addHint("forge_output", key)
    end
end
local function scanForgeOutput(identifier)
    for inputKey, recipe in pairs(FORGE_RECIPES) do
        for _, outputKey in ipairs(recipe.stone or {}) do
            if outputKey == identifier then
                addHint("forge_input", inputKey)
            end
        end
    end
end


-- === Purify ===
local function scanPurify(identifier)
    local recipe = PURIFY_RECIPES[identifier]
    log.debug("scanPurify: identifier=" .. tostring(identifier) .. " recipe_found=" .. tostring(recipe ~= nil))
    if not recipe then return end

    for _, key in ipairs(recipe.stone or {}) do
        addHint("purify_output", key)
    end
end

-- === Fuse ===
local function expressionToStoneKeys(expr)
    local keys = {}
    for key in expr:gmatch("[^|,()]+") do
        table.insert(keys, key)
    end
    return keys
end

local function matchesFuseEntry(item_id, entry)
    if entry.tag then
        return #U.filterEntitiesByTagExpression({ item_id }, entry.tag) > 0
    end
    if entry.name then
        return #U.filterEntitiesByNameExpression({ item_id }, entry.name) > 0
    end
    return false
end

local function scanFuseInput(item_id)
    for _, recipe in ipairs(FUSE_RECIPES) do
        local collect     = recipe.collect or {}
        local ingredients = collect.ingredients or {}
        local catalysts   = collect.catalysts or {}
 
        local heldMatches = false
        for _, entry in ipairs(ingredients) do
            if matchesFuseEntry(item_id, entry) then heldMatches = true break end
        end
        if not heldMatches then
            for _, entry in ipairs(catalysts) do
                if matchesFuseEntry(item_id, entry) then heldMatches = true break end
            end
        end
 
        if heldMatches then
            for _, entry in ipairs(ingredients) do
                if not matchesFuseEntry(item_id, entry) then
                    for _, key in ipairs(expressionToStoneKeys(entry.tag or entry.name)) do
                        addHint("fuse_input", key)
                    end
                end
            end
            for _, entry in ipairs(catalysts) do
                if not matchesFuseEntry(item_id, entry) then
                    for _, key in ipairs(expressionToStoneKeys(entry.tag or entry.name)) do
                        addHint("fuse_catalyst", key)
                    end
                end
            end
            for _, result in ipairs((recipe.effect or {}).results or {}) do
                addHint("fuse_output", result.key)
            end
        end
    end
end
 
-- Reverse: held item IS one of the recipe's output(s) -> hint every
-- ingredient and catalyst of that recipe, none excluded since the held
-- item is the finished product, not a component being collected here.
 
local function scanFuseOutput(identifier)
    for _, recipe in ipairs(FUSE_RECIPES) do
        local collect     = recipe.collect or {}
        local ingredients = collect.ingredients or {}
        local catalysts   = collect.catalysts or {}
        local results      = (recipe.effect or {}).results or {}
 
        local isResult = false
        for _, result in ipairs(results) do
            if result.key == identifier then isResult = true break end
        end

                log.debug("scanFuseOutput: identifier=" .. tostring(identifier)
            .. " recipe_result=" .. tostring(results[1] and results[1].key)
            .. " isResult=" .. tostring(isResult))
 
        if isResult then
            for _, entry in ipairs(ingredients) do
                for _, key in ipairs(expressionToStoneKeys(entry.tag or entry.name)) do
                    addHint("fuse_input", key)
                end
            end
            for _, entry in ipairs(catalysts) do
                for _, key in ipairs(expressionToStoneKeys(entry.tag or entry.name)) do
                    addHint("fuse_catalyst", key)
                end
            end
        end
    end
end


-- =============================================================================
-- Run
-- =============================================================================

local player = U.getPlayer()
local item_id = player and U.getActiveItem(player)

if item_id then
    scanInfuse(item_id)

    local identifier = U.getEntityIdentifier(item_id)
    if identifier then
        scanFuseInput(item_id)
        scanFuseOutput(identifier)
        scanInfuseStone(identifier)
        scanForgeInput(identifier)
        scanForgeOutput(identifier)
        scanPurify(identifier)
    end
end

P.setActiveHints(active)