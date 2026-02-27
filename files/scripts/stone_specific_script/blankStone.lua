local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

function kick( entity_who_kicked )
    local entity_id = GetUpdatedEntityID()

    if(entity_id ~= EntityGetRootEntity(entity_id)) then return end

    -- Cap usage
    local liquidAvailable = utils.getVariable(entity_id, "liquidAvailable")
    local quantityAvaiblable = utils.getValue(liquidAvailable, "value_int")

    if(quantityAvaiblable <= 0) then return end

    local quantity = math.min(quantityAvaiblable, 20)
    utils.setValue(liquidAvailable,"value_int",quantityAvaiblable - quantity)
    
    local x,y = EntityGetTransform(entity_id)
    GameCreateParticle("mimic_liquid",x,y,quantity,0,0,false)
end