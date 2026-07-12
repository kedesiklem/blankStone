local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local log     = dofile_once("mods/blankStone/utils/logger.lua")
local spawnExec = dofile_once("mods/blankStone/files/scripts/stone_factory/executors/spawn_executor.lua")

--- Exécute une recette Forge.
--- @param recipe table  { spells=?, items=?, message=? }
--- @param x      number
--- @param y      number
--- @return boolean
local function execute(recipe, x, y)
    if recipe.spells then
        for _, spell_id in ipairs(recipe.spells) do
            log.debug("forge_executor: sort -> " .. spell_id)
            CreateItemActionEntity(spell_id, x, y)
        end
    end

    if recipe.items then
        for _, item_path in ipairs(recipe.items) do
            log.debug("forge_executor: item -> " .. item_path)
            EntityLoad(item_path, x, y)
        end
    end

    if recipe.stone then
        for _, stone_path in ipairs(recipe.stone) do
            log.debug("forge_executor: stone -> " .. stone_path)
            local stone_data = STONE_REGISTRY[recipe.key]
            spawnExec.spawnWithVFX(stone_data, x, y)
        end
    end

    return true
end

return { execute = execute }
