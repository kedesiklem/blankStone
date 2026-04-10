local utils   = dofile_once("mods/blankStone/files/scripts/utils.lua")

-- Very hacky, use how the storage size is handle by BagsOfMany using names

--- Fonction apply pour l'executor upgrade.
--- @param entity_id entity_id  ID de l'entité à upgrader
return function(entity_id)
    EntitySetName(entity_id, "upgraded_universal_storageStone")
    local current_name = utils.getName(entity_id)
    utils.changeName(entity_id, current_name .. "+")
end
