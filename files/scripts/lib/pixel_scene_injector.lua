local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

--- @param x number
--- @param y number
--- @param file string  chemin de l'entité à charger telle quelle
--- @return string xml
local function buildEntityScene(x, y, file)
    return string.format(
        '<PixelScene pos_x="%d" pos_y="%d" just_load_an_entity="%s" />',
        x, y, file
    )
end

--- @param x number
--- @param y number
--- @param material_filename string
--- @param colors_filename string|nil
--- @param background_filename string|nil
--- @return string xml
local function buildMaterialScene(x, y, material_filename, colors_filename, background_filename)
    return string.format(
        '<PixelScene pos_x="%d" pos_y="%d" material_filename="%s" colors_filename="%s" background_filename="%s" skip_biome_checks="1" skip_edge_textures="1" clean_area_before="0" />',
        x, y, material_filename, colors_filename or "", background_filename or ""
    )
end

--- Comme buildMaterialScene, mais (center_x, center_y) désigne le CENTRE
--- souhaité de la scène plutôt que son coin haut-gauche.
--
-- material_filename ancre nativement au coin haut-gauche de l'image
-- (contrairement à just_load_an_entity qui ancre à l'origine locale de
-- l'entité, en général proche de son centre visuel) - c'est ce qui causait
-- le décalage visible entre le labo et la salle Progress au même point.
-- Cette fonction calcule le coin haut-gauche à partir du centre voulu et
-- des dimensions de l'image, pour ne plus avoir à faire ce calcul à la main
-- à chaque nouvelle image.
--- @param center_x number
--- @param center_y number
--- @param width number  largeur en pixels de material_filename
--- @param height number  hauteur en pixels de material_filename
--- @param material_filename string
--- @param colors_filename string|nil
--- @param background_filename string|nil
--- @return string xml
local function buildMaterialSceneCentered(center_x, center_y, width, height, material_filename, colors_filename, background_filename)
    local x = center_x - math.floor(width / 2)
    local y = center_y - math.floor(height / 2)
    return buildMaterialScene(x, y, material_filename, colors_filename, background_filename)
end

local MAX_TILE_SIZE = 512 -- limite dure du moteur pour un <PixelScene> material_filename

--- Comme buildMaterialSceneCentered, mais découpe automatiquement en autant
--- de tuiles material_filename/colors_filename/background_filename que
--- nécessaire dès que width ou height dépasse 512 (limite dure du moteur,
--- voir https://noita.wiki.gg/wiki/Modding:_Making_a_custom_environment#Splicing_Large_Pixel_Scenes).
--
-- Ne découpe PAS les images elles-mêmes (impossible en Lua) - il faut avoir
-- déjà exporté les tuiles séparément dans un éditeur d'image, une par
-- morceau de 512x512 maximum, nommées selon un motif contenant %d
-- (ex: "material%d.png" -> material1.png, material2.png, ...). Les tuiles
-- sont numérotées en lecture gauche->droite puis haut->bas à partir de 1.
-- Pour une scène qui tient déjà dans 512x512, une seule tuile est générée ;
-- un pattern sans %d (nom de fichier fixe) fonctionne aussi dans ce cas
-- (l'argument supplémentaire de string.format est simplement ignoré).
--- @param center_x number
--- @param center_y number
--- @param width number  largeur totale voulue de la scène complète
--- @param height number  hauteur totale voulue
--- @param material_pattern string  ex: ".../material%d.png", jamais vide
--- @param colors_pattern string|nil  même principe, "" ou nil si inutile
--- @param background_pattern string|nil  même principe
--- @return table  liste de strings XML <PixelScene .../>, une par tuile
local function buildTiledMaterialScene(center_x, center_y, width, height, material_pattern, colors_pattern, background_pattern)
    local cols = math.ceil(width / MAX_TILE_SIZE)
    local rows = math.ceil(height / MAX_TILE_SIZE)

    local origin_x = center_x - math.floor(width / 2)
    local origin_y = center_y - math.floor(height / 2)

    local entries = {}
    local tile_n = 0
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            tile_n = tile_n + 1
            local tile_x = origin_x + col * MAX_TILE_SIZE
            local tile_y = origin_y + row * MAX_TILE_SIZE

            local material_filename = string.format(material_pattern, tile_n)
            local colors_filename = (colors_pattern and colors_pattern ~= "") and string.format(colors_pattern, tile_n) or ""
            local background_filename = (background_pattern and background_pattern ~= "") and string.format(background_pattern, tile_n) or ""

            table.insert(entries, buildMaterialScene(tile_x, tile_y, material_filename, colors_filename, background_filename))
        end
    end
    return entries
end

--- Ajoute une liste de <PixelScene> déjà construits (strings XML) à
--- data/biome/_pixel_scenes.xml. Fait son propre cycle lecture -> modif ->
--- écriture complet à chaque appel : sûr à appeler plusieurs fois de suite
--- depuis des fichiers différents (chaque appel voit les écritures des
--- appels précédents), tant que les appels restent séquentiels (c'est le
--- cas ici, dofile_once dans init.lua ne parallélise rien).
--- @param entries_xml table  liste de strings XML <PixelScene .../>
local function inject(entries_xml)
    local content = ModTextFileGetContent("data/biome/_pixel_scenes.xml")
    local xml = nxml.parse(content)
    local pixel_scenes = xml:first_of("mBufferedPixelScenes")

    for _, entry_xml in ipairs(entries_xml) do
        pixel_scenes:add_child(nxml.parse(entry_xml))
    end

    ModTextFileSetContent("data/biome/_pixel_scenes.xml", tostring(xml))
end

return {
    buildEntityScene = buildEntityScene,
    buildMaterialScene = buildMaterialScene,
    buildMaterialSceneCentered = buildMaterialSceneCentered,
    buildTiledMaterialScene = buildTiledMaterialScene,
    inject = inject,
}