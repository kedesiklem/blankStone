local storage = dofile_once("mods/blankStone/files/scripts/storage_stone/storage.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function drop_all_item()
    log.debug("death detected for StorageStone")
    local stone_id = GetUpdatedEntityID()
    local items    = storage.get_items(stone_id)

    if #items == 0 then return end

    local sx, sy = EntityGetTransform(stone_id)

    for _, item in ipairs(items) do
        if not EntityGetIsAlive(item) then goto skip end

        -- Retire de la hiérarchie et nettoie le marqueur de position
        storage.remove_item_position(item)
        EntityRemoveFromParent(item)

        -- Dispersion aléatoire autour du point de mort
        local dx = math.random(-14, 14)
        local dy = math.random(-8, 4)
        EntityApplyTransform(item, sx + dx, sy + dy)

        -- Réaffiche l'item
        storage.show_entity(item)

        -- Réactive InheritTransformComponent (nécessaire pour les items avec parent transform)
        for _, comp in ipairs(EntityGetComponentIncludingDisabled(item, "InheritTransformComponent") or {}) do
            EntitySetComponentIsEnabled(item, comp, true)
        end

        -- Réactive les composants marqués enabled_in_inventory
        -- (certains items ont des effets passifs qui tournent en inventaire)
        for _, comp in ipairs(EntityGetAllComponents(item) or {}) do
            if ComponentHasTag(comp, "enabled_in_inventory") then
                EntitySetComponentIsEnabled(item, comp, true)
            end
        end

        -- Petite impulsion de dispersion physique
        local vel = EntityGetFirstComponentIncludingDisabled(item, "VelocityComponent")
        if vel then
            ComponentSetValue2(vel, "mVelocity", dx * 3, dy * 3 - 20)
        end

        ::skip::
    end
end

drop_all_item()