-- Teleport player to cursor position  when kicking
local function tp_to_cursor()
    local player = EntityGetRootEntity(GetUpdatedEntityID())
    local sx,sy = DEBUG_GetMouseWorld()

    EntitySetTransform(player, sx, sy)
end

function kick()
    -- Check if the LuaComponent is disable to prevent tp when stone in_inventory
    if (EntityGetComponent(GetUpdatedEntityID(), "LuaComponent", "enabled_in_hand"))
    then
        tp_to_cursor()
    end
end