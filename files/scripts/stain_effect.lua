local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local variables = EntityGetComponentIncludingDisabled( entity_id, "VariableStorageComponent" )

-- Apply stain effect define in variables to all targets
if ( variables ~= nil ) then
    for i,v in ipairs(variables) do
        local name = ComponentGetValue2( v, "name" )
        
        if ( name == "stain_effect" ) then
            local stain_effect_liquid = ComponentGetValue2( v, "value_string" )
            local radius_effect = ComponentGetValue2( v, "value_int" )
            local quantity_effect = ComponentGetValue2( v, "value_float" )
            
            local targets = EntityGetInRadiusWithTag( x, y, radius_effect, "hittable" )

            for _,eid in pairs( targets ) do
                EntityAddRandomStains( eid, CellFactory_GetType(stain_effect_liquid), quantity_effect )
            end
        end
    end
end