---@param player_id number
---@param effect_path string
---@param effect_name string
---@param check bool?
---@return nil
local function give_effect(player_id, effect_path, effect_name, check)
    if check then
        local children = EntityGetAllChildren(player_id) or {}

        for _, child_id in ipairs(children) do
            local name = EntityGetName(child_id)
            if name == effect_name then
                return
            end
        end
    end

    local x, y = EntityGetTransform(player_id)
    local effect_id = EntityLoad(effect_path, x, y)
    EntityAddChild(player_id, effect_id)
    EntitySetName(effect_id, effect_name)
end

---@param stone_id number         l'entité pierre en cours d'exécution (GetUpdatedEntityID())
---@param target_id number        l'entité cible (généralement le joueur)
---@param effect_path string      chemin de l'entité-effet à charger
---@param effect_name string      nom unique de l'enfant (à l'appelant de choisir : par type -> pas de stack, par stone_id -> stack)
---@param watchdog_frames number  intervalle de rafraîchissement souhaité
---@param stone_script_hint string  sous-chaîne du script_source_file de la pierre à retrouver
---@param configure_effect function|nil  callback(effect_id), appelé uniquement à la création
---@return number|nil effect_id
local function give_effect_watchdog(stone_id, target_id, effect_path, effect_name, watchdog_frames, stone_script_hint, configure_effect)
    if not target_id or not EntityGetIsAlive(target_id) then return nil end

    local children = EntityGetAllChildren(target_id) or {}
    for _, child_id in ipairs(children) do
        if EntityGetName(child_id) == effect_name then
            local effect_comp = EntityGetFirstComponentIncludingDisabled(child_id, "GameEffectComponent")
            if effect_comp then
                ComponentSetValue2(effect_comp, "frames", watchdog_frames * 2)
            end
            return child_id
        end
    end

    -- reste inchangé : création si absent
    local x, y = EntityGetTransform(target_id)
    local effect_id = EntityLoad(effect_path, x, y)

    local effect_comp = EntityGetFirstComponentIncludingDisabled(effect_id, "GameEffectComponent")
    if effect_comp then
        ComponentSetValue2(effect_comp, "frames", watchdog_frames * 2)
    end

    if configure_effect then
        configure_effect(effect_id)
    end

    EntityAddChild(target_id, effect_id)
    EntitySetName(effect_id, effect_name)

    local lua_comps = EntityGetComponentIncludingDisabled(stone_id, "LuaComponent") or {}
    for _, lc in ipairs(lua_comps) do
        local src = ComponentGetValue2(lc, "script_source_file")
        if src and stone_script_hint and src:find(stone_script_hint) then
            ComponentSetValue2(lc, "execute_every_n_frame", watchdog_frames)
            ComponentSetValue2(lc, "mNextExecutionTime", GameGetFrameNum() + watchdog_frames)
            break
        end
    end

    return effect_id
end

return {
    give_effect = give_effect,
    give_effect_watchdog = give_effect_watchdog,
}