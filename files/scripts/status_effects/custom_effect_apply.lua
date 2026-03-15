local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local D     = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

local entity_id = GetUpdatedEntityID()
local target    = EntityGetRootEntity( entity_id )
if target == 0 then return end

local custom_id = utils.getValue( utils.getVariable( entity_id, "custom_id" ), "value_string" )
if not custom_id then return end

local funcs = D[ custom_id ]
if funcs and funcs.func_apply then
    funcs.func_apply( target )
end