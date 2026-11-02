-- based on Purgatory by Priskip

local stone_io = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_stone_io.lua")

local PREFIX = "$blankstone_lab_"

local function setInteractText(slot_id, key)
    local comp = EntityGetFirstComponentIncludingDisabled(slot_id, "InteractableComponent")
    if comp then ComponentSetValue2(comp, "ui_text", GameTextGetTranslatedOrNot(key)) end
end

local function setDisplayName(slot_id, text)
    local comp = EntityGetFirstComponentIncludingDisabled(slot_id, "UIInfoComponent")
    if comp then ComponentSetValue2(comp, "name", text) end
end

local NAME_KEY = {
    potion       = "$item_potion_with_material",
    powder_stash = "$item_powder_stash_with_material_3",
}

--- Équivalent de GetMaterialInventoryMainMaterial sur content.materials
--- @param materials string "mat,amount-mat,amount"
--- @return string|nil material_name
local function getMainMaterial(materials)
    local best, best_amount = nil, 0
    for entry in string.gmatch(materials or "", "[^%-]+") do
        local mat, amount = entry:match("^(.-),(.*)$")
        amount = tonumber(amount) or 0
        if mat and amount > best_amount then
            best, best_amount = mat, amount
        end
    end
    return best
end

--- @param content table|nil
local function describeContent(content)
    if not content then
        return GameTextGetTranslatedOrNot(PREFIX .. "empty")
    end

    if content.kind == "stone" then
        return GameTextGetTranslatedOrNot(stone_io.b64Decode(content.item_name or ""))
    end

    local mat = getMainMaterial(content.materials)
    if not mat then
        return GameTextGetTranslatedOrNot(PREFIX .. "item_" .. tostring(content.tag))
    end

    local key = NAME_KEY[content.tag] or NAME_KEY.potion
    local mat_label = GameTextGetTranslatedOrNot(CellFactory_GetUIName(CellFactory_GetType(mat)))
    return GameTextGet(key, mat_label)
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
local INVALID_REASON_KEY = {
    nothing_held       = "interact_hold_something",
    too_deeply_nested  = "interact_too_deep",
    not_empty          = "interact_not_empty",
    not_blank_stone    = "interact_not_blank_stone",
}

local function onInvalidItem(slot_id, reason)
    setInteractText(slot_id, PREFIX .. (INVALID_REASON_KEY[reason] or "interact_invalid_item"))
end

--- @param slot_id number
local function onInventoryFull(slot_id)
    setInteractText(slot_id, PREFIX .. "inventory_full")
end

--- @param slot_id number
--- @param can_place boolean
--- @param reason string|nil  raison du refus (cf lab_validator)
local function onHintPlace(slot_id, can_place, reason)
    if can_place then
        setInteractText(slot_id, PREFIX .. "interact_place")
    else
        onInvalidItem(slot_id, reason or "nothing_held")
    end
end

--- Bouton de transmutation pressé sans rien à transmuter.
--- @param reason string  "no_slot" | "slot_empty"
local function onCycleFailed(reason)
    GamePrint(GameTextGetTranslatedOrNot(PREFIX .. "cycle_" .. reason))
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
    onCycleFailed   = onCycleFailed,
}
