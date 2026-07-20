-- based on Purgatory by Priskip

local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local MAX_QUICK_INVENTORY_SLOTS = 4

--- @param item_entity number|nil
--- @return boolean ok, string|nil reason
local function canStore(item_entity)
    if not item_entity then return false, "nothing_held" end

    local is_potion = EntityHasTag(item_entity, "potion")
    local is_sack = EntityHasTag(item_entity, "powder_stash")
    if not (is_potion or is_sack) then
        return false, "wrong_item_type"
    end

    return true, nil
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
            return #(EntityGetAllChildren(child) or {})
        end
    end
    return 0
end

--- @return boolean
local function hasFreeInventorySlot()
    return countHeldItems(utils.getPlayer()) < MAX_QUICK_INVENTORY_SLOTS
end

return {
    canStore = canStore,
    hasFreeInventorySlot = hasFreeInventorySlot,
}
