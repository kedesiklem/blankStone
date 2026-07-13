local MOD_PATH = "mods/blankStone/files/"
local progress_path = MOD_PATH .. "entities/progress/"

local entity_id = GetUpdatedEntityID()
local STONE_REGISTRY = dofile_once(MOD_PATH .. "scripts/stone_factory/stone_registry.lua")
local P = dofile_once(MOD_PATH .. "entities/progress/progress_utils.lua")

CACHE = CACHE or {}
local cache = CACHE[entity_id]

if not cache then
    cache = { stones = {}, emitters = {}, unlocked = {}, hinted = {} }
    CACHE[entity_id] = cache

    local existing_sprites_by_file = {}
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
        existing_sprites_by_file[ComponentGetValue2(comp, "image_file")] = comp
    end

    local existing_emitters_by_key = {}
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "ParticleEmitterComponent") or {}) do
        local image = ComponentGetValue2(comp, "image_animation_file")
        local material = ComponentGetValue2(comp, "emitted_material_name")
        existing_emitters_by_key[image .. "|" .. material] = comp
    end

    for k,_ in pairs(STONE_REGISTRY) do
        local stone_file = progress_path .. "stones/progress_" .. tostring(k) .. ".png"
        local hint_file = progress_path .. "stones/hint_" .. tostring(k) .. ".png"

        cache.stones[k] = existing_sprites_by_file[stone_file]

        local emittersForStone = {}
        for role, roleDef in pairs(P.HINT_ROLES) do
            emittersForStone[role] = existing_emitters_by_key[hint_file .. "|" .. roleDef.material]
        end
        cache.emitters[k] = emittersForStone
        cache.hinted[k] = {}
    end
end

-- Unlock : pilote le sprite de fond
for k, comp in pairs(cache.stones) do
    local unlocked = P.isUnlocked(k)
    if unlocked ~= cache.unlocked[k] then
        EntitySetComponentIsEnabled(entity_id, comp, unlocked)
        cache.unlocked[k] = unlocked
    end
end

-- Hint : pilote les emetteurs de sparks
for k, emittersForStone in pairs(cache.emitters) do
    for role, emitter in pairs(emittersForStone) do
        local hinted = P.isHinted(role, k)
        if hinted ~= cache.hinted[k][role] then
            EntitySetComponentIsEnabled(entity_id, emitter, hinted)
            cache.hinted[k][role] = hinted
        end
    end
end