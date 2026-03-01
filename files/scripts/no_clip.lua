dofile_once( "data/scripts/lib/utilities.lua" )

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

NoClip = NoClip or {}

-- ─── Constantes ──────────────────────────────────────────────────────────────

NoClip.DIST         = 3
NoClip.VELOCITY_MAX = 200

local SAVED_ENTITY_PREFIX = "noclip_saved_values_"

local CP_FIELDS_PHYSICS = {
    "pixel_gravity",
    "swim_idle_buoyancy_coeff",
    "swim_down_buoyancy_coeff",
    "swim_up_buoyancy_coeff",
    "swim_drag",
    "swim_extra_horizontal_drag",
    "fly_speed_change_spd",
}

local CP_PHYSICS_VALUES = {
    pixel_gravity              = 0,
    swim_idle_buoyancy_coeff   = 0,
    swim_down_buoyancy_coeff   = 0,
    swim_up_buoyancy_coeff     = 0,
    swim_drag                  = 1,
    swim_extra_horizontal_drag = 1,
    fly_speed_change_spd       = 0,
}

local CP_FIELDS_SPEED = {
    "run_velocity",
    "fly_velocity_x",
    "fly_speed_max_up",
    "fly_speed_max_down",
    "velocity_max_x",
    "velocity_max_y",
    "velocity_min_x",
    "velocity_min_y",
}

local CP_SPEED_VALUES = {
    run_velocity       = NoClip.VELOCITY_MAX,
    fly_velocity_x     = NoClip.VELOCITY_MAX,
    fly_speed_max_up   = NoClip.VELOCITY_MAX,
    fly_speed_max_down = NoClip.VELOCITY_MAX,
    velocity_max_x     = NoClip.VELOCITY_MAX,
    velocity_max_y     = NoClip.VELOCITY_MAX,
    velocity_min_x     = -NoClip.VELOCITY_MAX,
    velocity_min_y     = -NoClip.VELOCITY_MAX,
}

--- @class NoClipOptions
--- @field override_speed  boolean  Force les champs vitesse à VELOCITY_MAX  (défaut: true)
--- @field reset_velocity  boolean  Annule mVelocity chaque frame            (défaut: true)
--- @field infinite_air    boolean  Remplit air_in_lungs chaque frame        (défaut: false)
--- @field dist            number   Distance de déplacement par frame        (défaut: NoClip.DIST)
NoClip.DEFAULT_OPTIONS = {
    override_speed = true,
    reset_velocity = true,
    infinite_air   = false,
    dist           = NoClip.DIST,
}

-- ─── Options : encodage / décodage ───────────────────────────────────────────
-- Les 3 booléens sont encodés dans un seul int :
--   bit 0 : override_speed
--   bit 1 : reset_velocity
--   bit 2 : infinite_air

local function encode_flags( opts )
    return ( opts.override_speed and 1 or 0 )
         + ( opts.reset_velocity  and 2 or 0 )
         + ( opts.infinite_air    and 4 or 0 )
end

local function decode_flags( flags )
    return {
        override_speed = math.floor( flags )      % 2 == 1,
        reset_velocity = math.floor( flags / 2  ) % 2 == 1,
        infinite_air   = math.floor( flags / 4  ) % 2 == 1,
    }
end

local function resolve_options( options )
    if not options then return NoClip.DEFAULT_OPTIONS end
    return {
        override_speed = options.override_speed ~= nil and options.override_speed or NoClip.DEFAULT_OPTIONS.override_speed,
        reset_velocity = options.reset_velocity ~= nil and options.reset_velocity or NoClip.DEFAULT_OPTIONS.reset_velocity,
        infinite_air   = options.infinite_air   ~= nil and options.infinite_air   or NoClip.DEFAULT_OPTIONS.infinite_air,
        dist           = options.dist           ~= nil and options.dist           or NoClip.DEFAULT_OPTIONS.dist,
    }
end

-- ─── Helpers privés ──────────────────────────────────────────────────────────

local function is_valid_entity( entity_id )
    return entity_id and entity_id ~= 0 and EntityGetIsAlive( entity_id )
end

local function get_saved_entity( item_id )
    local e = EntityGetWithName( SAVED_ENTITY_PREFIX .. tostring( item_id ) )
    return e ~= 0 and e or nil
end

local function get_saved_components( item_id )
    local saved = get_saved_entity( item_id )
    if not saved then return nil, nil end
    return
        EntityGetFirstComponentIncludingDisabled( saved, "CharacterPlatformingComponent" ),
        EntityGetFirstComponentIncludingDisabled( saved, "CharacterDataComponent" )
end

