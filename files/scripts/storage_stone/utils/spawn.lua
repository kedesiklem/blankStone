dofile_once("data/scripts/lib/utilities.lua")

---@return integer|nil player_entity_id
function get_player()
    return EntityGetWithTag("player_unit")[1]
end

---@return number, number, number, number, number # x, y position of player
function get_player_pos()
    local player = get_player()
    if not player then return 0, 0, 0, 0, 0 end
    return EntityGetTransform(player)
end