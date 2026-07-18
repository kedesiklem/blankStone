-- based on Purgatory by Priskip

local lab_item_io = dofile_once("mods/blankStone/files/scripts/lab/executors/lab_item_io.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local DISPLAY_ENTITY_PATH = "mods/blankStone/files/entities/lab/stored_item_display.xml"

--- @param slot_entity number
--- @param content table
--- @return number display_entity_id
local function spawnDisplay(slot_entity, content)
    local x, y = EntityGetTransform(slot_entity)
    local display_id = EntityLoad(DISPLAY_ENTITY_PATH, x, y)

    lab_item_io.writeContent(display_id, content)
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
