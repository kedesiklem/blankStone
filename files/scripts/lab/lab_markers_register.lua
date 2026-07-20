-- based on Purgatory by Priskip
--
-- CE FICHIER N'EST JAMAIS dofile/dofile_once DIRECTEMENT.
-- Il est injecté à la fin de CHAQUE biome listé dans lab_biome_targets.lua
-- via ModLuaFileAppend (voir init.lua), pour que RegisterSpawnFunction
-- s'exécute DANS le contexte d'exécution du script de biome. C'est
-- obligatoire : appelé depuis n'importe où ailleurs (par exemple un simple
-- dofile_once dans init.lua), le moteur renvoie l'erreur
-- "couldn't find BiomeSpawnScript for us... no color registered".
--
-- Volontairement PAS injecté dans data/scripts/biome_scripts.lua (le
-- fichier "global" de Noita) : ça rendrait nos couleurs marqueurs actives
-- dans absolument tous les biomes du jeu en permanence, ce qui réserve
-- inutilement ce namespace de couleurs et augmente le risque de collision
-- avec d'autres mods.
--
-- Générique : boucle sur tout ce qui est déclaré dans lab_markers.lua,
-- n'a plus besoin d'être modifié quand tu ajoutes un marqueur.

do
    local lab_markers = dofile_once("mods/blankStone/files/scripts/lab/lab_markers.lua")
    for _, marker in pairs(lab_markers.MARKERS) do
        RegisterSpawnFunction(marker.color, marker.fn_name)
    end
end
