dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/debug/keycodes.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local SAVED_NAME = "blankstone_flight_overwritten_values"
local SPEED_NORMAL = 100
local SPEED_FAST   = 200

local FIELDS_DYNAMIC = {
    "run_velocity",
    "fly_velocity_x",
    "fly_speed_max_up",
    "fly_speed_max_down",
    "velocity_max_x",
    "velocity_max_y",
}

local FIELDS_FIXED = {
    velocity_min_x             = -SPEED_NORMAL,
    velocity_min_y             = -SPEED_NORMAL,
    pixel_gravity              = 0,
    swim_idle_buoyancy_coeff   = 0,
    swim_down_buoyancy_coeff   = 0,
    swim_up_buoyancy_coeff     = 0,
    fly_speed_change_spd       = 0,
    swim_drag                  = 1,
    swim_extra_horizontal_drag = 1,
}

local function save_and_set( entity_id )
    if EntityGetWithName( SAVED_NAME ) ~= 0 then
        log.warn( "CREATIVE_FLIGHT.func → sauvegarde déjà présente, abandon" )
        return
    end

    local cp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
    if not cp then
        log.error( "CREATIVE_FLIGHT.func → CharacterPlatformingComponent introuvable" )
        return
    end

    local saved    = EntityCreateNew( SAVED_NAME )
    local saved_cp = EntityAddComponent2( saved, "CharacterPlatformingComponent" )
    EntityAddChild( entity_id, saved )

    for _, field in ipairs( FIELDS_DYNAMIC ) do
        ComponentSetValue2( saved_cp, field, ComponentGetValue2( cp, field ) )
        ComponentSetValue2( cp, field, SPEED_NORMAL )
    end
    for field, value in pairs( FIELDS_FIXED ) do
        ComponentSetValue2( saved_cp, field, ComponentGetValue2( cp, field ) )
        ComponentSetValue2( cp, field, value )
    end

    log.info( "CREATIVE_FLIGHT activé sur entity=" .. tostring( entity_id ) )
end

local function restore( entity_id )
    local saved = EntityGetWithName( SAVED_NAME )
    if saved == 0 then
        log.warn( "CREATIVE_FLIGHT.func_remove → aucune sauvegarde trouvée" )
        return
    end

    local cp       = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
    local saved_cp = EntityGetFirstComponentIncludingDisabled( saved, "CharacterPlatformingComponent" )

    if cp and saved_cp then
        for _, field in ipairs( FIELDS_DYNAMIC ) do
            local v = ComponentGetValue2( saved_cp, field )
            if v ~= nil and v > 0 then
                ComponentSetValue2( cp, field, v )
            else
                log.warn( "CREATIVE_FLIGHT restore valeur suspecte " .. field .. "=" .. tostring(v) .. ", ignorée" )
            end
        end
        for field, _ in pairs( FIELDS_FIXED ) do
            ComponentSetValue2( cp, field, ComponentGetValue2( saved_cp, field ) )
        end
    else
        log.error( "CREATIVE_FLIGHT.func_remove → composant(s) manquant(s)" )
    end

    EntityKill( saved )
    log.info( "CREATIVE_FLIGHT désactivé sur entity=" .. tostring( entity_id ) )
end

local function apply( entity_id )
    local cp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
    local cd = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterDataComponent" )

    -- Vitesses réécrites chaque frame uniquement si l'effet est actif
    -- (évite d'écraser les valeurs restaurées par func_remove pendant le délai watchdog)
    if cp and EntityGetWithName( SAVED_NAME ) ~= 0 then
        for _, field in ipairs( FIELDS_DYNAMIC ) do
            ComponentSetValue2( cp, field, SPEED_NORMAL )
        end
    end

    -- Le reste tourne toujours : le mouvement ne doit jamais être interrompu
    if cd then
        ComponentSetValue2( cd, "mFlyingTimeLeft", ComponentGetValue2( cd, "fly_time_max" ) )
    end

    component_read(
        EntityGetFirstComponentIncludingDisabled( entity_id, "ControlsComponent" ),
        { mButtonDownDown = false, mButtonDownUp = false, mButtonDownLeft = false, mButtonDownRight = false },
        function( controls )
            local x, y = EntityGetTransform( entity_id )
            local shift = InputIsKeyDown( Key_LSHIFT ) or InputIsKeyDown( Key_RSHIFT )
            local dist  = ( shift and SPEED_FAST or SPEED_NORMAL ) / 60

            if controls.mButtonDownUp and controls.mButtonDownDown then
                if cd then ComponentSetValue2( cd, "is_on_ground", true ) end
            elseif controls.mButtonDownDown then
                y = y + dist
            elseif controls.mButtonDownUp then
                y = y - dist
            end

            if not ( controls.mButtonDownLeft and controls.mButtonDownRight ) then
                if controls.mButtonDownLeft  then x = x - dist end
                if controls.mButtonDownRight then x = x + dist end
            end

            EntityApplyTransform( entity_id, x, y )
        end
    )

    -- Reset après le transform : évite que la vélocité de correction
    -- calculée par le moteur ne s'applique à la frame suivante
    if cd then
        ComponentSetValue2( cd, "mVelocity", 0, 0 )
    end
end

return {
    watchdog_frames = 10,
    func            = save_and_set,
    func_remove     = restore,
    func_apply      = apply,
}