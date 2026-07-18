-- based on Purgatory by Priskip

function item_pickup(entity_item, entity_who_picked, name)
    local entity_id = GetUpdatedEntityID()
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        ComponentSetValue2(item_comp, "auto_pickup", false)
    end
end