local function get_var_comps( item_id )
    local saved = get_saved_entity( item_id )
    if not saved then return nil, nil end
    
    local comps = EntityGetComponentIncludingDisabled(saved,"VariableStorageComponent")
    -- comps[1] = carrier + dist, comps[2] = flags booléens
    return comps[ 1 ], comps[ 2 ]
end

local function get_carrier_id( item_id )
    local carrier_comp = select( 1, get_var_comps( item_id ) )
    if not carrier_comp then
        log.error( "get_carrier_id → VariableStorageComponent introuvable" )
        return nil
    end
    return ComponentGetValue2( carrier_comp, "value_int" )
end

local function get_options( item_id )
    local carrier_comp, flags_comp = get_var_comps( item_id )
    if not carrier_comp or not flags_comp then
        log.warn( "get_options → composants introuvables, options par défaut utilisées" )
        return resolve_options( nil )
    end
    local opts = decode_flags( ComponentGetValue2( flags_comp, "value_int" ) )
    opts.dist  = ComponentGetValue2( carrier_comp, "value_float" )
    return opts
end

-- ─── API publique ─────────────────────────────────────────────────────────────

--- Sauvegarde les valeurs originales du porteur et active le no_clip.
--- @param entity_id  number         Entité porteur (joueur)
--- @param item_id    number         Entité item
--- @param options    NoClipOptions  Options de comportement (optionnel)
function NoClip.enable( entity_id, item_id, options )
    local opts = resolve_options( options )

    log.debug( "NoClip.enable → entity=" .. tostring( entity_id )
        .. " item="           .. tostring( item_id )
        .. " override_speed=" .. tostring( opts.override_speed )
        .. " reset_velocity=" .. tostring( opts.reset_velocity )
        .. " infinite_air="   .. tostring( opts.infinite_air )
        .. " dist="           .. tostring( opts.dist ) )

    if get_saved_entity( item_id ) then
        log.warn( "NoClip.enable → déjà actif pour item=" .. tostring( item_id ) .. ", abandon" )
        return
    end

    local cp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
    local cd = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterDataComponent" )

    if not cp then
        log.error( "NoClip.enable → CharacterPlatformingComponent introuvable sur entity=" .. tostring( entity_id ) )
        return
    end

    local saved    = EntityCreateNew( SAVED_ENTITY_PREFIX .. tostring( item_id ) )
    local saved_cp = EntityAddComponent2( saved, "CharacterPlatformingComponent" )
    local saved_cd = EntityAddComponent2( saved, "CharacterDataComponent" )

    -- Composant 1 : carrier_id + dist
    EntityAddComponent2( saved, "VariableStorageComponent", {
        value_int   = entity_id,
        value_float = opts.dist,
    } )
    -- Composant 2 : flags booléens encodés
    EntityAddComponent2( saved, "VariableStorageComponent", {
        value_int = encode_flags( opts ),
    } )

    EntityAddChild( item_id, saved )

    for _, field in ipairs( CP_FIELDS_PHYSICS ) do
        local value = ComponentGetValue2( cp, field )
        ComponentSetValue2( saved_cp, field, value )
        log.debug( "  sauvegarde " .. field .. " = " .. tostring( value ) )
    end

    for _, field in ipairs( CP_FIELDS_SPEED ) do
        local value = ComponentGetValue2( cp, field )
        ComponentSetValue2( saved_cp, field, value )
        log.debug( "  sauvegarde " .. field .. " = " .. tostring( value ) )
    end

    if cd then
        local vx, vy = ComponentGetValue2( cd, "mVelocity" )
        ComponentSetValue2( saved_cd, "mVelocity", vx, vy )
        log.debug( "  sauvegarde mVelocity = (" .. tostring( vx ) .. ", " .. tostring( vy ) .. ")" )
    else
        log.warn( "NoClip.enable → CharacterDataComponent introuvable, mVelocity non sauvegardée" )
    end

    log.info( "NoClip activé sur entity=" .. tostring( entity_id ) )
end

