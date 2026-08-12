
local U = dofile_once("mods/blankStone/files/scripts/utils.lua")
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local EFFECT_TEMPLATE = "mods/blankStone/files/entities/misc/effect_generic_watchdog.xml"
local WATCHDOG_FRAMES = 30

--- @param entity_id integer
--- @param entry string  a single "EFFECT_NAME" or "EFFECT_NAME*COUNT_VAR" entry
--- @return string, integer  effect_name, count
local function parse_entry(entity_id, entry)
    local effect_name, count_var = entry:match("^([%w_]+)%*?([%w_]*)$")
    local count = 1
    if count_var and count_var ~= "" then
        local count_storage = U.getVariable(entity_id, count_var)
        count = tonumber(U.getValue(count_storage, "value_int", 1)) or 1
    end
    return effect_name, math.max(count, 0)
end

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

if entity_id ~= player_id and player_id then
    local list_var = UnlockItem.getVariable(entity_id, "watchdog_game_effect")
    local effect_list = U.getValue(list_var, "value_string", "")
    local instance_id = U.getOrCreateInstanceId(entity_id, "watchdog_instance_id")

    for entry in effect_list:gmatch("[^,]+") do
        local effect_name, count = parse_entry(entity_id, entry)

        for i = 1, count do
            effect_status.give_effect_watchdog(
                entity_id,
                player_id,
                EFFECT_TEMPLATE,
                "blankstone_watchdog_" .. instance_id .. "_" .. effect_name .. "_" .. i,
                WATCHDOG_FRAMES,
                "generic_game_effect_watchdog",
                function(effect_id)
                    -- Only known at runtime: set the real GAME_EFFECT
                    -- value on the freshly spawned helper entity.
                    local comp = EntityGetFirstComponentIncludingDisabled(effect_id, "GameEffectComponent")
                    if comp then
                        ComponentSetValue2(comp, "effect", effect_name)
                    end
                end
            )
        end
    end
end