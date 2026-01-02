dofile_once("data/scripts/lib/utilities.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local stone_factory = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_factory.lua")
local craft = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")

local distance_full = 150

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )


function calculate_force_at(body_x, body_y)
	local distance = math.sqrt( ( x - body_x ) ^ 2 + ( y - body_y ) ^ 2 )
	local direction = 0 - math.atan2( ( y - body_y ), ( x - body_x ) )

	local gravity_percent = ( distance_full - distance ) / distance_full
	local gravity_coeff = 196
	
	local fx = math.cos( direction ) * ( gravity_coeff * gravity_percent )
	local fy = -math.sin( direction ) * ( gravity_coeff * gravity_percent )

    return fx,fy
end

-- force field for physics bodies
function calculate_force_for_body( entity, body_mass, body_x, body_y, body_vel_x, body_vel_y, body_vel_angular )
	local fx, fy = calculate_force_at(body_x, body_y)

	fx = fx * 0.2 * body_mass
	fy = fy * 0.2 * body_mass

    return body_x,body_y,fx,fy,0 -- forcePosX,forcePosY,forceX,forceY,forceAngular
end
local size = distance_full * 0.5


PhysicsApplyForceOnArea( calculate_force_for_body, entity_id, x-size, y-size, x+size, y+size )


-- Fonction principale à appeler
local function fuseCrafting()
    return stone_factory.genericCraft(x, y, craft.FUSE_RECIPIES)
end

if(fuseCrafting()) then
	EntityKill(entity_id)
end