local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function getVariable(entity_id, variable_name)

    local variables = EntityGetComponentIncludingDisabled( entity_id,"VariableStorageComponent")

    if ( not variables ) then
        log.warn("No VariableStorageComponent found")
        return nil
    end

    for i,v in ipairs(variables) do
        local name = ComponentGetValue2( v, "name" )
        if ( name == variable_name ) then
            return v
        end
    end
end

local function setVariable(entity_id, variable_name, value_type, value)
    local variable = getVariable(entity_id, variable_name)
    if(not variable) then
        log.debug("No variable name " .. variable_name .. "found")
        return
    end
    ComponentSetValue2(variable, value_type, value)
end

--- Variable Manipulation function
local function setValue(component, name, value)
    if component ~= nil then
        ComponentSetValue2(component, name, value)
    end
end

local function getValue(component, name, default)
    if component ~= nil then
        return ComponentGetValue2(component, name)
    end
    return default
end

--- Potion related function
local function getPotionMaterial(potion_id)
    local material_id = GetMaterialInventoryMainMaterial(potion_id)
    if material_id == 0 then
        return nil
    end
    
    return CellFactory_GetName(material_id), CellFactory_GetTags(material_id)
end

-- Fonction auxiliaire pour diviser une chaîne de tags en table
local function splitTags(tagString, separator)
    local tags = {}
    local pattern = "([^" .. separator .. "]+)"
    for tag in string.gmatch(tagString, pattern) do
        tag = tag:match("^%s*(.-)%s*$")
        if tag ~= "" then
            table.insert(tags, tag)
        end
    end
    return tags
end

-- Fonction pour vérifier si une entité a au moins un des tags d'un groupe
local function hasAnyTagFromGroup(entity_id, tagGroup)
    local entityTagsString = EntityGetTags(entity_id)
    if not entityTagsString then
        return false
    end
    
    local entityTags = splitTags(entityTagsString, ",")
    local entityTagSet = {}
    for _, tag in ipairs(entityTags) do
        entityTagSet[tag] = true
    end
    
    -- Vérifie si l'entité a au moins un des tags du groupe
    for _, tag in ipairs(tagGroup) do
        if entityTagSet[tag] then
            return true
        end
    end
    
    return false
end

-- Fonction pour parser une expression complexe avec parenthèses
-- Format: "(ice|fire),(magic|dead)" = (ice OU fire) ET (magic OU dead)
local function parseComplexTagExpression(tagString)
    local groups = {}
    
    -- Extraire les groupes entre parenthèses
    for group in string.gmatch(tagString, "%(([^)]+)%)") do
        local tags = splitTags(group, "|")
        table.insert(groups, tags)
    end
    
    -- Si pas de parenthèses, traiter comme avant
    if #groups == 0 then
        if string.find(tagString, "|") then
            -- Mode OU simple
            return {mode = "OR", tags = splitTags(tagString, "|")}
        else
            -- Mode ET simple
            return {mode = "AND", tags = splitTags(tagString, ",")}
        end
    end
    
    -- Mode complexe avec parenthèses
    return {mode = "COMPLEX", groups = groups}
end

-- Fonction pour vérifier si une entité correspond à l'expression
local function entityMatchesExpression(entity_id, expression)
    if expression.mode == "OR" then
        -- Au moins un des tags
        return hasAnyTagFromGroup(entity_id, expression.tags)
        
    elseif expression.mode == "AND" then
        -- Tous les tags
        local entityTagsString = EntityGetTags(entity_id)
        if not entityTagsString then
            return false
        end
        
        local entityTags = splitTags(entityTagsString, ",")
        local entityTagSet = {}
        for _, tag in ipairs(entityTags) do
            entityTagSet[tag] = true
        end
        
        for _, requiredTag in ipairs(expression.tags) do
            if not entityTagSet[requiredTag] then
                return false
            end
        end
        return true
        
    elseif expression.mode == "COMPLEX" then
        -- Chaque groupe doit avoir au moins un tag présent (ET entre les groupes)
        for _, group in ipairs(expression.groups) do
            if not hasAnyTagFromGroup(entity_id, group) then
                return false
            end
        end
        return true
    end
    
    return false
end

-- Fonction pour obtenir les entités correspondant à une expression de tags
local function getEntitiesMatchingExpressionInRadius(cx, cy, radius, tagString)
    local expression = parseComplexTagExpression(tagString)
    
    -- Optimisation : récupère d'abord avec un tag de base
    local firstTag
    if expression.mode == "OR" then
        firstTag = expression.tags[1]
    elseif expression.mode == "AND" then
        firstTag = expression.tags[1]
    elseif expression.mode == "COMPLEX" then
        firstTag = expression.groups[1][1]
    end
    
    local candidateEntities = EntityGetInRadiusWithTag(cx, cy, radius, firstTag) or {}
    local matchingEntities = {}
    
    -- Filtre les entités selon l'expression complète
    for _, entity in ipairs(candidateEntities) do
        if entityMatchesExpression(entity, expression) then
            table.insert(matchingEntities, entity)
        end
    end
    
    return matchingEntities
end

-- Return the first element of a list that is not in inventory
local function getFirstOutofInventory(item_list)
    for k=1,#item_list do
	    local item = item_list[k]
        if EntityGetRootEntity(item) == item then
            return item
        end
    end
    return nil
end

-- Return a list with the element of input list satisfying the predicate
local function filter(list, predicate)
    local result = {}
    for _, element in ipairs(list) do
        log.debug("element filtered : " .. element)
        if predicate(element) then
            table.insert(result, element)
        end
    end
    return result
end

-- Start by getting all entities in a radius then filter to get the correct name (use EntityGetInRadiusWithTag if possible)
local function EntityGetInRadiusWithName(x,y,rad, name)
    return filter(
        EntityGetInRadius(x,y,rad),
        function (entitie)
            return EntityGetName(entitie) == name
        end
    )
end

return {
    getVariable = getVariable,
    setVariable = setVariable,
    setValue = setValue,
    getValue = getValue,

    getPotionMaterial = getPotionMaterial,
    entityMatchesExpression = entityMatchesExpression,
    getEntitiesMatchingExpressionInRadius = getEntitiesMatchingExpressionInRadius,
    getFirstOutofInventory = getFirstOutofInventory,

    filter = filter,
    EntityGetInRadiusWithName = EntityGetInRadiusWithName,
}