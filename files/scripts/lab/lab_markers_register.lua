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
-- avec d'autres mods. En ciblant explicitement les biomes listés dans
-- lab_biome_targets.lua, on limite la réservation au strict nécessaire -
-- même logique que purgatory qui enregistre ses couleurs uniquement dans
-- son propre temple_altar_left.lua plutôt que globalement.

do
    local lab_markers = dofile_once("mods/blankStone/files/scripts/lab/lab_markers.lua")
    RegisterSpawnFunction(lab_markers.MARKERS.LAB_ROOT, "blankStone_lab_spawn_root")
    RegisterSpawnFunction(lab_markers.MARKERS.LAB_SLOT, "blankStone_lab_spawn_slot")
end
