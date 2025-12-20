local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)

-- convert items
local converted_blankStone = false

local QuintessenceRecipe = {
    -- Ingrédient central (catalyst)
    catalyst = {
        name = "blankStone",
    },
    -- Ingrédients requis autour du catalyst
    ingredients = {
        { tag = "brimstone", count = 1 },
        { tag = "thunderstone", count = 1 },
        { tag = "waterstone", count = 1 },
        { tag = "stonestone", count = 1 }
    },
    -- Rayon de détection
    radius = 70,
    -- Résultats à spawner
    results = {
        { path = "mods/blankStone/files/entities/quintessence_stone.xml", offset_y = -10 },
        { path = "data/entities/projectiles/deck/explosion_giga.xml", offset_y = -10 },
        { path = "mods/blankStone/files/image_emitters/quintessence_symbol_fast.xml", offset_y = -10},
    },
    -- Callback optionnel après craft réussi
    on_success = function()
        converted_blankStone = true
    end
}

local TestingRecipe = {
    -- Ingrédient central (catalyst)
    catalyst = {
        name = "blankStone",
    },
    -- Ingrédients requis autour du catalyst
    ingredients = {
    },
    -- Rayon de détection
    radius = 70,
    -- Résultats à spawner
    results = {
        { path = "mods/blankStone/files/entities/quintessence_stone.xml", offset_y = -10 },
        { path = "data/entities/projectiles/deck/explosion_giga.xml", offset_y = -10 },
        { path = "mods/blankStone/files/image_emitters/quintessence_symbol_fast.xml", offset_y = -10},
    },
    -- Callback optionnel après craft réussi
    on_success = function()
        converted_blankStone = true
    end
}

local function getFirstOutofInventory(item_list)
    for k=1,#item_list do
	    local item = item_list[k]
        if EntityGetRootEntity(item) == item then
            return item
        end
    end
    return nil
end

-- Fonction d'aide: valide un catalyst
local function validateCatalyst(catalyst, recipe)
    if EntityGetRootEntity(catalyst) ~= catalyst then return false end
    if EntityGetName(catalyst) ~= recipe.catalyst.name then return false end
    return true
end

-- Fonction d'aide: collecte les ingrédients
local function collectIngredients(cx, cy, recipe)
    local ingredients_entities = {}
    
    for i, ingredient in ipairs(recipe.ingredients) do
        local entities = EntityGetInRadiusWithTag(cx, cy, recipe.radius, ingredient.tag) or {}
        log.info(ingredient.tag .. ": " .. #entities)
        
        if #entities < ingredient.count then return nil end
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
            local entity = getFirstOutofInventory(ingredients_entities[i])
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

-- Fonction d'aide: traite un catalyst unique
local function processCatalyst(catalyst, anvil_pos_x, anvil_pos_y, recipe)
    if not validateCatalyst(catalyst, recipe) then return false end
    
    local cx, cy = EntityGetTransform(catalyst)
    log.info(recipe.catalyst.name .. " found!")
    
    local ingredients_entities = collectIngredients(cx, cy, recipe)
    if not ingredients_entities then return false end
    
    log.info("All ingredients present!")
    
    local selected_ingredients = selectOutOfInventory(ingredients_entities, recipe)
    if not selected_ingredients then return false end
    
    log.info("All ingredients out of inventory!")
    
    -- Spawn les résultats
    for _, result in ipairs(recipe.results) do
        local spawn_x = anvil_pos_x + (result.offset_x or 0)
        local spawn_y = anvil_pos_y + (result.offset_y or 0)
        EntityLoad(result.path, spawn_x, spawn_y)
    end
    
    -- Détruit le catalyst
    EntityKill(catalyst)
    
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
local function genericCraft(anvil_pos_x, anvil_pos_y, recipe)
    local catalysts = EntityGetInRadiusWithTag(anvil_pos_x, anvil_pos_y, recipe.radius, "forgeable") or {}
    
    for k = 1, #catalysts do
        if processCatalyst(catalysts[k], anvil_pos_x, anvil_pos_y, recipe) then
            return true
        end
    end
    
    return false
end

-- Fonction principale à appeler
local function forgeQuintessence()
    genericCraft(pos_x, pos_y, QuintessenceRecipe)
end

forgeQuintessence()
genericCraft(pos_x, pos_y, TestingRecipe)

if converted_blankStone then
	GameTriggerMusicFadeOutAndDequeueAll( 3.0 )
	GameTriggerMusicEvent( "music/oneshot/dark_01", true, pos_x, pos_y )
end