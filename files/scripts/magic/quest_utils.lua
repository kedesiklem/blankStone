local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local QUEST_FAIL_FLAG = "blankstone_ban_quest"

local function warnPlayer()
    log.warn("Player detected in parallel world!")
end

local function banPlayer(x,y)
    GameAddFlagRun(QUEST_FAIL_FLAG)
	GamePrintImportant( "$text_blankstone_quest_no_perk_fail_title", "$text_blankstone_quest_no_perk_fail_desc" )
    GamePlaySound( "data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", x, y )
    GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", x, y )
end

local function banThroughPW()
    local player = GetUpdatedEntityID()
    local x,y = EntityGetTransform(player)
    EntityLoad("mods/blankStone/files/VFX/image_emitters/questLockPW.xml",x,y)
    banPlayer(x,y)
end

local function banThroughPerk()
    local player = GetUpdatedEntityID()
    local x,y = EntityGetTransform(player)
    EntityLoad("mods/blankStone/files/VFX/image_emitters/questLockPerk.xml",x,y)
    banPlayer(x,y)
end

local function isBanned()
    return GameHasFlagRun(QUEST_FAIL_FLAG)
end

local function inMainWorld()
    local player = GetUpdatedEntityID()
    local x,y = EntityGetTransform(player)
    if player == nil or player == 0 or not EntityGetIsAlive(player) then
        return true
    end

    local pw_x, pw_y = GetParallelWorldPosition(x, y)
    return (pw_x == 0 and pw_y == 0)
end


return {
    warnPlayer = warnPlayer,
    banPlayer = banPlayer,
    banThroughPW = banThroughPW,
    banThroughPerk = banThroughPerk,
    isBanned = isBanned,
    inMainWorld = inMainWorld,
    QUEST_FAIL_FLAG = QUEST_FAIL_FLAG
}