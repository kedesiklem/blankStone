-- based on Purgatory by Priskip

local lab_factory = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_factory.lua")

function collision_trigger(colliding_entity)
    local slot_id = GetUpdatedEntityID()
    lab_factory.updateSlotHint(slot_id)
end
