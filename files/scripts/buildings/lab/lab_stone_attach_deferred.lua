-- Exécuté au moins une frame après le respawn complet d'une storageStone
-- récupérée du lab (cf lab_stone_io.rebuild). Rattache les objets qu'elle
-- contient à son inventaire, PUIS SEULEMENT ALORS autorise auto_pickup - une
-- fois que le moteur a eu le temps d'initialiser chaque entité fraîchement
-- spawnée. L'ordre est important : poser auto_pickup avant le rattachement
-- risque de faire rejoindre l'objet à l'inventaire du joueur avant que ce
-- script n'ait eu la moindre chance de tourner (si les LuaComponent
-- périodiques cessent de s'exécuter une fois l'objet dans l'inventaire,
-- hypothèse retenue pour du contenu qui restait au sol, jamais rattaché).
--
-- Traite TOUT ce qui est actuellement en attente (entity_serializer.
-- processPendingAttachments), pas seulement ce qu'a marqué CETTE storageStone -
-- sans danger si plusieurs récupérations sont en vol en même temps, puisque
-- chaque objet en attente porte lui-même l'id de son propre parent.

local stone_io = dofile_once("mods/blankStone/files/scripts/lab/lab_stone_io.lua")

local self_id = GetUpdatedEntityID()

stone_io.processPendingAttachments(stone_io.attachToBag)

if self_id and self_id ~= 0 then
    stone_io.setAutoPickup(self_id)
end

-- Se retire soi-même : ne dépend pas de remove_after_executed (incertain
-- avec execute_every_n_frame), retrouve son propre LuaComponent via son tag.
if self_id and self_id ~= 0 then
    local comp = EntityGetFirstComponentIncludingDisabled(self_id, "LuaComponent", stone_io.ATTACH_SCHEDULER_TAG)
    if comp then
        EntityRemoveComponent(self_id, comp)
    end
end
