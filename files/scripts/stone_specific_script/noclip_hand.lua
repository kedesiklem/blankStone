dofile_once( "mods/blankStone/files/scripts/no_clip.lua" )

local item_id   = GetUpdatedEntityID()
local entity_id = EntityGetRootEntity( item_id )
if not entity_id or entity_id == 0 then return end

NoClip.enable( entity_id, item_id, {} )

NoClip.apply( entity_id, item_id )