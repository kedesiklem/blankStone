local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local log           = dofile_once("mods/blankStone/utils/logger.lua")

local SPAWN_Y_OFFSET = -5   -- décalage vertical pour l'apparition

--- Spawn une stone sans VFX. Usage interne ou pour les scripts externes
--- qui ont besoin d'un spawn brut.
--- @param stone_data table  Entrée normalisée du STONE_REGISTRY
--- @param x          number
--- @param y          number
--- @return entity_id  entity_id
local function spawnRaw(stone_data, x, y)
    log.info("spawnRaw: " .. stone_data.path .. " @ " .. x .. "," .. y)
    return EntityLoad(stone_data.path, x, y)
end

local function unlock_progress(key)
    local mod_progess_prefix = "blankstone_progress_"
    AddFlagPersistent(mod_progess_prefix .. key)
end

--- Spawn une stone avec ses VFX (explosion, glyphe...).
--- @param stone_data table
--- @param x          number
--- @param y          number
--- @return entity_id  entity_id
local function spawnWithVFX(stone_data, x, y)
    local ey = y + SPAWN_Y_OFFSET
    log.info("spawnWithVFX: " .. stone_data.path .. " @ " .. x .. "," .. ey)
    local id = EntityLoad(stone_data.path, x, ey)
    for _, vfx_path in ipairs(stone_data.vfx) do
        EntityLoad(vfx_path, x, y)
    end
    unlock_progress(stone_data.key)
    return id
end

--- Exécute le spawn de tous les résultats d'une recette de type "fusion".
--- Appelle preprocess et postprocess sur chaque stone.
--- @param recipe table  Recette Fuse avec effect.results
--- @param cx     number
--- @param cy     number
--- @return table  Liste des entity_ids spawnés
local function executeFusion(recipe, cx, cy)
    local spawned = {}
    for _, result in ipairs(recipe.effect.results) do
        local stone_data = STONE_REGISTRY[result.key]
        stone_data = stone_data.preprocess(stone_data)
        local id = spawnWithVFX(
            stone_data,
            cx + (result.offset_x or 0),
            cy + (result.offset_y or 0)
        )
        stone_data.postprocess(id)
        table.insert(spawned, id)
    end
    return spawned
end

return {
    spawnRaw      = spawnRaw,
    spawnWithVFX  = spawnWithVFX,
    executeFusion = executeFusion,
}
