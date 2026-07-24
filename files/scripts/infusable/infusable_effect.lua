local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
local I = dofile_once("mods/blankStone/files/scripts/infusable/infusable_utils.lua")

local entity_id = GetUpdatedEntityID()
local stone_id = EntityGetRootEntity(entity_id)
if stone_id == 0 then return end

local infusable_id
local children = EntityGetAllChildren(stone_id)
if children then
    for _, child in pairs(children) do
        if EntityGetName(child) == "infusableEntity" then
            infusable_id = child
        end
    end
end
if not infusable_id then log.error("How the fuck ? infuse entity without infusableEntity") return end

local pos_x, pos_y = EntityGetTransform(entity_id)
local entityName = U.getEntityIdentifier(stone_id)
local reactives_id = I.getNearbyReactives(pos_x, pos_y)

log.debug("infusable_effect (classique) : " .. #reactives_id .. " réactif(s) trouvé(s) pour " .. tostring(entityName))

if #reactives_id == 0 then
    log.debug("Reset hint count")
    local hint_id = U.getVariable(infusable_id, "hintEnable")
    U.setValue(hint_id, "value_int", 0)
else
    for i = 1, #reactives_id do
        -- Don't use potion directly from inventory
        if reactives_id[i] == EntityGetRootEntity(reactives_id[i]) then
            log.debug("infusable_effect (classique) : tentative sur réactif " .. tostring(reactives_id[i]))
            if I.tryCreateStone(reactives_id[i], pos_x, pos_y, stone_id, infusable_id, entityName) then
                log.info("infusable_effect (classique) : infusion réussie via réactif " .. tostring(reactives_id[i]))
                break
            end
        end
    end
end