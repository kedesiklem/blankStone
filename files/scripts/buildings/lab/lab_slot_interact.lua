-- based on Purgatory by Priskip

local lab_factory = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_factory.lua")

function interacting(entity_who_interacted, entity_interacted, interactable_name)
    local slot_id = GetUpdatedEntityID()
    lab_factory.interactSlot(slot_id)
end
