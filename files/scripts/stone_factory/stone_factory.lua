local pipeline      = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_pipeline.lua")
local infuseAct     = dofile_once("mods/blankStone/files/scripts/stone_factory/activation/infuse_activation.lua")
local forgeAct      = dofile_once("mods/blankStone/files/scripts/stone_factory/activation/forge_activation.lua")
local forgeExec     = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/forge_executor.lua")
local spawnExec     = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/spawn_executor.lua")
local feedback      = dofile_once("mods/blankStone/files/scripts/stone_factory/feedback/game_feedback.lua")
local craft         = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local log           = dofile_once("mods/blankStone/utils/logger.lua")

-- =============================================================================
-- API publique
-- =============================================================================

--- Spawn brut d'une stone (sans VFX). Conservé pour les scripts externes.
--- Pour un spawn avec VFX, utiliser createStone.
--- @param stone_data table  Entrée du STONE_REGISTRY (déjà normalisée)
--- @param pos_x      number
--- @param pos_y      number
--- @return number  entity_id
local function spawnStone(stone_data, pos_x, pos_y)
    log.info("spawnStone: " .. stone_data.path)
    return spawnExec.spawnRaw(stone_data, pos_x, pos_y)
end

--- Spawn d'une stone avec ses VFX.
--- @param stone_data table
--- @param pos_x      number
--- @param pos_y      number
--- @return number  entity_id
local function createStone(stone_data, pos_x, pos_y)
    return spawnExec.spawnWithVFX(stone_data, pos_x, pos_y)
end

--- Tente une infusion.
---
--- MIGRATION : l'ancienne signature passait une stone_recipe pré-résolue.
--- La nouvelle signature passe stone_id + material directement.
--- La résolution registre => recette|hint est maintenant internalisée.
---
--- Le rate-limiting du hint (hintCount) reste géré par l'appelant :
--- passer hintCount = 0 pour afficher le hint, > 0 pour le supprimer.
---
--- @param stone_id   string   Identifiant de la pierre portée (blankStoneID)
--- @param material_key   string   Nom du matériau Noita
--- @param hintCount  number   Compteur de frames depuis le dernier hint affiché
--- @param pos_x      number
--- @param pos_y      number
--- @return boolean
local function tryInfuseStone(stone_id, material_key, hintCount, pos_x, pos_y)
    local resolved = infuseAct.resolve(stone_id, material_key)
    if not resolved then return false end

    if resolved.type == "hint" then
        if hintCount == 0 then
            if resolved.data then feedback.onHint(resolved.data, pos_x, pos_y) end
        end
        return false
    end

    local result = pipeline.runInfuse(resolved.stone_keys, hintCount, pos_x, pos_y)

    return result
end

--- Tente toutes les recettes Fuse dans l'ordre de déclaration.
--- @param cx number
--- @param cy number
--- @return boolean
local function tryAllFuse(cx, cy)
    return pipeline.tryAllFuse(craft.FUSE_RECIPES, cx, cy)
end

--- Tente une recette Forge sur une entité spécifique.
--- @param entity_id number  Entité posée sur la forge
--- @param x         number
--- @param y         number
--- @return boolean
local function forgeStone(entity_id, x, y)
    local recipe = forgeAct.resolve(entity_id)
    if not recipe then return false end

    local ok = forgeExec.execute(recipe, x, y)
    if ok then
        feedback.onRecipeSuccess(recipe)
    end
    return ok
end

return {
    spawnStone     = spawnStone,
    createStone    = createStone,
    tryInfuseStone = tryInfuseStone,
    tryAllFuse     = tryAllFuse,
    forgeStone     = forgeStone,
}
