local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger


-- Steve  : "$animal_necromancer_super"
-- Skoude : "$animal_necromancer_shop"

function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    local entity = GetUpdatedEntityID()
    local x, y = EntityGetTransform(entity)

    local proba_spawn = 0.01
    if EntityGetName(entity) == "$animal_necromancer_super"
    then
        proba_spawn = 0.05
    end

    local roll = Random()
    log.debug("try spawning stone_bones : "..roll)
    if roll <= proba_spawn then
        EntityLoad("mods/blankStone/files/entities/elemental_stone/stone_bones.xml", x, y)
    end
end

