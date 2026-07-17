local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function warnPlayer()
    log.warn("Player detected in parallel world!")
end

local function banPlayer()
    log.error("Player banned from main quest!")
end

local function isBanned()
    return false
end

local function inMainWorld()
    local player = GetUpdatedEntityID()
    if player == nil or player == 0 or not EntityGetIsAlive(player) then
        return true
    end

    local x, y = EntityGetTransform(player)
    local pw_x, pw_y = GetParallelWorldPosition(x, y)
    return (pw_x == 0 and pw_y == 0)
end

return {
    warnPlayer = warnPlayer,
    banPlayer = banPlayer,
    isBanned = isBanned,
    inMainWorld = inMainWorld,
}