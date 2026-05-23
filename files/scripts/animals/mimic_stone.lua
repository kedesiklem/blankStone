dofile_once("data/scripts/lib/utilities.lua")

function init( entity_id )
	EntityRemoveTag( entity_id, "enemy" ) -- fix bug RISKY_CRITICAL
 
	local item = EntityGetFirstComponentIncludingDisabled( entity_id, "ItemComponent" )
	if item ~= nil then
		EntitySetComponentIsEnabled( entity_id, item, false )
	end
end


function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
	local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )
	SetRandomSeed( x, y )

	local roll = Random( 1, 10 )

	if roll <= 3 then
		-- 30% : rend une blank stone
		EntityLoad( "mods/blankStone/files/entities/blank_stone.xml", x, y )

	elseif roll <= 9 then
		-- 60% : rend une magic stone
		EntityLoad( "mods/blankStone/files/entities/elemental_stone/stone_magic_liquid.xml", x, y )

	else
		-- 10% : explosion
		EntityLoad( "data/entities/projectiles/explosion.xml", x, y )
	end
end

-- correction du ciblage homing sur la mimic_stone en main
function enabled_changed( entity_id, is_enabled )

	if EntityGetParent( entity_id ) ~= NULL_ENTITY then
		EntityRemoveTag( entity_id, "homing_target" )
	else
		EntityAddTag( entity_id, "homing_target" )
	end

	if is_enabled == false then
		return
	end

	local c = EntityGetAllChildren( entity_id )
	if c ~= nil then
		for _, b in ipairs( c ) do
			EntitySetComponentsWithTagEnabled( b, "enabled_in_world", true )
		end
	end
end


-- main update
local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
SetRandomSeed( x, y )

-- ramassable si charmée
local comp = GameGetGameEffect( entity_id, "CHARM" )
if ( comp ~= nil ) and ( comp ~= NULL_ENTITY ) then
	EntitySetComponentsWithTagEnabled( entity_id, "enabled_if_charmed", true )
else
	EntitySetComponentsWithTagEnabled( entity_id, "enabled_if_charmed", false )
end

-- sons aléatoires
if Random( 1, 8 ) == 1 then
	if Random( 1, 4 ) == 1 then
		GameEntityPlaySound( entity_id, "jump" )
	else
		GameEntityPlaySound( entity_id, "damage/projectile" )
	end
end