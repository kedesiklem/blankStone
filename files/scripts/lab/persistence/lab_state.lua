-- based on Purgatory by Priskip

-- Persistance du contenu d'un slot, indépendante de sa position ou de la
-- scène qui l'a fait apparaître. Clé = préfixe + instance_id du lab_root
-- (généré une fois via utils.getOrCreateInstanceId, donc stable même si le
-- labo est rechargé) + index du slot. Deux labos différents ne peuvent donc
-- jamais se marcher dessus, contrairement à un système à clé fixe.

local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local log   = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local PREFIX = "blankStone_lab_"

--- @param instance_id string
--- @param slot_index number
--- @return string
local function key(instance_id, slot_index)
    return PREFIX .. instance_id .. "_" .. tostring(slot_index)
end

--- @param instance_id string
--- @param slot_index number
--- @return table|nil content  nil si le slot est vide
local function getSlotContent(instance_id, slot_index)
    local raw = GlobalsGetValue(key(instance_id, slot_index), "")
    if raw == "" then return nil end
    return utils.deserializeData(raw)
end

--- @param instance_id string
--- @param slot_index number
--- @param content table
local function setSlotContent(instance_id, slot_index, content)
    GlobalsSetValue(key(instance_id, slot_index), utils.serializeData(content))
    log.debug("lab_state: slot " .. slot_index .. " de " .. instance_id .. " rempli")
end

--- @param instance_id string
--- @param slot_index number
local function clearSlotContent(instance_id, slot_index)
    GlobalsSetValue(key(instance_id, slot_index), "")
    log.debug("lab_state: slot " .. slot_index .. " de " .. instance_id .. " vidé")
end

return {
    getSlotContent   = getSlotContent,
    setSlotContent   = setSlotContent,
    clearSlotContent = clearSlotContent,
}
