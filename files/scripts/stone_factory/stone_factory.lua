local condition = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_requirements.lua")
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local HINT_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/hint_registry.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua")
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

-- Just spawn the stone, use createStone instead to add VFX
local function spawnStone(stone_data, pos_x, pos_y)
    log.info("Stone created: " .. stone_data.path)
    return EntityLoad(stone_data.path, pos_x, pos_y - 5)
end

-- Create stone with VFX
local function createStone(stone_data, pos_x, pos_y)
    -- Charger l'entité de la pierre
    local stone_id = spawnStone(stone_data, pos_x, pos_y)
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

local function tryInfuseStone(stone_recipie, hintCount, pos_x, pos_y)

    local stone_hint = stone_recipie.hint_key
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
    
    local stone_key = stone_recipie.stone_key
    local stone_data = STONE_REGISTRY[stone_key]


    -- Useless if the lookup table is done correctly
    if not stone_data then
        log.warn("Stone key not found in registry: " .. tostring(stone_key))
        return false
    end

    stone_data = stone_data.preprocess(stone_data)

    log.debug("Found stone data for key: " .. tostring(stone_key))



    local is_success, message, pure = condition.checkRequirements(stone_data)

    if (not is_success) then
        log.debug("Fail stone requirement")
        if (hintCount == 0) then
            if not pure then GamePrintImportant("$text_blankstone_corrupt","$text_blankstone_lies_desc") else GamePrint(message) end
        end
        return false
    end

    local stone_id = createStone(stone_data, pos_x, pos_y)
    stone_data.postprocess(stone_id)
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

local UPGRADE_COMP = "blankStoneUpgraded"

local function isUpgraded(item)
    local c = utils.getVariable(item, UPGRADE_COMP)
    if c then
        return ComponentGetValue2(c, "value_bool")
    end
    return nil
end

local function setUpgraded(item, value)
    EntityAddComponent2(item, "VariableStorageComponent", {
        name      = UPGRADE_COMP,
        value_bool = value,
    })
end

local function tryFuse(cx, cy, recipe, cached_entities)

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


    local function_upgrade = recipe.upgrade
    
    if(function_upgrade ~= nil) then
    --- MODE UPGRADE

        log.debug("Mode UPGRADE")
        
        local is_upgrading = false
        for _, value in ipairs(selected_ingredients[1]) do
            if(not isUpgraded(value)) then
                log.debug("UPGRADE " .. value)
                function_upgrade(value)
                setUpgraded(value, true)
                is_upgrading = true
            end
        end
        
        if not is_upgrading then return false end

    else
    --- MODE FUSION
    
        log.debug("Mode FUSION")
        
        -- Vérification des requirements
        for _, result in ipairs(recipe.results) do
            local stone_data = STONE_REGISTRY[result.key]
            local can_craft, msg, pure = condition.checkRequirements(stone_data)
            if not can_craft then
                log.debug("requirements not meet : recipe skipped")
                if not pure then GamePrintImportant("$text_blankstone_corrupt","$text_blankstone_lies_desc") else GamePrint(msg) end
                return false
            end
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


    end

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
    createStone = createStone,
    tryInfuseStone = tryInfuseStone,
    tryAllFuse = tryAllFuse,
    forgeStone = forgeStone
}