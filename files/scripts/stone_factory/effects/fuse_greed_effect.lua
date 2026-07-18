local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log   = dofile_once("mods/blankStone/utils/logger.lua")

--- Callback on_success pour la fusion de shiniestOrbStone (entre elles ou avec un shiny orb vanilla).
--- @param spawned table  Liste des entités créées par l'executor
--- @param ctx    table   { ingredients = {{id, ...}, ...}, catalysts = {...} }
return function(spawned, ctx)
    local total = 0

    for _, slot in ipairs(ctx.ingredients) do
        for _, source_id in ipairs(slot) do
            local greed_info = utils.getVariable(source_id, "greed_count")
            -- une source sans greed_count (orb vanilla, ou toute autre pierre) compte pour 1
            local greed = greed_info and tonumber(utils.getValue(greed_info, "value_int")) or 1
            total = total + greed
        end
    end

    if total <= 0 then total = 1 end

    local out = spawned[1]

    local existing = utils.getVariable(out, "greed_count")
    if existing then
        utils.setValue(existing, "value_int", total)
    else
        EntityAddComponent2(out, "VariableStorageComponent", {
            name = "greed_count",
            value_int = total,
        })
    end

    local name = utils.getName(out)
    utils.changeName(out, name .. " [" .. total .. "]")

    log.info("fuse_greed_effect: fusion complète — avidité totale = " .. total)
end