-- based on Purgatory by Priskip

-- Injecte les labos dans data/biome/_pixel_scenes.xml, même mécanisme que
-- hint_spawn_list.lua. Deux modes possibles par entrée :
--
-- type = "scene"  : calque matériaux + marqueurs (LAB_ROOT / LAB_SLOT peints
--                    dans une image, position résolue automatiquement).
--                    Nécessite que le biome à cette position soit listé
--                    dans lab_biome_targets.lua (RegisterSpawnFunction doit
--                    s'exécuter dans le contexte d'un script de biome).
--
-- type = "direct" : root + slots chargés directement via just_load_an_entity,
--                    comme la salle "Progress" dans hint_spawn_list.lua.
--                    Positions des slots données à la main (slot_offsets),
--                    mais AUCUNE dépendance à un biome : fonctionne dans la
--                    roche dense, entre deux biomes, ou n'importe où le
--                    moteur accepte de stamper un pixel scene.
--                    À utiliser pour un spot caché fixe et unique ; pour
--                    plusieurs salles procédurales avec une vraie
--                    composition artistique, préfère "scene".

local nxml = dofile_once("mods/blankStone/lib/nxml.lua")
local content = ModTextFileGetContent("data/biome/_pixel_scenes.xml")
local xml = nxml.parse(content)

local MOD_PATH = "mods/blankStone/files/"
local BIOME_IMPL_PATH = MOD_PATH .. "biome_impl/lab/"
local ROOT_ENTITY = MOD_PATH .. "entities/lab/lab_root.xml"
local SLOT_ENTITY = MOD_PATH .. "entities/lab/lab_slot.xml"

local labs = {
    {
        type = "scene",
        pos_x = -14150, pos_y = 17300, -- roche dense, sous la Gold Room (Secret Beehive)
        material_filename  = BIOME_IMPL_PATH .. "lab_test.png",
        colors_filename     = "",
        background_filename  = "",
    },
}

local pixel_scenes = xml:first_of("mBufferedPixelScenes")

local function addPixelScene(pos_x, pos_y, just_load_an_entity)
    pixel_scenes:add_child(nxml.parse(string.format(
        '<PixelScene pos_x="%d" pos_y="%d" just_load_an_entity="%s" />',
        pos_x, pos_y, just_load_an_entity
    )))
end

local function addSceneLab(lab)
    pixel_scenes:add_child(nxml.parse(string.format(
        '<PixelScene pos_x="%d" pos_y="%d" material_filename="%s" colors_filename="%s" background_filename="%s" skip_biome_checks="1" skip_edge_textures="1" clean_area_before="0" />',
        lab.pos_x, lab.pos_y, lab.material_filename, lab.colors_filename or "", lab.background_filename or ""
    )))
end

local function addDirectLab(lab)
    addPixelScene(lab.pos_x, lab.pos_y, ROOT_ENTITY)
    for _, offset in ipairs(lab.slot_offsets) do
        addPixelScene(lab.pos_x + offset[1], lab.pos_y + offset[2], SLOT_ENTITY)
    end
end

for _, lab in ipairs(labs) do
    if lab.type == "direct" then
        addDirectLab(lab)
    elseif lab.type == "scene" then
        addSceneLab(lab)
    end
end

ModTextFileSetContent("data/biome/_pixel_scenes.xml", tostring(xml))
