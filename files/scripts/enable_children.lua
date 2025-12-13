-- To correct children disable bug
function throw_item( from_x, from_y, to_x, to_y )
    local entity_id = GetUpdatedEntityID()
    local children = EntityGetAllChildren(entity_id)
    if (children) then
        for _, child in ipairs(children) do
            local components = EntityGetAllComponents(child)
            for _, component in ipairs(components) do
                EntitySetComponentIsEnabled(child, component, true)
            end
        end
    end
end