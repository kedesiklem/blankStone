local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function remove_effect()
    local entity_id = GetUpdatedEntityID()
    local player_id = EntityGetRootEntity(entity_id)

    local variables = EntityGetComponentIncludingDisabled( entity_id, "VariableStorageComponent" )

    -- Apply stain immunity define in variables stain_immunity
    if ( variables ~= nil ) then
        for i,v in ipairs(variables) do
            local name = ComponentGetValue2( v, "name" )
            
            if ( name == "stain_immunity" ) then
                local stain_immunity_list = ComponentGetValue2( v, "value_string" )
                for effect in stain_immunity_list:gmatch("[^,]+") do
                    log.debug("Grant \"" .. effect .. "\" immunity")
                    EntityRemoveStainStatusEffect(player_id, effect, 5)
                    EntityRemoveIngestionStatusEffect(player_id, effect)
                end
            end
        end
    end
end

remove_effect()