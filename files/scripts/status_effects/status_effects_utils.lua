---@param player_id number
---@param effect_path string
---@param effect_name string
---@param check bool?
---@return nil
local function give_effect(player_id, effect_path, effect_name, check)
    if check then
        local children = EntityGetAllChildren(player_id) or {}

        for _, child_id in ipairs(children) do
            local name = EntityGetName(child_id)
            if name == effect_name then
                return
            end
        end
    end

    local x, y = EntityGetTransform(player_id)
    local effect_id = EntityLoad(effect_path, x, y)
    EntityAddChild(player_id, effect_id)
    EntitySetName(effect_id, effect_name)
end

return {
    give_effect = give_effect
}