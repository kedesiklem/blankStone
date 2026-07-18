local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local effect_status = dofile_once("mods/blankStone/files/scripts/status_effects/status_effects_utils.lua")

local WATCHDOG_FRAMES = 30
local EFFECT_PATH = "mods/blankStone/files/entities/misc/effect_custom.xml"

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity(entity_id)

local damage_type_info = utils.getVariable(entity_id, "protected_damage_type")
local damage_type = utils.getValue(damage_type_info, "value_string")
local damage_mult = utils.getValue(damage_type_info, "value_float")

local new_dmg_info = utils.getVariable(entity_id, "new_mult")
local new_damage_mult = new_dmg_info and utils.getValue(new_dmg_info, "value_float") or 0

if entity_id ~= player_id then
    if damage_mult == 0 then
        local comp = EntityGetFirstComponentIncludingDisabled(player_id, "DamageModelComponent")
        if comp then
            damage_mult = ComponentObjectGetValue2(comp, "damage_multipliers", damage_type)
        else
            log.error("No DamageModelComponent found for damage_type_multiplier_stone")
        end
        utils.setValue(damage_type_info, "value_float", damage_mult)
    end

    effect_status.give_effect_watchdog(
        entity_id,
        player_id,
        EFFECT_PATH,
        "blankstone_damage_type_protection_" .. damage_type,
        WATCHDOG_FRAMES,
        "damage_type_multiplier_stone",
        function(effect_id)
            utils.setVariable(effect_id, "custom_id", "value_string", "DAMAGE_TYPE_MULTIPLIER")
            utils.setVariable(effect_id, "data", "value_string",
                utils.serializeData({ damage_type = damage_type, original_mult = damage_mult, new_mult = new_damage_mult }))
        end
    )
end