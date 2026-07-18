-- based on Purgatory by Priskip

function init(entity_id)
    EntityAddComponent2(entity_id, "LuaComponent", {
        script_source_file = "mods/blankStone/files/scripts/buildings/lab/lab_restore_appends.lua",
        execute_every_n_frame = 5,
        remove_after_executed = true,
    })
end
