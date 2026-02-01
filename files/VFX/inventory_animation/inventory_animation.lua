local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

local function animate_inventory_sprite(entity_id)
    local config_var = utils.getVariable(entity_id, "animation_config")
    if not config_var then
        log.warn("Missing animation_config variable")
        return
    end
    
    local anim_type = utils.getValue(config_var, "value_string", "loop")
    local num_tiles = utils.getValue(config_var, "value_int", 1)
    
    local folder_var = utils.getVariable(entity_id, "animation_folder")
    if not folder_var then
        log.warn("Missing animation_folder variable")
        return
    end
    
    local tile_folder = utils.getValue(folder_var, "value_string", "")
    
    local state_var = utils.getVariable(entity_id, "animation_state")
    if not state_var then
        log.warn("Missing animation_state variable")
        return
    end
    
    local current_frame = utils.getValue(state_var, "value_int", 0)
    local blink_state = utils.getValue(state_var, "value_float", 0)
    
    local next_frame = current_frame
    local next_blink_state = blink_state
    
    if anim_type == "loop" then
        next_frame = (current_frame + 1) % num_tiles
        
    elseif anim_type == "pulse" then
        local max_counter = (num_tiles - 1) * 2
        local counter = (current_frame + 1) % max_counter
        
        if counter < num_tiles then
            next_frame = counter
        else
            next_frame = max_counter - counter
        end
        
    elseif anim_type == "blink" then
        if blink_state == 0 then
            -- 0.5% every 6 frames to start blink animation
            if math.random(1, 200) <= 1 then
                next_blink_state = 1
            end
            next_frame = 0
        elseif blink_state == 1 then
            next_frame = current_frame + 1
            if(next_frame == (num_tiles - 1))
            then next_blink_state = 2
            end
        else
            next_frame = current_frame - 1
            if(next_frame == 0)
            then next_blink_state = 0
            end
        end
    else
        log.warn("Unknown animation type: " .. anim_type)
        return
    end
    
    local sprite_path = tile_folder .. "/tile-" .. next_frame .. ".png"
    
    local item_components = EntityGetComponentIncludingDisabled(entity_id, "ItemComponent")
    if not item_components then
        log.warn("No ItemComponent found on entity " .. tostring(entity_id))
        return
    end
    
    for _, item_comp in ipairs(item_components) do
        utils.setValue(item_comp, "ui_sprite", sprite_path)
    end
    
    utils.setValue(state_var, "value_int", next_frame)
    utils.setValue(state_var, "value_float", next_blink_state)
end

animate_inventory_sprite(GetUpdatedEntityID())