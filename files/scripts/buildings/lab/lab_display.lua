-- based on Purgatory by Priskip

local lab_item_io = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_item_io.lua")
local stone_io    = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_stone_io.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local ITEM_DISPLAY_ENTITY_PATH = "mods/blankStone/files/entities/lab/stored_item_display.xml"
local STONE_DISPLAY_ENTITY_PATH = "mods/blankStone/files/entities/lab/stored_stone_display.xml"

--- Vitrine pierre = un sprite simple (item_gfx capturé au dump, dans
--- content.sprite), pas la pierre réelle ni son contenu respawnés.
--- @param content table
--- @param x number
--- @param y number
--- @return number|nil display_entity_id
local function spawnStoneDisplay(content, x, y)
    local display_id = EntityLoad(STONE_DISPLAY_ENTITY_PATH, x, y)
    if not display_id then return nil end

    local sprite = stone_io.b64Decode(content.sprite or "")
    if sprite ~= "" then
        for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(display_id, "SpriteComponent") or {}) do
            ComponentSetValue2(comp_id, "image_file", sprite)
        end
    end

    return display_id
end

--- Sprite de la vitrine "liquide" selon content.tag (potion / powder_stash).
local LIQUID_SPRITES = {
    potion       = { image_file = "data/items_gfx/potion.png",         offset_y = 4 },
    powder_stash = { image_file = "data/items_gfx/material_pouch.png", offset_y = 6 },
}

--- @param content table
--- @param x number
--- @param y number
--- @return number|nil display_entity_id
local function spawnLiquidDisplay(content, x, y)
    local display_id = EntityLoad(ITEM_DISPLAY_ENTITY_PATH, x, y)
    if not display_id then return nil end

    lab_item_io.writeContent(display_id, content)

    local sprite = LIQUID_SPRITES[content.tag] or LIQUID_SPRITES.potion
    for _, comp_id in ipairs(EntityGetComponentIncludingDisabled(display_id, "SpriteComponent") or {}) do
        ComponentSetValue2(comp_id, "image_file", sprite.image_file)
        ComponentSetValue2(comp_id, "offset_y", sprite.offset_y)
        EntityRefreshSprite(display_id, comp_id)
    end

    return display_id
end

--- @param slot_entity number
--- @param content table
--- @return number|nil display_entity_id
local function spawnDisplay(slot_entity, content)
    local x, y = EntityGetTransform(slot_entity)
    local display_id

    if content.kind == "stone" then
        display_id = spawnStoneDisplay(content, x, y)
    else
        display_id = spawnLiquidDisplay(content, x, y)
    end

    if not display_id then
        log.error("lab_display.spawnDisplay: échec du spawn de la vitrine")
        return nil
    end

    EntityAddChild(slot_entity, display_id)

    log.debug("lab_display_executor: vitrine " .. display_id .. " posée sur slot " .. slot_entity)
    return display_id
end

--- Tue l'entité vitrine actuellement enfant du slot, si elle existe.
--- @param slot_entity number
local function killDisplay(slot_entity)
    local children = EntityGetAllChildren(slot_entity)
    if not children then return end
    for _, child in ipairs(children) do
        EntityKill(child)
    end
end

return {
    spawnDisplay = spawnDisplay,
    killDisplay = killDisplay,
}
