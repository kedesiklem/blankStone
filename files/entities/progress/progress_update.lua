local mod_path = "mods/blankStone/files/"
local progress_path = mod_path .. "entities/progress/"

local entity_id = GetUpdatedEntityID()
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")

local mod_progess_prefix = "blankstone_progress_"

CACHE = CACHE or {}
local cache = CACHE[entity_id]

if not cache then
    cache = { stones = {}, unlocked = {} }
    CACHE[entity_id] = cache

    local existing_by_file = {}
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
        existing_by_file[ComponentGetValue2(comp, "image_file")] = comp
    end

    for k,_ in pairs(STONE_REGISTRY) do
        local stone_file = progress_path .. "stones/progress_" .. tostring(k) .. ".png"
        cache.stones[k] = existing_by_file[stone_file]
    end
end

for k, comp in pairs(cache.stones) do
    local unlocked = HasFlagPersistent(mod_progess_prefix .. k)
    if unlocked ~= cache.unlocked[k] then
        EntitySetComponentIsEnabled(entity_id, comp, unlocked)
        cache.unlocked[k] = unlocked
    end
end