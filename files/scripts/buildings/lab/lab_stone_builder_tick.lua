-- Exécuté à chaque frame sur le "runner" d'une reconstruction en cours (cf
-- lab_stone_io.rebuild), jusqu'à ce que toute la file de noeuds ait été
-- reconstruite et rattachée (ou que l'auto-pickup ait été posé pour la
-- racine) - alors il se tue lui-même.
--
-- Ne lit/écrit QUE des composants (jamais de table Lua) : chaque exécution
-- de LuaComponent.script_source_file a son propre état Lua isolé, une
-- variable définie dans un autre script n'est pas visible ici (cf note en
-- tête de entity_serializer.lua).

local stone_io = dofile_once("mods/blankStone/files/scripts/buildings/lab/lab_stone_io.lua")

local self_id = GetUpdatedEntityID()
stone_io.tickRunner(self_id)