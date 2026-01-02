local level = dofile_once("mods/blankStone/files/scripts/stone_factory/level_requirements.lua")
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")


local function createStone(stone_data, pos_x, pos_y)
    -- Charger l'entité de la pierre
    EntityLoad(stone_data.path, pos_x, pos_y - 5)
    -- Spawn VFX Entity (explosion/gliph...)
    for i=1, #stone_data.vfx do
        EntityLoad(stone_data.vfx[i], pos_x, pos_y - 5)
    end

    GamePrintImportant(stone_data.message)

    log.info("Stone created: " .. stone_data.path)
end

local function failStone(stone_data)
    GamePrint(stone_data.message_fail)
end


-- INFUSION RECIPES RELATED FUNCTION
---------------------------------------------------------------

local function tryCreateStoneFromPotion(stone_key, hintCount, pos_x, pos_y, potion_id)
    -- Gérer la structure custom_stone vs vanilla_stone
    local stone_data = STONE_REGISTRY[stone_key]
    
    -- Useless if the lookup table is done correctly
    if not stone_data then
        log.warn("Stone key not found in registry: " .. tostring(stone_key))
        return false
    end

    log.debug("Found stone data for key: " .. tostring(stone_key))
    
    -- Vérifier les conditions de level
    if stone_data.conditions.use_level_requirements then
        if not level.checkLevelRequirements(stone_data.level) then
            if(hintCount == 0) then
                failStone(stone_data)
            end
            return false
        end
    end
    
    -- Toutes les conditions remplies : créer la pierre
    createStone(stone_data, pos_x, pos_y)
    return true
end

---------------------------------------------------------------


-- FUSE RECIPES RELATED FUNCTION
---------------------------------------------------------------

-- Fonction d'aide: collecte les ingrédients
local function collectIngredients(cx, cy, recipe)
    local ingredients_entities = {}
    
    for i, ingredient in ipairs(recipe.ingredients) do
        local entities
        
        if ingredient.tag then
            entities = utils.getEntitiesMatchingExpressionInRadius(cx, cy, recipe.radius, ingredient.tag)
            log.debug("Ingrédient trouvé par expression '" .. ingredient.tag .. "': " .. #entities)
        elseif ingredient.name then
            entities = utils.EntityGetInRadiusWithName(cx, cy, recipe.radius, ingredient.name) or {}
            log.debug("Ingrédient trouvé par nom '" .. ingredient.name .. "': " .. #entities)
        end
        
        if #entities < ingredient.count then 
            return nil 
        end
        
        ingredients_entities[i] = entities
    end
    
    return ingredients_entities
end

-- Fonction d'aide: sélectionne les entités hors inventaire
local function selectOutOfInventory(ingredients_entities, recipe)
    local selected_ingredients = {}
    
    for i, ingredient in ipairs(recipe.ingredients) do
        local entities = {}
        
        for _ = 1, ingredient.count do
            local entity = utils.getFirstOutofInventory(ingredients_entities[i])
            if not entity then return nil end
            
            table.insert(entities, entity)
            
            for k, v in ipairs(ingredients_entities[i]) do
                if v == entity then
                    table.remove(ingredients_entities[i], k)
                    break
                end
            end
        end
        
        selected_ingredients[i] = entities
    end
    
    return selected_ingredients
end

-- Fonction d'aide: traite une recette unique
local function tryRecipes(cx, cy, recipe)

    local ingredients_entities = collectIngredients(cx, cy, recipe)
    if not ingredients_entities then return false end
    
    log.debug("All ingredients present!")
    
    local selected_ingredients = selectOutOfInventory(ingredients_entities, recipe)
    if not selected_ingredients then return false end
    
    log.debug("All ingredients out of inventory!")
    
    for _, result in ipairs(recipe.results) do
        local stone_data = STONE_REGISTRY[result.key]
        local spawn_x = cx + (result.offset_x or 0)
        local spawn_y = cy + (result.offset_y or 0)
        createStone(stone_data, spawn_x, spawn_y)
    end
    
    -- Détruit tous les ingrédients utilisés
    for i, entities in ipairs(selected_ingredients) do
        for _, entity in ipairs(entities) do
            EntityKill(entity)
        end
    end
    
    -- Callback de succès
    if recipe.on_success then recipe.on_success() end
    
    return true
end

-- Fonction générique de crafting
local function genericCraft(cx, cy, recipes)
    if(not recipes) then
        log.error("No recipes loaded")
        return false
    end
    for k = 1, #recipes do
        if tryRecipes(cx, cy, recipes[k]) then
            return true
        end
    end
    
    return false
end
---------------------------------------------------------------


-- FORGE RECIPES RELATED FUNCTION
---------------------------------------------------------------

local function forgeStone(id,x,y)
    local result = craft.FORGE_RECIPIES[EntityGetName(id)]

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
    tryCreateStoneFromPotion = tryCreateStoneFromPotion,
    genericCraft = genericCraft,
    forgeStone = forgeStone
}