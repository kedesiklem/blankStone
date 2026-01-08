local level = dofile_once("mods/blankStone/files/scripts/stone_factory/level_requirements.lua")
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")


-- Check level requirements and return a message linked to the result
local function checkRequirements(stone_data)
    -- Vérifier les conditions de level
    if stone_data.conditions.use_level_requirements then
        if not level.checkLevelRequirements(stone_data.level) then
            return false, stone_data.message_fail
        end
    end
    return true, stone_data.message
end

-- Just spawn the stone, use createStone instead to add VFX
local function spawnStone(stone_data, pos_x, pos_y)
    EntityLoad(stone_data.path, pos_x, pos_y - 5)
    log.info("Stone created: " .. stone_data.path)
end

-- Create stone with VFX
local function createStone(stone_data, pos_x, pos_y)
    -- Charger l'entité de la pierre
    spawnStone(stone_data, pos_x, pos_y)
    -- Spawn VFX Entity (explosion/gliph...)
    for i=1, #stone_data.vfx do
        EntityLoad(stone_data.vfx[i], pos_x, pos_y - 5)
    end
end

-- INFUSION RECIPES RELATED FUNCTION
---------------------------------------------------------------

local function tryInfuseStone(stone_key, hintCount, pos_x, pos_y)

    local stone_data = STONE_REGISTRY[stone_key]
    
    -- Useless if the lookup table is done correctly
    if not stone_data then
        log.warn("Stone key not found in registry: " .. tostring(stone_key))
        return false
    end

    log.debug("Found stone data for key: " .. tostring(stone_key))
    
    local is_success, message = checkRequirements(stone_data)

    if (not is_success) then 
        if (hintCount == 0) then
            GamePrint(message)
        end
        return false
    end

    createStone(stone_data, pos_x, pos_y)
    GamePrintImportant(message)
    return true
end

---------------------------------------------------------------


-- FUSE RECIPES RELATED FUNCTION
---------------------------------------------------------------

-- Filter element out of inventory from a list
local function getAllOutOfInventory(entities)
    local out_entities = {}

    for _, entitie in ipairs(entities) do
        if entitie == EntityGetRootEntity(entitie) then
            table.insert(out_entities, entitie)
        end
    end

    return out_entities
end

local function getAllEntitiesInRadius(cx, cy, radius)
    return EntityGetInRadius(cx, cy, radius) or {}
end

local function collectShoppingList(cx, cy, radius, list, cached_entities)
    local found_entities = {}
    
    for i, ingredient in ipairs(list) do
        local entities
        
        if ingredient.tag then
            -- Utilise la nouvelle fonction de filtrage depuis cache
            entities = utils.filterEntitiesByTagExpression(cached_entities, ingredient.tag)
            log.debug("Ingredient by tag '" .. ingredient.tag .. "': " .. #entities .. " (from cache)")
        elseif ingredient.name then
            -- Utilise la nouvelle fonction de filtrage depuis cache
            entities = utils.filterEntitiesByNameExpression(cached_entities, ingredient.name)
            log.debug("Ingredient by name '" .. ingredient.name .. "': " .. #entities .. " (from cache)")
        end
        
        if #entities < ingredient.count then
            return nil
        end
        
        found_entities[i] = entities
    end
    
    return found_entities
end

local function collectAndSelect(cx, cy, radius, item_list, item_type_name, cached_entities)
    local found_entities = collectShoppingList(cx, cy, radius, item_list, cached_entities)
    if not found_entities then return nil end

    log.debug("All " .. item_type_name .. " present!")
    return found_entities
end

local function destroyEntities(entity_groups)
    for _, entities in ipairs(entity_groups) do
        for _, entity in ipairs(entities) do
            EntityKill(entity)
        end
    end
end

local function tryFuse(cx, cy, recipe, cached_entities)
    -- Vérification des level requirements
    for _, result in ipairs(recipe.results) do
        local stone_data = STONE_REGISTRY[result.key]
        local can_craft, _ = checkRequirements(stone_data)
        if not can_craft then
            log.debug("level requirements not meet : recipe skipped")
            return false
        end
    end

    -- Collects ingredients (avec cache)
    local selected_ingredients = collectAndSelect(cx, cy, recipe.radius, recipe.ingredients, "ingredients", cached_entities)
    if not selected_ingredients then return false end

    -- Collecte catalistes (avec cache, optionnel)
    if recipe.catalistes then
        local selected_catalist = collectAndSelect(cx, cy, recipe.radius, recipe.catalistes, "catalist", cached_entities)
        if not selected_catalist then return false end
    else
        log.debug("no catalist required")
    end
    
    -- Create results
    for _, result in ipairs(recipe.results) do
        local stone_data = STONE_REGISTRY[result.key]
        local spawn_x = cx + (result.offset_x or 0)
        local spawn_y = cy + (result.offset_y or 0)
        createStone(stone_data, spawn_x, spawn_y)
    end

    -- Remove ingredients
    destroyEntities(selected_ingredients)

    if recipe.message then
        GamePrintImportant(recipe.message.title, recipe.message.desc)
    end

    -- Callback de succès
    if recipe.on_success then recipe.on_success() end

    return true
end

-- Version optimisée : UNE SEULE recherche d'entités pour toutes les recettes
local function tryAllFuse(cx, cy, recipes)
    if not recipes then
        log.error("No recipes loaded")
        return false
    end
    
    -- Calcul du radius maximum nécessaire
    local max_radius = 0
    for _, recipe in ipairs(recipes) do
        if recipe.radius > max_radius then
            max_radius = recipe.radius
        end
    end
    
    -- UNE SEULE recherche pour toutes les recettes
    local cached_entities = getAllOutOfInventory(getAllEntitiesInRadius(cx, cy, max_radius))
    log.debug("Cached " .. #cached_entities .. " entities for all recipes")
    
    -- Tester chaque recette avec le cache
    for k = 1, #recipes do
        if tryFuse(cx, cy, recipes[k], cached_entities) then
            return true  -- Kill le sort après la première fusion réussie
        else
            log.debug("recipie failed.")
        end
    end
    
    return false
end
---------------------------------------------------------------


-- FORGE RECIPES RELATED FUNCTION
---------------------------------------------------------------

local function forgeStone(id,x,y)
    local result = craft.FORGE_RECIPES[EntityGetName(id)]

    if not result then return false end
    
    if result.spells then
        for _, spell in ipairs(result.spells) do
            CreateItemActionEntity(spell, x, y)
        end
    end

    if result.message then
        GamePrintImportant(result.message.title, result.message.desc)
    end
    return true
end

---------------------------------------------------------------

return {
    createStone = createStone,
    tryInfuseStone = tryInfuseStone,
    tryAllFuse = tryAllFuse,
    forgeStone = forgeStone
}