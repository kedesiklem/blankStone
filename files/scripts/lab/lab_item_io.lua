-- based on Purgatory by Priskip and spellLabShuggle

-- Point d'entrée unique pour lire/écrire/reconstruire le contenu stocké par le
-- lab. Deux familles de contenu, distinguées par content.kind :
--   - "liquid" : potions / powder_stash (logique d'origine, MaterialInventoryComponent)
--   - "stone"  : pierres blankStone, y compris storageStone récursives
--                (délégué à lab_stone_io.lua)
-- lab_display.lua et lab_feedback.lua dispatchent eux aussi sur content.kind.

local log       = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local stone_io  = dofile_once("mods/blankStone/files/scripts/lab/lab_stone_io.lua")

local PICKUP_PATH = {
    potion = "data/entities/items/pickup/potion.xml",
    powder_stash = "data/entities/items/pickup/powder_stash.xml",
}

-- =============================================================================
-- Liquides (potion / powder_stash) - logique d'origine, kind="liquid" ajouté
-- =============================================================================

--- @param item_entity number
--- @return table|nil content
local function readLiquidContent(item_entity)
    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(item_entity, "MaterialInventoryComponent")
    if not mat_inv_comp then
        log.warn("lab_item_io.readLiquidContent: pas de MaterialInventoryComponent")
        return nil
    end

    local is_potion = EntityHasTag(item_entity, "potion")

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
        kind        = "liquid",
        tag         = is_potion and "potion" or "powder_stash",
        barrel_size = tostring(barrel_size),
        materials   = table.concat(parts, "-"),
    }
end

--- @param item_entity number
--- @param content table
local function writeLiquidContent(item_entity, content)
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

--- @param content table
--- @param x number
--- @param y number
--- @return number|nil entity_id
local function createLiquidPickup(content, x, y)
    local path = PICKUP_PATH[content.tag]
    if not path then
        log.error("lab_item_io.createLiquidPickup: tag inconnu '" .. tostring(content.tag) .. "'")
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

    writeLiquidContent(id, content)

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

-- =============================================================================
-- Dispatch public (inchangé pour lab_factory.lua : signatures identiques)
-- =============================================================================

--- Lit le contenu d'une potion/sac/pierre et le retourne sous forme de table
--- prête à être sauvegardée (via state.setSlotContent, qui la fait passer par
--- utils.serializeData - un content "stone" reste un simple {kind, data}
--- compatible avec ce format plat, `data` étant du base64 donc sans '|' ni
--- caractère qui casserait le parsing).
--- @param item_entity number|nil
--- @return table|nil content
local function readContent(item_entity)
    if not item_entity then return nil end

    local is_potion = EntityHasTag(item_entity, "potion")
    local is_sack = EntityHasTag(item_entity, "powder_stash")
    if is_potion or is_sack then
        return readLiquidContent(item_entity)
    end

    if stone_io.isStone(item_entity) then
        local data, item_name, sprite = stone_io.serialize(item_entity)
        if not data then
            log.warn("lab_item_io.readContent: échec de la capture de la pierre")
            return nil
        end
        return { kind = "stone", data = data, item_name = item_name, sprite = sprite }
    end

    log.warn("lab_item_io.readContent: entité ni potion, ni powder_stash, ni pierre reconnue")
    return nil
end

--- Utilisé uniquement pour la vitrine "liquide" (potion/powder_stash) :
--- writeContent sur une pierre n'a pas de sens dans ce schéma - cf
--- lab_stone_io.spawnDecorative pour l'équivalent vitrine des pierres,
--- appelé directement depuis lab_display.lua.
--- @param item_entity number
--- @param content table
local function writeContent(item_entity, content)
    if content.kind == "liquid" then
        writeLiquidContent(item_entity, content)
    end
end

--- @param content table
--- @param x number
--- @param y number
--- @return number|nil entity_id
local function createPickupEntity(content, x, y)
    if content.kind == "stone" then
        return stone_io.rebuild(content.data, x, y)
    end
    return createLiquidPickup(content, x, y)
end

return {
    readContent = readContent,
    writeContent = writeContent,
    createPickupEntity = createPickupEntity,
}