--- Applique les effets du no_clip chaque frame.
--- @param entity_id  number  Entité porteur (joueur)
--- @param item_id    number  Entité item (pour relire les options)
function NoClip.apply( entity_id, item_id )

    if not is_valid_entity( entity_id ) then
        log.warn( "NoClip.apply → entity invalide (" .. tostring( entity_id ) .. "), désactivation auto" )
        if NoClip.is_active( item_id ) then
            NoClip.disable( item_id )
        end
        return
    end


    local opts = get_options( item_id )

    local cp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
    local cd = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterDataComponent" )
    local dm = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )

    -- ─── Mode no_clip complet ─────────────────────────────────────────────────
    if not cp then
        log.error( "NoClip.apply → CharacterPlatformingComponent introuvable sur entity=" .. tostring( entity_id ) )
        return
    end

    component_read(
        EntityGetFirstComponentIncludingDisabled( entity_id, "ControlsComponent" ),
        {
            mButtonDownDown  = false,
            mButtonDownUp    = false,
            mButtonDownLeft  = false,
            mButtonDownRight = false,
        },
        function( controls )
            local x, y   = EntityGetTransform( entity_id )
            local nx, ny = x, y

            if controls.mButtonDownUp and controls.mButtonDownDown then
                if cd then ComponentSetValue2( cd, "is_on_ground", true ) end
            elseif controls.mButtonDownDown then
                ny = y + opts.dist
            elseif controls.mButtonDownUp then
                ny = y - opts.dist
            end

            if not ( controls.mButtonDownLeft and controls.mButtonDownRight ) then
                if controls.mButtonDownLeft then
                    nx = x - opts.dist
                elseif controls.mButtonDownRight then
                    nx = x + opts.dist
                end
            end

            if nx ~= x or ny ~= y then
                log.debug( "NoClip.apply → déplacement ("
                    .. tostring( x )  .. "," .. tostring( y )
                    .. ") → ("
                    .. tostring( nx ) .. "," .. tostring( ny ) .. ")" )
                EntityApplyTransform( entity_id, nx, ny )
            end
        end
    )

    for field, value in pairs( CP_PHYSICS_VALUES ) do
        ComponentSetValue2( cp, field, value )
    end

    if opts.override_speed then
        for field, value in pairs( CP_SPEED_VALUES ) do
            ComponentSetValue2( cp, field, value )
        end
    end

    if cd then
        ComponentSetValue2( cd, "mFlyingTimeLeft", ComponentGetValue2( cd, "fly_time_max" ) )
        if opts.reset_velocity then
            ComponentSetValue2( cd, "mVelocity", 0, 0 )
        end
    else
        log.warn( "NoClip.apply → CharacterDataComponent introuvable" )
    end

    if opts.infinite_air and dm then
        ComponentSetValue2( dm, "air_in_lungs", ComponentGetValue2( dm, "air_in_lungs_max" ) )
    end
end

--- Restaure les valeurs originales du porteur et nettoie la sauvegarde.
--- @param item_id  number  Entité item
function NoClip.disable( item_id )
    local entity_id = get_carrier_id( item_id )

    -- ② Sécurité : carrier_id récupéré mais entité morte/invalide → on nettoie quand même
    local entity_alive = is_valid_entity( entity_id )
    if not entity_id then
        log.error( "NoClip.disable → carrier_id introuvable pour item=" .. tostring( item_id ) )
        -- On tente quand même de tuer la sauvegarde pour ne pas laisser de fantôme
        local saved = get_saved_entity( item_id )
        if saved then EntityKill( saved ) end
        return
    end

    log.debug( "NoClip.disable → entity=" .. tostring( entity_id ) .. " item=" .. tostring( item_id ) )

    local saved = get_saved_entity( item_id )
    if not saved then
        log.warn( "NoClip.disable → aucune sauvegarde pour item=" .. tostring( item_id ) .. ", abandon" )
        return
    end

    -- On ne tente la restauration que si l'entité est encore vivante
    if entity_alive then
        local cp               = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
        local cd               = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterDataComponent" )
        local saved_cp, saved_cd = get_saved_components( item_id )

        if cp and saved_cp then
            for _, field in ipairs( CP_FIELDS_PHYSICS ) do
                local value = ComponentGetValue2( saved_cp, field )
                ComponentSetValue2( cp, field, value )
            end
            for _, field in ipairs( CP_FIELDS_SPEED ) do
                local value = ComponentGetValue2( saved_cp, field )
                ComponentSetValue2( cp, field, value )
            end
        else
            log.error( "NoClip.disable → composant(s) manquant(s) cp=" .. tostring(cp) .. " saved_cp=" .. tostring(saved_cp) )
        end

        if cd and saved_cd then
            local vx, vy = ComponentGetValue2( saved_cd, "mVelocity" )
            ComponentSetValue2( cd, "mVelocity", vx, vy )
        else
            log.warn( "NoClip.disable → CharacterDataComponent introuvable" )
        end
    else
        log.warn( "NoClip.disable → entité " .. tostring(entity_id) .. " invalide, restauration ignorée" )
    end

    EntityKill( saved )
    log.info( "NoClip désactivé sur entity=" .. tostring( entity_id ) )
end

--- Indique si le no_clip est actuellement actif pour cet item.
--- @param item_id  number
--- @return boolean
function NoClip.is_active( item_id )
    local active = get_saved_entity( item_id ) ~= nil
    log.debug( "NoClip.is_active → item=" .. tostring( item_id ) .. " → " .. tostring( active ) )
    return active
end