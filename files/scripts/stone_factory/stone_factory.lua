local condition = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_requirements.lua")
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local HINT_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/hint_registry.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

-- Just spawn the stone, use createStone instead to add VFX
local function spawnStone(stone_data, pos_x, pos_y)
    log.info("Stone created: " .. stone_data.path .. " " .. pos_x .. " " .. pos_y)
    return EntityLoad(stone_data.path, pos_x, pos_y)
end

-- Create stone with VFX
local function createStone(stone_data, pos_x, pos_y)
    -- Charger l'entité de la pierre
    local stone_id = spawnStone(stone_data, pos_x, pos_y - 5)
    -- Spawn VFX Entity (explosion/gliph...)
    for i=1, #stone_data.vfx do
        EntityLoad(stone_data.vfx[i], pos_x, pos_y - 5)
    end

    return stone_id
end

-- INFUSION RECIPES RELATED FUNCTION
---------------------------------------------------------------

local function handleHint(hint_data, pos_x, pos_y)
    if not hint_data then
        log.warn("Hint data is nil")
        return
    end
    
    GamePrint(hint_data.message)
    
    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", pos_x, pos_y)
end

local function tryInfuseStone(stone_recipe, hintCount, pos_x, pos_y)

    local stone_hint = stone_recipe.hint_key
    if stone_hint then
        if hintCount == 0 then
            local hint_data = HINT_REGISTRY[stone_hint]
            if hint_data then
                handleHint(hint_data, pos_x, pos_y)
            else
                log.warn("Hint key not found in registry: " .. tostring(stone_hint))
            end
        end
        return false
    end

    local stone_keys = stone_recipe.stone_keys

    -- First pass: validate all keys
    local resolved = {}
    for _, stone_key in ipairs(stone_keys) do
        local stone_data = STONE_REGISTRY[stone_key]

        if not stone_data then
            log.warn("Stone key not found in registry: " .. tostring(stone_key))
            return false
        end

        stone_data = stone_data.preprocess(stone_data)
        log.debug("Found stone data for key: " .. tostring(stone_key))

        local is_success, message, pure = condition.checkRequirements(stone_data)

        if not is_success then
            log.debug("Fail stone requirement")
            if hintCount == 0 then
                if not pure then GamePrintImportant("$text_blankstone_corrupt","$text_blankstone_lies_desc") else GamePrint(message) end
            end
            return false
        end

        resolved[#resolved + 1] = { stone_data = stone_data, message = message }
    end

    -- Second pass: all checks passed, create all stones
    for _, entry in ipairs(resolved) do
        local stone_id = createStone(entry.stone_data, pos_x, pos_y)
        entry.stone_data.postprocess(stone_id)
        GamePrintImportant(entry.message)
    end

    return true
end

---------------------------------------------------------------


-- FUSE RECIPES RELATED FUNCTION
---------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- Collecte
-- ---------------------------------------------------------------------------

local function getAllOutOfInventory(entities)
    local out = {}
    for _, e in ipairs(entities) do
        if e == EntityGetRootEntity(e) then
            table.insert(out, e)
        end
    end
    return out
end

local function getAllEntitiesInRadius(cx, cy, radius)
    return EntityGetInRadius(cx, cy, radius) or {}
end

local function collectShoppingList(cx, cy, radius, list, cached_entities)
    local found = {}
    for i, ingredient in ipairs(list) do
        local entities
        if ingredient.tag then
            entities = utils.filterEntitiesByTagExpression(cached_entities, ingredient.tag)
        elseif ingredient.name then
            entities = utils.filterEntitiesByNameExpression(cached_entities, ingredient.name)
        end
        if #entities < ingredient.count then return nil end
        local sliced = {}
        for j = 1, ingredient.count do sliced[j] = entities[j] end
        found[i] = sliced
    end
    return found
end

local function collectAndSelect(cx, cy, radius, list, label, cached_entities)
    local found = collectShoppingList(cx, cy, radius, list, cached_entities)
    if not found then return nil end
    log.debug("All " .. label .. " present!")
    return found
end

local function destroyEntities(entity_groups)
    for _, group in ipairs(entity_groups) do
        for _, entity in ipairs(group) do
            EntityKill(entity)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Upgrade helpers
-- ---------------------------------------------------------------------------

local UPGRADE_COMP = "blankStoneUpgraded"

local function isUpgraded(item)
    local c = utils.getVariable(item, UPGRADE_COMP)
    if c then return ComponentGetValue2(c, "value_bool") end
    return nil
end

local function setUpgraded(item, value)
    EntityAddComponent2(item, "VariableStorageComponent", {
        name       = UPGRADE_COMP,
        value_bool = value,
    })
end

local function buildContext(ingredients, catalysts)
    return {
        ingredients = ingredients,
        catalysts   = catalysts or {},
    }
end

-- ---------------------------------------------------------------------------
-- Effect handlers
-- ---------------------------------------------------------------------------

local EFFECT_HANDLERS = {

    -- MODE FUSION -----------------------------------------------------------
    fusion = function(cx, cy, recipe, ctx)

        -- Check requirements for every result before spawning anything
        for _, result in ipairs(recipe.effect.results) do
            local stone_data = STONE_REGISTRY[result.key]
            stone_data = stone_data.preprocess(stone_data)

            local can_craft, msg, pure = condition.checkRequirements(stone_data)
            if not can_craft then
                log.debug("requirements not met: recipe skipped")
                if not pure then
                    GamePrintImportant("$text_blankstone_corrupt", "$text_blankstone_lies_desc")
                else
                    GamePrint(msg)
                end
                return false
            end
        end

        -- Spawn results
        local spawned = {}
        for _, result in ipairs(recipe.effect.results) do
            local stone_data = STONE_REGISTRY[result.key]
            stone_data = stone_data.preprocess(stone_data)

            local entity_id = createStone(stone_data,
                cx + (result.offset_x or 0),
                cy + (result.offset_y or 0))
            table.insert(spawned, entity_id)
        end

        return true, spawned
    end,

    -- MODE UPGRADE ----------------------------------------------------------
    upgrade = function(cx, cy, recipe, ctx)
        local upgraded = {}
        for _, entity in ipairs(ctx.ingredients[1]) do
            if not isUpgraded(entity) then
                recipe.effect.apply(entity)
                setUpgraded(entity, true)
                table.insert(upgraded, entity)
            end
        end
        if #upgraded == 0 then return false end
        return true, upgraded
    end,
}

-- ---------------------------------------------------------------------------
-- Core
-- ---------------------------------------------------------------------------

local function tryFuse(cx, cy, recipe, cached_entities)

    local ingredients = collectAndSelect(
        cx, cy, recipe.radius,
        recipe.collect.ingredients, "ingredients",
        cached_entities)
    if not ingredients then return false end

    local catalysts = nil
    if recipe.collect.catalysts then
        catalysts = collectAndSelect(
            cx, cy, recipe.radius,
            recipe.collect.catalysts, "catalysts",
            cached_entities)
        if not catalysts then return false end
    end

    local handler = EFFECT_HANDLERS[recipe.effect.type]
    if not handler then
        log.error("Unknown effect type: " .. tostring(recipe.effect.type))
        return false
    end

    local ctx = buildContext(ingredients, catalysts)

    local ok, spawned = handler(cx, cy, recipe, ctx)
    if not ok then return false end

    if recipe.message then
        GamePrintImportant(recipe.message.title, recipe.message.desc)
    end
    if recipe.on_success then recipe.on_success(spawned, ctx) end
    if recipe.effect.type == "fusion" then destroyEntities(ctx.ingredients) end
    return true
end

local function tryAllFuse(cx, cy, recipes)
    if not recipes then
        log.error("No recipes loaded")
        return false
    end

    local max_radius = 0
    for _, recipe in ipairs(recipes) do
        if recipe.radius > max_radius then max_radius = recipe.radius end
    end

    local cached_entities = getAllOutOfInventory(getAllEntitiesInRadius(cx, cy, max_radius))
    log.debug("Cached " .. #cached_entities .. " entities for all recipes")

    for k = 1, #recipes do
        if tryFuse(cx, cy, recipes[k], cached_entities) then
            return true
        end
        log.debug("recipe " .. k .. " failed.")
    end

    return false
end

-- FORGE RECIPES RELATED FUNCTION
---------------------------------------------------------------

local function forgeStone(id,x,y)
    local result = craft.FORGE_RECIPES[utils.getEntityIdentifier(id)]

    if not result then return false end
    
    if result.spells then
        for _, spell in ipairs(result.spells) do
            CreateItemActionEntity(spell, x, y)
        end
    end

    if result.items then
        for _, item in ipairs(result.items) do
            log.debug("forge item : ".. item)
            EntityLoad(item, x, y)
        end
    end

    if result.message then
        GamePrintImportant(result.message.title, result.message.desc)
    end
    return true
end

---------------------------------------------------------------

return {
    spawnStone = spawnStone,
    createStone = createStone,
    tryInfuseStone = tryInfuseStone,
    tryAllFuse = tryAllFuse,
    forgeStone = forgeStone
}