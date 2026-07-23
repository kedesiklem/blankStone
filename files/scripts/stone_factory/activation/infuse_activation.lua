local C = dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry.lua")
local HINT_REGISTRY   = dofile_once("mods/blankStone/files/scripts/stone_factory/hint_registry.lua")
local log             = dofile_once("mods/blankStone/utils/logger.lua")
local INFUSE_REGISTRY = C.STONE_TO_MATERIAL_TO_STONE
--- Résout un couple (stone_id, material) depuis les registres d'infusion.
---
--- @param stone_id string   Identifiant de la pierre (blankStoneID ou EntityName)
--- @param material string   Nom du matériau Noita
---
--- @return nil
---   Aucun match dans le registre.
---
--- @return table { type = "hint", data = { message = string }, key = string }
---   Un hint doit être affiché. `data` peut être nil si la clé est introuvable
---   dans HINT_REGISTRY (cas d'erreur de configuration).
---
--- @return table { type = "recipe", stone_keys = { string, ... } }
---   Un craft est à exécuter.
local function resolve(stone_id, material)
    local stone_map = INFUSE_REGISTRY[stone_id]
    if not stone_map then return nil end

    local entry = stone_map[material]
    if not entry then return nil end

    if entry.hint_key then
        local hint_data = HINT_REGISTRY[entry.hint_key]
        if not hint_data then
            log.warn("infuse_activation: clé hint introuvable -> " .. entry.hint_key)
        end
        return { type = "hint", data = hint_data, key = entry.hint_key }
    end

    if not entry.stone_keys then
        log.warn("infuse_activation: entrée sans stone_keys ni hint_key pour stone="
            .. tostring(stone_id) .. " material=" .. tostring(material))
        return nil
    end

    return { type = "recipe", stone_keys = entry.stone_keys }
end

return { resolve = resolve }
