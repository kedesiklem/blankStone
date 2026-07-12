local mod_path = "mods/blankStone/files/"
local progress_path = mod_path .. "entities/progress/"

local x, y = EntityGetTransform(GetUpdatedEntityID())
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")


GameCreateSpriteForXFrames(progress_path .. "progress_back.png", x, y, false, 0, 0, 5)

local mod_progess_prefix = "blankstone_progress_"
for k,_ in pairs(STONE_REGISTRY) do
    if HasFlagPersistent(mod_progess_prefix .. k) then
    -- if true then
        GameCreateSpriteForXFrames(progress_path .. "stones/progress_" .. tostring(k) .. ".png", x, y, false, 0, 0, 5)
    end
end