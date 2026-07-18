-- based on Purgatory by Priskip

-- Liste explicite des scripts de biome vanilla dans lesquels le système lab
-- enregistre ses marqueurs. Un labo ne peut apparaître QUE dans un biome
-- listé ici - choix délibéré : enregistrer dans le fichier global
-- data/scripts/biome_scripts.lua rendrait nos couleurs actives dans TOUS
-- les biomes en permanence (mauvaise pratique de compatibilité, cf. doc
-- Noita sur RegisterSpawnFunction). En listant explicitement, on ne réserve
-- ces couleurs que là où on en a réellement besoin.
--
-- Pour placer un labo dans un nouveau biome : ajoute son fichier ici ET une
-- entrée avec des coordonnées dans ce biome dans lab_spawn_list.lua.
-- Référence des noms de fichiers de biome vanilla :
-- https://noita.wiki.gg/wiki/Modding:_Making_a_custom_environment

return {

    "data/scripts/biomes/hills.lua", -- lua_script réel du biome solid_wall (confirmé via data/biome/solid_wall.xml,
                                      -- <Topology lua_script="data/scripts/biomes/hills.lua">) : la roche dense
                                      -- réutilise le script du biome "hills" plutôt que d'en avoir un dédié.
                                      
    -- ATTENTION : ce biome couvre TOUTES les zones de roche dense de la
    -- carte, pas juste ce spot précis (le fichier de biome est partagé par
    -- tous les murs solides du jeu). Nos marqueurs sont donc réservés dans
    -- toute la roche dense, ce qui reste un scope raisonnable (peu de
    -- contenu y est normalement placé par d'autres mods).
}