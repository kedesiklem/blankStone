local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local D = dofile_once("mods/blankStone/files/scripts/status_effects/effect_registry/custom.lua")

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local custom_info = utils.getVariable(entity_id, "custom_id")
local custom_id = utils.getValue(custom_info, "value_string")

local DEFAULT_WATCHDOG = 30

local function load_custom_effect(id, type, check)
    local effect_path = "mods/blankStone/files/entities/misc/effect_custom.xml"
    local effect_name = "blankstone_custom_" .. type

    if check then
        local children = EntityGetAllChildren(id) or {}
        for _, child_id in ipairs(children) do
            if EntityGetName(child_id) == effect_name then
                return
            end
        end
    end

    local funcs = D[type]
    local watchdog_frames = ( funcs and funcs.watchdog_frames ) or DEFAULT_WATCHDOG

    local x, y = EntityGetTransform(id)
    local effect_id = EntityLoad(effect_path, x, y)

    utils.setVariable(effect_id, "custom_id", "value_string", type)

    -- Configure la durée de vie de l'effet en fonction du watchdog
    local effect_comp = EntityGetFirstComponentIncludingDisabled(effect_id, "GameEffectComponent")
    if effect_comp then
        ComponentSetValue2(effect_comp, "frames", watchdog_frames * 2)
    end

    EntityAddChild(id, effect_id)
    EntitySetName(effect_id, effect_name)

    -- Configure l'intervalle de vérification de la pierre elle-même
    local lua_comps = EntityGetComponentIncludingDisabled(entity_id, "LuaComponent") or {}
    for _, lc in ipairs(lua_comps) do
        local src = ComponentGetValue2(lc, "script_source_file")
        if src and src:find("custom_effect_stone") then
            ComponentSetValue2(lc, "execute_every_n_frame", watchdog_frames)
            ComponentSetValue2(lc, "mNextExecutionTime", GameGetFrameNum() + watchdog_frames)
            break
        end
    end
end

if entity_id ~= player_id then
    load_custom_effect(player_id, custom_id, true)
end