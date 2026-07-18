-- based on Purgatory by Priskip

local lab_factory = dofile_once("mods/blankStone/files/scripts/lab/lab_factory.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

-- Couleurs marqueurs, format 0xAARRGGBB.
-- Choisies pour ne collisionner avec aucune couleur de data/materials.xml.
-- Centralisées ici : c'est le seul endroit à vérifier en cas de conflit avec
-- un autre mod ou un futur ajout de marqueur.
local MARKERS = {
    LAB_ROOT = 0xff42ff00,
    LAB_SLOT = 0xff42ff01,
}

--- Marqueur "racine du labo". Un seul par scène.
--- @param x number position monde résolue automatiquement par le moteur
--- @param y number
function blankStone_lab_spawn_root(x, y)
    log.debug("lab_markers: marker LAB_ROOT @ " .. x .. "," .. y)
    lab_factory.spawnRoot(x, y)
end

--- Marqueur "emplacement de stockage". Autant que voulu par scène ;
--- l'index (slot 0, 1, 2...) est assigné automatiquement à la restauration
--- en triant les slots trouvés par position (lecture haut-bas, gauche-droite).
--- @param x number
--- @param y number
function blankStone_lab_spawn_slot(x, y)
    log.debug("lab_markers: marker LAB_SLOT @ " .. x .. "," .. y)
    lab_factory.spawnSlot(x, y)
end

return { MARKERS = MARKERS }
