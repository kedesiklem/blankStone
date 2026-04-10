local utils   = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log     = dofile_once("mods/blankStone/utils/logger.lua")

local SHIELD_XML  = "mods/blankStone/files/entities/misc/shield.xml"
local RADIUS_STEP = 3   -- offset de rayon entre chaque anneau supplémentaire
local BASE_RADIUS = 12

--- Callback on_success pour la recette de fusion de shieldStone.
--- @param spawned table  Liste des entités créées par l'executor
--- @param ctx    table   { ingredients = {{id, ...}, ...}, catalysts = {...} }
return function(spawned, ctx)
    local stone_in1 = EntityGetAllChildren(ctx.ingredients[1][1], "energy_shield")
    local stone_in2 = EntityGetAllChildren(ctx.ingredients[1][2], "energy_shield")
    local stone_out = EntityGetAllChildren(spawned[1],             "energy_shield")

    if not stone_in1 or not stone_in2 or not stone_out then
        log.error("fuse_shield_effect: impossible de trouver les 3 stones source")
        return
    end

    local total     = #stone_in1 + #stone_in2
    local ox, oy    = EntityGetTransform(spawned[1])

    -- Ajouter (total - 1) anneaux supplémentaires (stone_out en a déjà 1)
    for _ = 1, total - 1 do
        local new_shield = EntityLoad(SHIELD_XML, ox, oy)
        EntityAddChild(spawned[1], new_shield)
    end

    -- Régler le rayon de chaque anneau
    local all_out = EntityGetAllChildren(spawned[1], "energy_shield") or {}
    for i, shield_entity in ipairs(all_out) do
        local radius = BASE_RADIUS + (i - 1) * RADIUS_STEP

        local shield_comps = EntityGetComponentIncludingDisabled(shield_entity, "EnergyShieldComponent")
        if shield_comps then
            for _, c in ipairs(shield_comps) do
                ComponentSetValue2(c, "radius", radius)
            end
        end

        local particle_comps = EntityGetComponentIncludingDisabled(shield_entity, "ParticleEmitterComponent")
        if particle_comps then
            for _, c in ipairs(particle_comps) do
                ComponentSetValue2(c, "area_circle_radius", radius, radius)
            end
        end
    end

    -- Renommer la pierre avec le nombre d'anneaux
    local name = utils.getName(spawned[1])
    utils.changeName(spawned[1], name .. " [" .. total .. "]")

    log.info("fuse_shield_effect: fusion complète — " .. #all_out .. " anneaux")
end
