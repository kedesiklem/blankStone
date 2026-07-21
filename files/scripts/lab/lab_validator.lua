-- based on Purgatory by Priskip

local U = dofile_once("mods/blankStone/files/scripts/utils.lua")

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
    hasFreeInventorySlot = hasFreeInventorySlot,
}
