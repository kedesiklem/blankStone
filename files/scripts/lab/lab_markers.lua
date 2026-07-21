-- based on Purgatory by Priskip


local lab_factory = dofile_once("mods/blankStone/files/scripts/lab/lab_factory.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

-- Couleurs marqueurs, format 0xAARRGGBB.
-- Choisies pour ne collisionner avec aucune couleur de data/materials.xml.
local MARKERS = {
    LAB_ROOT   = { color = 0xff42ff00, spawn = lab_factory.spawnRoot },
    LAB_SLOT   = { color = 0xff42ff01, spawn = lab_factory.spawnSlot },
    LAB_TRASH  = { color = 0xff42ff02, spawn = lab_factory.spawnTrash },
    LAB_PORTAL = { color = 0xff42ff03, spawn = lab_factory.spawnPortal },
}

-- Génère "blankStone_lab_spawn_<nom sans le préfixe LAB_>" pour chaque
-- entrée (ex: LAB_ROOT -> blankStone_lab_spawn_root) et l'expose en global.
for name, marker in pairs(MARKERS) do
    local short = name:gsub("^LAB_", ""):lower()
    marker.fn_name = "blankStone_lab_spawn_" .. short

    _G[marker.fn_name] = function(x, y)
        log.debug("lab_markers: marker " .. name .. " @ " .. x .. "," .. y)
        marker.spawn(x, y)
    end
end

return { MARKERS = MARKERS }
