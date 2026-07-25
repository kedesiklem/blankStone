local mod_path = "mods/blankStone/files/"
local progress_path = mod_path .. "entities/progress/"

local entity_id = GetUpdatedEntityID()
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")

local STONE_Z_INDEX = 1.3

local existing_by_file = {}
for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent") or {}) do
    existing_by_file[ComponentGetValue2(comp, "image_file")] = comp
end

local existing_emitters_by_image = {}
for _, comp in ipairs(EntityGetComponentIncludingDisabled(entity_id, "ParticleEmitterComponent") or {}) do
    local image = ComponentGetValue2(comp, "image_animation_file")
    existing_emitters_by_image[image] = comp
end

for k,_ in pairs(STONE_REGISTRY) do
    local progress_file_image = progress_path .. "stones/progress_" .. tostring(k) .. ".png"
    local hint_file_image = progress_path .. "stones/hint_" .. tostring(k) .. ".png"

    if not existing_by_file[progress_file_image] then
        local progress_comp EntityAddComponent(entity_id, "SpriteComponent", {
            image_file = progress_file_image,
            z_index = STONE_Z_INDEX,
            offset_x = 250,
            offset_y = 150,
        })
        EntitySetComponentIsEnabled(entity_id, progress_comp, false)
    end

    if not existing_emitters_by_image[hint_file_image] then
        local emitter_comp = EntityAddComponent(entity_id, "ParticleEmitterComponent", {
            emitted_material_name = "spark",
            emit_cosmetic_particles = true,
            image_animation_file = hint_file_image,
            lifetime_min = 0.5,
            lifetime_max = 1,
            render_on_grid=1,
            x_pos_offset_min = 1,
            y_pos_offset_min = 0,
            x_pos_offset_max = 1,
            y_pos_offset_max = 0,
        })
        EntitySetComponentIsEnabled(entity_id, emitter_comp, false)
        ComponentSetValue2(emitter_comp, "gravity", 0.0, 0.0)
    end
end