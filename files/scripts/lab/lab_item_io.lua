
-- based on Purgatory by Priskip


local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local PICKUP_PATH = {
    potion = "data/entities/items/pickup/potion.xml",
    powder_stash = "data/entities/items/pickup/powder_stash.xml",
}

--- Lit le contenu d'une potion/sac et le retourne sous forme de table plate
--- prête à être sérialisée par utils.serializeData.
--- @param item_entity number|nil
--- @return table|nil content  { tag, barrel_size, materials }, nil si invalide
local function readContent(item_entity)
    if not item_entity then return nil end

    local is_potion = EntityHasTag(item_entity, "potion")
    local is_sack = EntityHasTag(item_entity, "powder_stash")
    if not (is_potion or is_sack) then
        log.warn("lab_item_io.readContent: entité ni potion ni powder_stash")
        return nil
    end

    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(item_entity, "MaterialInventoryComponent")
    if not mat_inv_comp then
        log.warn("lab_item_io.readContent: pas de MaterialInventoryComponent")
        return nil
    end

    local sucker_comp = EntityGetFirstComponentIncludingDisabled(item_entity, "MaterialSuckerComponent")
    local barrel_size = sucker_comp and ComponentGetValue2(sucker_comp, "barrel_size") or 0

    local count_per_material_type = ComponentGetValue2(mat_inv_comp, "count_per_material_type")
    local parts = {}
    for i, amount in ipairs(count_per_material_type) do
        if amount ~= 0 then
            table.insert(parts, CellFactory_GetName(i - 1) .. "," .. tostring(amount))
        end
    end

    return {
        tag = is_potion and "potion" or "powder_stash",
        barrel_size = tostring(barrel_size),
        materials = table.concat(parts, "-"),
    }
end

--- Applique un contenu sauvegardé au MaterialInventoryComponent d'une entité
--- déjà chargée (vitrine ou vrai pickup).
--- @param item_entity number
--- @param content table  { tag, barrel_size, materials }
local function writeContent(item_entity, content)
    local sucker_comp = EntityGetFirstComponentIncludingDisabled(item_entity, "MaterialSuckerComponent")
    if sucker_comp then
        ComponentSetValue2(sucker_comp, "barrel_size", tonumber(content.barrel_size) or 0)
    end

    if content.materials and content.materials ~= "" then
        for entry in string.gmatch(content.materials, "[^%-]+") do
            local material, amount = entry:match("^(.-),(.*)$")
            if material then
                AddMaterialInventoryMaterial(item_entity, material, tonumber(amount) or 0)
            end
        end
    end
end

--- Fabrique une vraie entité potion/sac que le joueur ramasse instantanément,
--- avec le contenu sauvegardé. Physique désactivée le temps du ramassage
--- automatique, comme dans purgatory.
--- @param content table  { tag, barrel_size, materials }
--- @param x number
--- @param y number
--- @return number|nil entity_id
local function createPickupEntity(content, x, y)
    local path = PICKUP_PATH[content.tag]
    if not path then
        log.error("lab_item_io.createPickupEntity: tag inconnu '" .. tostring(content.tag) .. "'")
        return nil
    end

    local id = EntityLoad(path, x + 4, y + 8)

    -- Vide l'inventaire par défaut du pickup vanilla avant d'appliquer le contenu sauvegardé
    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(id, "MaterialInventoryComponent")
    local count_per_material_type = ComponentGetValue2(mat_inv_comp, "count_per_material_type")
    for i, amount in ipairs(count_per_material_type) do
        if amount ~= 0 then
            AddMaterialInventoryMaterial(id, CellFactory_GetName(i - 1), 0)
        end
    end

    writeContent(id, content)

    local item_comp = EntityGetFirstComponentIncludingDisabled(id, "ItemComponent")
    if item_comp then
        ComponentSetValue2(item_comp, "auto_pickup", true)
        ComponentSetValue2(item_comp, "next_frame_pickable", GameGetFrameNum())
    end

    EntitySetComponentIsEnabled(id, EntityGetFirstComponentIncludingDisabled(id, "PhysicsBodyComponent"), false)
    EntitySetComponentIsEnabled(id, EntityGetFirstComponentIncludingDisabled(id, "PhysicsImageShapeComponent"), false)
    EntitySetComponentIsEnabled(id, EntityGetFirstComponentIncludingDisabled(id, "ProjectileComponent"), false)

    EntityAddComponent2(id, "LuaComponent", {
        remove_after_executed = true,
        script_item_picked_up = "mods/blankStone/files/scripts/buildings/lab/lab_pickup_finalize.lua",
    })

    return id
end

return {
    readContent = readContent,
    writeContent = writeContent,
    createPickupEntity = createPickupEntity,
}
