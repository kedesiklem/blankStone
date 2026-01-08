local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

-- BRUNK DOUBLE VISION EFFECT
effect_status.give_effect(player_id, "mods/blankStone/files/entities/misc/effect_double_vision.xml", "blankstone_doublevision_effect", true)

local function clear_liquid(potion_id, material_id)
    local material_name_input = CellFactory_GetName(material_id -1)
    AddMaterialInventoryMaterial(potion_id, material_name_input, 0)
end

local function convert_all_liquid_alcohol(potion_id)
        -- Material quantity check
    local potion_inventory = EntityGetFirstComponentIncludingDisabled(potion_id, "MaterialInventoryComponent")

    if not(potion_inventory) then
        log.error("How the fuck potion has no MaterialInventoryComponent?")
        return
    end

    local cpmt = ComponentGetValue2(potion_inventory, "count_per_material_type")

    local alcohol_id = CellFactory_GetType("alcohol")

    local acumulator = 0

    for material_id, count in ipairs(cpmt) do
        if count ~= 0 and material_id ~= alcohol_id+1 then
            clear_liquid(potion_id, material_id)
            acumulator = acumulator + count
        end
    end
    AddMaterialInventoryMaterial(potion_id, "alcohol", cpmt[alcohol_id +1] + acumulator)
end

convert_all_liquid_alcohol(entity_id)