local function spawn_leggy( entity_item )
	local x, y = EntityGetTransform( entity_item )
	EntityLoad( "data/entities/particles/polymorph_explosion.xml", x, y )
	GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/polymorph/create", x, y )
	EntityLoad( "mods/blankStone/files/entities/mimic_stone.xml", x, y )
	EntityKill( entity_item )
end

function item_pickup( entity_item, entity_who_picked, name )
	spawn_leggy( entity_item )
end

function physics_body_modified( is_destroyed )
	local entity_item = GetUpdatedEntityID()
	spawn_leggy( entity_item )
end

function collision_trigger( colliding_entity_id )
	local entity_item = GetUpdatedEntityID()
	spawn_leggy( entity_item )
end