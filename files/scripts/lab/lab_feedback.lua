-- based on Purgatory by Priskip

local stone_io = dofile_once("mods/blankStone/files/scripts/lab/lab_stone_io.lua")

local PREFIX = "$blankstone_lab_"

local function setInteractText(slot_id, key)
    local comp = EntityGetFirstComponentIncludingDisabled(slot_id, "InteractableComponent")
    if comp then ComponentSetValue2(comp, "ui_text", GameTextGetTranslatedOrNot(key)) end
end

local function setDisplayName(slot_id, text)
    local comp = EntityGetFirstComponentIncludingDisabled(slot_id, "UIInfoComponent")
    if comp then ComponentSetValue2(comp, "name", text) end
end

--- @param content table|nil
local function describeContent(content)
    if not content then
        return GameTextGetTranslatedOrNot(PREFIX .. "empty")
    end

    local prefix = GameTextGetTranslatedOrNot(PREFIX .. "slot_filled_prefix")

    if content.kind == "stone" then
        return prefix .. GameTextGetTranslatedOrNot(stone_io.b64Decode(content.item_name or ""))
    end

    local item_label = GameTextGetTranslatedOrNot(PREFIX .. "item_" .. content.tag)
    return prefix .. item_label .. " (" .. tostring(content.barrel_size) .. ")"
end

--- @param slot_id number
--- @param content table
local function onSlotFilled(slot_id, content)
    setDisplayName(slot_id, describeContent(content))
    setInteractText(slot_id, PREFIX .. "interact_pickup")
end

--- @param slot_id number
local function onSlotEmptied(slot_id)
    setDisplayName(slot_id, GameTextGetTranslatedOrNot(PREFIX .. "empty"))
    setInteractText(slot_id, PREFIX .. "interact_place")
end

--- @param slot_id number
--- @param reason string
local function onInvalidItem(slot_id, reason)
    if reason == "nothing_held" then
        setInteractText(slot_id, PREFIX .. "interact_need_item")
    elseif reason == "too_deeply_nested" then
        setInteractText(slot_id, PREFIX .. "interact_too_deep")
    else
        setInteractText(slot_id, PREFIX .. "interact_invalid_item")
    end
end

--- @param slot_id number
local function onInventoryFull(slot_id)
    setInteractText(slot_id, PREFIX .. "inventory_full")
end

--- @param slot_id number
--- @param can_place boolean
local function onHintPlace(slot_id, can_place)
    if can_place then
        setInteractText(slot_id, PREFIX .. "interact_place")
    else
        setInteractText(slot_id, PREFIX .. "interact_need_item")
    end
end

--- @param slot_id number
--- @param has_space boolean
local function onHintPickup(slot_id, has_space)
    if has_space then
        setInteractText(slot_id, PREFIX .. "interact_pickup")
    else
        setInteractText(slot_id, PREFIX .. "inventory_full")
    end
end

return {
    onSlotFilled    = onSlotFilled,
    onSlotEmptied   = onSlotEmptied,
    onInvalidItem   = onInvalidItem,
    onInventoryFull = onInventoryFull,
    onHintPlace     = onHintPlace,
    onHintPickup    = onHintPickup,
}
