local MOD_PATH = "mods/blankStone/files/"

local U   = dofile_once(MOD_PATH .. "scripts/utils.lua")
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local TARGET_ID_VAR = "hidden_message_target_id"

local root_id = GetUpdatedEntityID()

local item = U.getActiveItem(U.getPlayer())
local held_id = item and U.getEntityIdentifier(item) or nil

local children = EntityGetAllChildren(root_id) or {}

local function isTarget(target_list, held_id)
    if not held_id or held_id == "" then
        return false
    end

    for candidate in target_list:gmatch("[^,]+") do
        -- Trim leading/trailing whitespace, in case the list has spaces after commas.
        candidate = candidate:match("^%s*(.-)%s*$")
        if candidate == held_id then
            return true
        end
    end

    return false
end

for _, child_id in ipairs(children) do
    local target_var = U.getVariable(child_id, TARGET_ID_VAR)
    local target_id = U.getValue(target_var, "value_string")

    if not target_id then
        log.error("hidden_message: no VariableStorageComponent '" .. TARGET_ID_VAR .. "' found on child entity " .. tostring(child_id))
    else
        local should_be_active = held_id ~= nil and isTarget(target_id, held_id)

        for _, comp in ipairs(EntityGetComponentIncludingDisabled(child_id, "ParticleEmitterComponent") or {}) do
            EntitySetComponentIsEnabled(child_id, comp, should_be_active)
        end
    end
end