local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local children = EntityGetAllChildren(player_id) or {}
local has_effect = false

-- BRUNK DOUBLE VISION EFFECT

for _, child_id in ipairs(children) do
    local name = EntityGetName(child_id)
    if name == "blankstone_doublevision_effect" then
        has_effect = true
        break
    end
end

if not has_effect then
    local x, y = EntityGetTransform(player_id)
    local effect_id = EntityLoad("mods/blankStone/files/entities/misc/effect_double_vision.xml", x, y)
    EntityAddChild(player_id, effect_id)
    EntitySetName(effect_id, "blankstone_doublevision_effect")
end



-- return the quantity extract from the main material, nil == error
local function clear_liquid(potion_id, material_id)
    local material_name_input = CellFactory_GetName(material_id -1)
    AddMaterialInventoryMaterial(potion_id, material_name_input, 0)

end

local function convert_all_liquid_alcohol(potion_id)
        -- Material quantity check
    local potion_inventory = EntityGetFirstComponent(potion_id, "MaterialInventoryComponent")

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