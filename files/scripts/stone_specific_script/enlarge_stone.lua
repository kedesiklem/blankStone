-- Doesn't work as intended but do the job
function kick( entity_who_kicked )
    local entity_id = GetUpdatedEntityID()

    if(entity_id ~= EntityGetRootEntity(entity_id)) then return end
    
    local pos_x, pos_y, rot, scale_x, scale_y = EntityGetTransform( entity_id )
    if(Random() <= 0.92)
    -- if(true)
    then
        EntitySetTransform(entity_id, pos_x, pos_y, rot, scale_x * 1.2, scale_y * 1.2)
    else
        -- big stone = big explosion
        if(scale_x >= 2.0) then
            EntityLoad("data/entities/projectiles/deck/explosion_giga.xml", pos_x, pos_y - 10)
        else
            EntityLoad("data/entities/projectiles/explosion.xml", pos_x, pos_y - 10)
        end
        EntityKill(entity_id)
    end
end