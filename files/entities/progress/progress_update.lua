local MOD_PATH = "mods/blankStone/files/"
local progress_path = MOD_PATH .. "entities/progress/"

local entity_id = GetUpdatedEntityID()
local STONE_REGISTRY = dofile_once(MOD_PATH .. "scripts/stone_factory/stone_registry.lua")
local P = dofile_once(MOD_PATH .. "entities/progress/progress_utils.lua")

CACHE = CACHE or {}
local cache = CACHE[entity_id]

if not cache then
    cache = { stones = {}, emitters = {}, unlocked = {}, hint_material = {} }
    CACHE[entity_id] = cache

    local existing_sprites_by_file = {}
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
        existing_sprites_by_file[ComponentGetValue2(comp, "image_file")] = comp
    end

    local existing_emitters_by_image = {}
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "ParticleEmitterComponent") or {}) do
        local image = ComponentGetValue2(comp, "image_animation_file")
        existing_emitters_by_image[image] = comp
    end

    for k,_ in pairs(STONE_REGISTRY) do
        local stone_file = progress_path .. "stones/progress_" .. tostring(k) .. ".png"
        local hint_file = progress_path .. "stones/hint_" .. tostring(k) .. ".png"

        cache.stones[k] = existing_sprites_by_file[stone_file]
        cache.emitters[k] = existing_emitters_by_image[hint_file]
    end
end

-- Unlock : pilote le sprite de fond
for k, comp in pairs(cache.stones) do
    local unlocked = P.isUnlock(k)
    if unlocked ~= cache.unlocked[k] then
        EntitySetComponentIsEnabled(entity_id, comp, unlocked)
        cache.unlocked[k] = unlocked
    end
end

-- Hint : un seul emetteur par stone, material change dynamiquement
for k, emitter in pairs(cache.emitters) do
    local material = P.getHintMaterial(k) -- nil si aucun role actif

    if material ~= cache.hint_material[k] then
        EntitySetComponentIsEnabled(entity_id, emitter, material ~= nil)
        if material then
            ComponentSetValue2(emitter, "emitted_material_name", material)
        end
        cache.hint_material[k] = material
    end
end