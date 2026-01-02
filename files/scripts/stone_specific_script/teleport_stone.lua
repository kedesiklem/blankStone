local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local tp = dofile_once("mods/blankStone/files/scripts/stone_specific_script/tp_stone_util.lua")

-- Use 5% of max_quantity/tp
local SLIME_USE_QUANTITY = 50

-- return the quantity extract from the main material, nil == error
local function extract_liquid_quantity(potion_id, quantity)
    -- Material quantity check
    local material_id = GetMaterialInventoryMainMaterial(potion_id)

    if(material_id == 0) then return 0 end

    local material_name = CellFactory_GetName(material_id)
    local potion_inventory = EntityGetFirstComponent(potion_id, "MaterialInventoryComponent")

    if not(potion_inventory) then
        log.error("How the fuck potion has no MaterialInventoryComponent?")
        return
    end

    local cpmt = ComponentGetValue2(potion_inventory, "count_per_material_type")

    -- Why +1 ? Because fuck you that's why.
    local count = cpmt[material_id +1] or 0

    if count < quantity then
        AddMaterialInventoryMaterial(potion_id, material_name, 0)
        return count
    end

    AddMaterialInventoryMaterial(potion_id, material_name, count - quantity)
    return quantity

end

local function use_liquid_quantity(potion_id, quantity)
    local tmp_quantity = quantity

    while tmp_quantity > 0 do
        local material_count = extract_liquid_quantity(potion_id, tmp_quantity)
        if(material_count == 0) then return false end
        tmp_quantity = tmp_quantity - material_count
    end

    return true
end

local function check_slime_perk()
    local stone = GetUpdatedEntityID()
    local player = EntityGetRootEntity(stone)
    if GameGetGameEffectCount(player, "NO_SLIME_SLOWDOWN") > 0
    then
        AddMaterialInventoryMaterial(stone, "slime", 1000)
        log.debug("Slime perk actif") 
        return true
    end
        log.debug("Slime perk inactif")
        return false
end

function kick()
    -- Check if the LuaComponent is disable to prevent tp when stone in_inventory
    local stone = GetUpdatedEntityID()
    if not(EntityGetComponent(stone, "LuaComponent", "enabled_in_hand")) then return end
    
    if(check_slime_perk() or use_liquid_quantity(stone, SLIME_USE_QUANTITY))
    then tp.tp_to_cursor()
    else tp.tp_random()
    end
end