-- based on Purgatory by Priskip

local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
local stone_io = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_stone_io.lua")

local MAX_QUICK_INVENTORY_SLOTS = 4

--- @param item_entity number|nil
--- @return boolean ok, string|nil reason
local function canStore(item_entity)
    if not item_entity then return false, "nothing_held" end

    local is_potion = EntityHasTag(item_entity, "potion")
    local is_sack = EntityHasTag(item_entity, "powder_stash")
    if is_potion or is_sack then
        return true, nil
    end

    if stone_io.isStone(item_entity) then
        -- Rejeté explicitement plutôt que silencieusement tronqué au dump :
        -- une storageStone contenant trop de storageStones imbriquées ne doit
        -- pas perdre discrètement une partie de son contenu.
        if stone_io.computeNestingDepth(item_entity) > stone_io.MAX_DEPTH then
            return false, "too_deeply_nested"
        end
        return true, nil
    end

    return false, "wrong_item_type"
end

--- @param item_entity number
--- @return boolean
local function isLiquidEmpty(item_entity)
    local mat_inv_comp = EntityGetFirstComponentIncludingDisabled(item_entity, "MaterialInventoryComponent")
    if not mat_inv_comp then return true end
    for _, amount in ipairs(ComponentGetValue2(mat_inv_comp, "count_per_material_type") or {}) do
        if amount ~= 0 then return false end
    end
    return true
end

--- Slot de transmutation : potion vide, powder_stash vide ou blank stone
--- uniquement - tout autre objet serait perdu à la conversion.
--- @param item_entity number|nil
--- @return boolean ok, string|nil reason
local function canStoreCycle(item_entity)
    if not item_entity then return false, "nothing_held" end

    if EntityHasTag(item_entity, "potion") or EntityHasTag(item_entity, "powder_stash") then
        if not isLiquidEmpty(item_entity) then return false, "not_empty" end
        return true, nil
    end

    if stone_io.isStone(item_entity) then
        if not stone_io.isBlankStone(item_entity) then return false, "not_blank_stone" end
        return true, nil
    end

    return false, "wrong_item_type"
end

--- utils.lua de blankStone n'a pas d'équivalent à getHeldItems() de
--- purgatory - implémentation autonome ici plutôt que de dépendre d'une
--- fonction qui n'existe pas (bug précédent : U.getHeldItems plantait au
--- premier appel).
--- @param player number
--- @return number
local function countHeldItems(player)
    if not player then return 0 end
    for _, child in ipairs(EntityGetAllChildren(player) or {}) do
        if EntityGetName(child) == "inventory_quick" then
            return #(U.getHeldItems(player) or {})
        end
    end
    return 0
end

--- @return boolean
local function hasFreeInventorySlot()
    return countHeldItems(U.getPlayer()) < MAX_QUICK_INVENTORY_SLOTS
end

return {
    canStore = canStore,
    canStoreCycle = canStoreCycle,
    hasFreeInventorySlot = hasFreeInventorySlot,
}
