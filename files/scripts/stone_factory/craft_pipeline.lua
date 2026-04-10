-- =============================================================================
-- craft_pipeline.lua
-- Pipeline interne partagé par Infuse et Fuse.
-- Séquence : collect => validate => execute => feedback.
-- Ne pas appeler directement depuis l'extérieur : passer par stone_factory.lua.
-- =============================================================================

local STONE_REGISTRY  = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local HINT_REGISTRY   = dofile_once("mods/blankStone/files/scripts/stone_factory/hint_registry.lua")
local validator       = dofile_once("mods/blankStone/files/scripts/stone_factory/validators/condition_validator.lua")
local spawnExec       = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/spawn_executor.lua")
local upgradeExec     = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/upgrade_executor.lua")
local feedback        = dofile_once("mods/blankStone/files/scripts/stone_factory/feedback/game_feedback.lua")
local utils           = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log             = dofile_once("mods/blankStone/utils/logger.lua")

-- =============================================================================
-- PIPELINE INFUSE
-- Double passe : valider tout AVANT de spawner pour éviter les états partiels.
-- =============================================================================

local function runInfuse(stone_keys, hintCount, cx, cy)
    local resolved = {}
    for _, stone_key in ipairs(stone_keys) do
        local stone_data = STONE_REGISTRY[stone_key]
        if not stone_data then
            log.warn("runInfuse: stone_key introuvable -> " .. tostring(stone_key))
            return false
        end

        stone_data = stone_data.preprocess(stone_data)
        local result = validator.validate(stone_data)

        if not result.ok then
            if hintCount == 0 then
                feedback.onValidationFail(result)
            end
            return false
        end

        table.insert(resolved, { stone_data = stone_data, message = result.message })
    end

    for _, entry in ipairs(resolved) do
        local stone_id = spawnExec.spawnWithVFX(entry.stone_data, cx, cy)
        entry.stone_data.postprocess(stone_id)
        feedback.onStoneSuccess(entry.message)
    end

    return true
end

-- =============================================================================
-- PIPELINE FUSE
-- =============================================================================

local function getAllOutOfInventory(entities)
    local out = {}
    for _, e in ipairs(entities) do
        if e == EntityGetRootEntity(e) then
            table.insert(out, e)
        end
    end
    return out
end

local function collectList(list, cached_entities)
    local found = {}
    for i, ingredient in ipairs(list) do
        local entities
        if ingredient.tag then
            entities = utils.filterEntitiesByTagExpression(cached_entities, ingredient.tag)
        elseif ingredient.name then
            entities = utils.filterEntitiesByNameExpression(cached_entities, ingredient.name)
        end

        if not entities or #entities < ingredient.count then return nil end

        local sliced = {}
        for j = 1, ingredient.count do sliced[j] = entities[j] end
        found[i] = sliced
    end
    return found
end

local function destroyIngredients(ingredient_groups)
    for _, group in ipairs(ingredient_groups) do
        for _, entity_id in ipairs(group) do
            EntityKill(entity_id)
        end
    end
end

-- =============================================================================
-- CONDITIONS DE RECETTE
-- Distinctes des conditions sur les pierres (condition_validator) :
-- celles-ci bloquent la recette entière, pas le spawn d'une pierre spécifique.
--
-- Format dans fuse_registry :
--   conditions = {
--       orbs     = 11,        -- nombre d'orbes minimum requis
--       purity   = true,      -- run non corrompu
--       flags    = {{ run = "...", persistent = "..." }},
--       hint_key = "hint_xxx" -- affiché si ingrédients présents mais condition non remplie
--   }
-- =============================================================================

local function isPure()
    for i = 0, 11 do
        for _, offset in ipairs({128, 256}) do
            if GameGetOrbCollectedThisRun(i + offset) then return false end
        end
    end
    return true
end

local function checkRecipeConditions(recipe)
    local conds = recipe.conditions
    if not conds then return true end

    if conds.orbs and GameGetOrbCountThisRun() < conds.orbs then
        return false
    end
    if conds.purity and not isPure() then
        return false
    end
    if conds.flags then
        for _, flag in pairs(conds.flags) do
            if not GameHasFlagRun(flag.run) then
                if not HasFlagPersistent(flag.persistent) then
                    return false
                end
            end
        end
    end

    return true
end

local function runFuse(recipe, cached_entities, cx, cy)
    local ingredients = collectList(recipe.collect.ingredients, cached_entities)
    if not ingredients then return false end

    -- Les ingrédients sont là mais la condition de recette bloque :
    -- afficher l'indice associé si défini.
    if not checkRecipeConditions(recipe) then
        local hint_key = recipe.conditions and recipe.conditions.hint_key
        if hint_key then
            local hint_data = HINT_REGISTRY[hint_key]
            if hint_data then
                feedback.onHint(hint_data, cx, cy)
            else
                log.warn("runFuse: hint_key introuvable -> " .. tostring(hint_key))
            end
        end
        return false
    end

    local catalysts = nil
    if recipe.collect.catalysts then
        catalysts = collectList(recipe.collect.catalysts, cached_entities)
        if not catalysts then return false end
    end

    local ctx = { ingredients = ingredients, catalysts = catalysts or {} }

    local effect_type = recipe.effect.type

    if effect_type == "fusion" then
        for _, result in ipairs(recipe.effect.results) do
            local stone_data = STONE_REGISTRY[result.key]
            if not stone_data then
                log.warn("runFuse: stone_key résultat introuvable -> " .. tostring(result.key))
                return false
            end
            stone_data = stone_data.preprocess(stone_data)
            local vresult = validator.validate(stone_data)
            if not vresult.ok then
                feedback.onValidationFail(vresult)
                return false
            end
        end

        local spawned = spawnExec.executeFusion(recipe, cx, cy)
        feedback.onRecipeSuccess(recipe)
        if recipe.on_success then recipe.on_success(spawned, ctx) end
        destroyIngredients(ctx.ingredients)
        return true

    elseif effect_type == "upgrade" then
        local result = upgradeExec.execute(recipe, ctx)
        if not result then return false end
        feedback.onRecipeSuccess(recipe)
        if recipe.on_success then recipe.on_success(result, ctx) end
        return true

    else
        log.error("runFuse: type d'effet inconnu -> " .. tostring(effect_type))
        return false
    end
end

local function tryAllFuse(recipes, cx, cy)
    if not recipes then
        log.error("tryAllFuse: aucune recette chargée")
        return false
    end

    local max_radius = 0
    for _, recipe in ipairs(recipes) do
        if recipe.radius > max_radius then max_radius = recipe.radius end
    end

    local cached = getAllOutOfInventory(EntityGetInRadius(cx, cy, max_radius) or {})
    log.debug("tryAllFuse: " .. #cached .. " entités (rayon " .. max_radius .. ")")

    for k, recipe in ipairs(recipes) do
        if runFuse(recipe, cached, cx, cy) then return true end
        log.debug("tryAllFuse: recette " .. k .. " échouée")
    end

    return false
end

return {
    runInfuse  = runInfuse,
    tryAllFuse = tryAllFuse,
}