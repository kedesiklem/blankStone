local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger


local function MergeTable(base, patch, _depth)
    _depth = _depth or 0
    local indent = string.rep("  ", _depth)

    for k, v in pairs(patch) do
        local base_type = type(base[k])
        local patch_type = type(v)

        if patch_type == "table" then
            if base_type ~= "table" then
                log.debug(indent .. "[" .. tostring(k) .. "] base=" .. base_type .. " → création table vide")
                base[k] = {}
            else
                log.debug(indent .. "[" .. tostring(k) .. "] fusion récursive (profondeur " .. _depth .. ")")
            end
            MergeTable(base[k], v, _depth + 1)
        else
            log.debug(indent .. "[" .. tostring(k) .. "] " .. base_type .. " → " .. patch_type .. " : " .. tostring(base[k]) .. " → " .. tostring(v))
            base[k] = v
        end
    end

    return base
end

local function isAnyEnabled(mod_ids)
    for _,id in ipairs(mod_ids) do
        if ModIsEnabled(id) then return true end
    end
    return false
end

return {
    MergeTable =  MergeTable,
    isAnyEnabled =  isAnyEnabled
}