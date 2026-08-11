local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

--- @param x number
--- @param y number
--- @param file string  path to the entity to load as-is
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

--- Like buildMaterialScene, but (center_x, center_y) is the desired CENTER
--- of the scene, rather than its top-left corner.
--
-- material_filename natively anchors at the top-left corner of the image
-- (unlike just_load_an_entity, which anchors at the entity's own local
-- origin, usually close to its visual center) - this is what caused the
-- visible offset between the lab and the Progress room at the same point.
-- This function computes the top-left corner from the desired center and
-- the image dimensions, so we don't have to redo that math by hand every
-- time we add a new image.
--- @param center_x number
--- @param center_y number
--- @param width number  width in pixels of material_filename
--- @param height number  height in pixels of material_filename
--- @param material_filename string
--- @param colors_filename string|nil
--- @param background_filename string|nil
--- @return string xml
local function buildMaterialSceneCentered(center_x, center_y, width, height, material_filename, colors_filename, background_filename)
    local x = center_x - math.floor(width / 2)
    local y = center_y - math.floor(height / 2)
    return buildMaterialScene(x, y, material_filename, colors_filename, background_filename)
end

local MAX_TILE_SIZE = 512 -- hard engine limit for a <PixelScene> material_filename

--- Like buildMaterialSceneCentered, but automatically splits into as many
--- material_filename/colors_filename/background_filename tiles as needed
--- as soon as width or height exceeds 512 (hard engine limit, see
--- https://noita.wiki.gg/wiki/Modding:_Making_a_custom_environment#Splicing_Large_Pixel_Scenes).
--
-- Does NOT split the images themselves (impossible in Lua) - the tiles
-- must already have been exported separately in an image editor, one per
-- chunk of at most 512x512, named following a pattern containing %d
-- (e.g. "material%d.png" -> material1.png, material2.png, ...). Tiles are
-- numbered left->right then top->bottom, starting at 1. For a scene that
-- already fits in 512x512, a single tile is generated; a pattern with no
-- %d (fixed filename) also works in that case (the extra string.format
-- argument is simply ignored).
--- @param center_x number
--- @param center_y number
--- @param width number  total desired width of the full scene
--- @param height number  total desired height
--- @param material_pattern string  e.g. ".../material%d.png", never empty
--- @param colors_pattern string|nil  same idea, "" or nil if unused
--- @param background_pattern string|nil  same idea
--- @return table  list of XML strings <PixelScene .../>, one per tile
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

--- Adds a list of already-built <PixelScene> XML strings to
--- data/biome/_pixel_scenes.xml.
--
-- Safe to call several times in a row from different files (each call
-- sees the writes from previous calls), as long as calls stay sequential
-- (which is the case here - dofile_once in init.lua doesn't parallelize
-- anything).
--- @param entries_xml table  list of XML strings <PixelScene .../>
local function inject(entries_xml)
    for xml in nxml.edit_file("data/biome/_pixel_scenes.xml") do
        local pixel_scenes = xml:first_of("mBufferedPixelScenes")
        for _, entry_xml in ipairs(entries_xml) do
            pixel_scenes:add_child(nxml.parse(entry_xml))
        end
    end
end

return {
    buildEntityScene = buildEntityScene,
    buildMaterialScene = buildMaterialScene,
    buildMaterialSceneCentered = buildMaterialSceneCentered,
    buildTiledMaterialScene = buildTiledMaterialScene,
    inject = inject,
}