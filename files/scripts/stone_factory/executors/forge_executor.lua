local log     = dofile_once("mods/blankStone/utils/logger.lua")

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

    return true
end

return { execute = execute }
