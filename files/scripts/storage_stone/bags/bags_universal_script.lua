dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/blankStone/files/scripts/storage_stone/utils/inventory.lua" )

local function pickup_detection(player, bag_entity)
    if not is_storageStone(bag_entity) then
        return
    end
    local pickup_input_code = tonumber(ModSettingGet("blankStone.pickup_input_code"))
    local pickup_input_type = ModSettingGet("blankStone.pickup_input_type")
    if player ~= nil and bag_entity ~= nil then
        local override_bag_entity = get_bag_pickup_override(bag_entity)
        if override_bag_entity and is_storageStone(override_bag_entity) then
            bag_entity = override_bag_entity
        end
        if pickup_input_code and pickup_input_type then
            if pickup_input_type == "Key" then
                if InputIsKeyJustDown(pickup_input_code) then
                    bag_pickup_action(player, bag_entity)
                end
            elseif pickup_input_type == "Mouse" then
                if InputIsMouseButtonJustDown(pickup_input_code) then
                    bag_pickup_action(player, bag_entity)
                end
            end
        else
            if InputIsKeyJustDown(InputCodes.Key.Key_f) then
                ModSettingSetNextValue("blankStone.pickup_input_type", "Key", false)
                ModSettingSetNextValue("blankStone.pickup_input_code", 10, false)
                bag_pickup_action(player, bag_entity)
                print("No pickup action found reverting to [G] key. Please raise a bug with the mod: BlankStone")
                GamePrint("No pickup action found reverting to [G] key by default.")
            end
        end
    end
end

return pickup_detection