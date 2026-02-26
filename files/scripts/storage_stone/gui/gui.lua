dofile_once( "mods/blankStone/files/scripts/storage_stone/gui/bag_inventory.lua" )
dofile_once( "mods/blankStone/files/scripts/storage_stone/utils/inputs.lua" )

local function blankStone_ui_setup()
    if type(blankStone_mod_state.button_pos_x) == "number" and type(blankStone_mod_state.button_pos_y) == "number" then
        bags_of_many_bag_gui(blankStone_mod_state.button_pos_x, blankStone_mod_state.button_pos_y)
    else
        print_error("BlankStone: Button position is not set correctly. Please check your settings. You might need to reset the mod settings file.")
    end
end

return blankStone_ui_setup