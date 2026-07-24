local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
local I = dofile_once("mods/blankStone/files/scripts/infusable/infusable_utils.lua")

local suck_id = GetUpdatedEntityID()
local stone_id = EntityGetParent(suck_id)

log.debug("infusable_liquid_suck_end : évaluation de " .. tostring(suck_id) .. " (pierre=" .. tostring(stone_id) .. ")")

if stone_id == 0 or not EntityGetIsAlive(stone_id) then
    log.debug("infusable_liquid_suck_end : pierre introuvable ou détruite, on recrache et on tue")
    EntityKill(suck_id)
    return
end

local infusable_id
local children = EntityGetAllChildren(stone_id)
if children then
    for _, child in pairs(children) do
        if EntityGetName(child) == "infusableEntity" then
            infusable_id = child
        end
    end
end
if not infusable_id then
    log.error("infusable_liquid_suck_end : How the fuck ? infuse entity without infusableEntity")
    EntityKill(suck_id)
    return
end

local entityName = U.getEntityIdentifier(stone_id)
local pos_x, pos_y = EntityGetTransform(suck_id)
local inv_comp = EntityGetFirstComponentIncludingDisabled(suck_id, "MaterialInventoryComponent")

local main_material_id = GetMaterialInventoryMainMaterial(suck_id)
log.debug("infusable_liquid_suck_end : matériau principal aspiré = " .. tostring(main_material_id ~= 0 and CellFactory_GetName(main_material_id) or "aucun"))

local key = I.findMaterialKey(suck_id, entityName)

if key then
    log.info("infusable_liquid_suck_end : matériau valide (" .. key .. ") pour " .. entityName .. ", tentative d'infusion")
    if inv_comp then
        ComponentSetValue2(inv_comp, "on_death_spill", false)
    end
    local success = I.tryCreateStone(suck_id, pos_x, pos_y, stone_id, infusable_id, entityName)
    log.info("infusable_liquid_suck_end : résultat tryCreateStone = " .. tostring(success))
    -- tryCreateStone tue suck_id lui-même en cas de succès ; s'il est encore vivant
    -- (recette trouvée mais l'infusion elle-même a échoué), on le tue nous-mêmes.
    if EntityGetIsAlive(suck_id) then
        EntityKill(suck_id)
    end
else
    log.debug("infusable_liquid_suck_end : rien d'utilisable aspiré pour " .. entityName .. ", on recrache")
    if inv_comp then
        ComponentSetValue2(inv_comp, "on_death_spill", true)
    end
    EntityKill(suck_id)
end

log.debug("Reset hint count")
local hint_id = U.getVariable(infusable_id, "hintEnable")
U.setValue(hint_id, "value_int", 0)