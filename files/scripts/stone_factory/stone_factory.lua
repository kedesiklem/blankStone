-- stone_factory.lua

local LEVEL_REQUIREMENTS = dofile_once("mods/blankStone/files/scripts/stone_factory/level_requirements.lua")
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua")

local function checkLevelRequirements(all_requirements, pos_x, pos_y, potion_id)
    local check = true
    
    -- Material quantity check
    local min_potion_count = all_requirements.min_potion_count or 0
    local material_id = GetMaterialInventoryMainMaterial(potion_id)
    if min_potion_count > 0 then
        local potion_inventory = EntityGetFirstComponent(potion_id, "MaterialInventoryComponent")
        if potion_inventory then
            local cpmt = ComponentGetValue2(potion_inventory, "count_per_material_type")

            -- Why +1 ? Because fuck you that's why.
            local count = cpmt[material_id +1] or 0
            
            check = check and (count >= min_potion_count)
        else
            log.error("How the fuck potion has no MaterialInventoryComponent?")
            return false
        end
    end

    -- Orb count check
    local min_orb = all_requirements.min_orb or 0
    local np_orb = GameGetOrbCountThisRun()
    check = check and np_orb >= min_orb

    -- Purity check
    -- ID of Corrupted Orb in the west adds 128 to Main World's ID, and the ones in east adds 256
    local pure_orb_only = all_requirements.pure_orb_only or false
    if pure_orb_only and np_orb ~= 0 then
        local corrupted = false
        for i=0, 11 do 
            for _, j in ipairs({128, 256}) do
                corrupted = corrupted or GameGetOrbCollectedThisRun(i + j)
            end
        end
        if corrupted then
            log.info("You're corrupt.")
        end
        check = check and not(corrupted)
    end

    return check
end

local function checkSpecificConditions(specific_conditions, pos_x, pos_y)
    log.debug("Checking specific requirements not implemented yet")
    -- TODO: Implémenter les checks spécifiques
    return true
end

local function createStone(stone_data, pos_x, pos_y)
    -- Charger l'entité de la pierre
    EntityLoad(stone_data.path, pos_x, pos_y - 5)
    -- Spawn VFX Entity (explosion/gliph...)
    for i=1, #stone_data.vfx do
        EntityLoad(stone_data.vfx[i], pos_x, pos_y - 5)
    end
    if stone_data.message then
        GamePrintImportant(stone_data.message)
    else
        GamePrint("You've done something...")
    end
    log.info("Stone created: " .. stone_data.path)
end

local function tryCreateStoneFromPotion(stone_key, pos_x, pos_y, potion_id)
    -- Gérer la structure custom_stone vs vanilla_stone
    local stone_data = STONE_REGISTRY[stone_key]
    
    -- Useless if the lookup table is done correctly
    if not stone_data then
        log.warn("Stone key not found in registry: " .. tostring(stone_key))
        return false
    end

    log.debug("Found stone data for key: " .. tostring(stone_key))
    
    -- Vérifier les conditions de level
    if stone_data.conditions.use_level_requirements then
        local all_requirements = LEVEL_REQUIREMENTS[stone_data.level]
        if not checkLevelRequirements(all_requirements, pos_x, pos_y, potion_id) then
            return false
        end
    end
    
    -- Vérifier les conditions spécifiques
    if stone_data.conditions.specific then
        if not checkSpecificConditions(stone_data.conditions.specific, pos_x, pos_y) then
            log.info("Specific conditions not met for stone: " .. tostring(stone_key))
            return false
        end
    else
        log.debug("No specific conditions for stone: " .. tostring(stone_key))
    end
    
    -- Toutes les conditions remplies : créer la pierre
    createStone(stone_data, pos_x, pos_y)
    return true
end

return {
    createStone = createStone,
    tryCreateStoneFromPotion = tryCreateStoneFromPotion
}