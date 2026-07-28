-- Exécuté 1 frame après entity_serializer.deserializeAsync(), sur l'entité
-- sentinelle créée par cet appel (cf entity_serializer.lua). Retrouve
-- l'entité reconstruite par le polymorph et notifie l'appelant d'origine.

local entity_serializer = dofile_once("mods/blankStone/files/scripts/lib/entity_serializer.lua")

local self_id = GetUpdatedEntityID()
entity_serializer.resolvePending(self_id)
