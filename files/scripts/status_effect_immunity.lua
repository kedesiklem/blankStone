local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function remove_effect()
    local entity_id = GetUpdatedEntityID()
    local player_id = EntityGetRootEntity(entity_id)

    local variables = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    if variables == nil then return end

    local immune_effects = {}
    for _, v in ipairs(variables) do
        if ComponentGetValue2(v, "name") == "status_effect_immunity" then
            for effect in ComponentGetValue2(v, "value_string"):gmatch("[^,]+") do
                immune_effects[effect] = true
            end
        end
    end

    if next(immune_effects) == nil then return end

    -- Based on spell_lab_shuggled
    for _, child_id in ipairs(EntityGetAllChildren(player_id) or {}) do
        local effect_comp = EntityGetFirstComponentIncludingDisabled(child_id, "GameEffectComponent")
        if not effect_comp then goto continue end

        local game_effect_id = ComponentGetValue2(effect_comp, "effect")
        if not immune_effects[game_effect_id] then goto continue end

        log.debug("Grant \"" .. game_effect_id .. "\" (status) immunity")
        ComponentSetValue2(effect_comp, "disable_movement", false)
        if ComponentGetValue2(effect_comp, "frames") > 1 then
            ComponentSetValue2(effect_comp, "frames", 1)
        end
        ::continue::
    end
end

remove_effect()