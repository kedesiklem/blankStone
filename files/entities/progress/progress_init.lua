local mod_path = "mods/blankStone/files/"
local progress_path = mod_path .. "entities/progress/"

local entity_id = GetUpdatedEntityID()
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")

local BACKGROUND_Z_INDEX = 1.4
local STONE_Z_INDEX = 1.3

local existing_by_file = {}
for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
    existing_by_file[ComponentGetValue2(comp, "image_file")] = comp
end

local back_file = progress_path .. "progress_back.png"
if not existing_by_file[back_file] then
    EntityAddComponent(entity_id, "SpriteComponent", {
        image_file = back_file,
        z_index = BACKGROUND_Z_INDEX,
    })
end

for k,_ in pairs(STONE_REGISTRY) do
    local stone_file = progress_path .. "stones/progress_" .. tostring(k) .. ".png"
    if not existing_by_file[stone_file] then
        EntityAddComponent(entity_id, "SpriteComponent", {
            image_file = stone_file,
            z_index = STONE_Z_INDEX,
            _enabled = false,
        })
    end
end