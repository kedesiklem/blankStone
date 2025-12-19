local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

local function getVariable(entity_id, variable_name)

    local variables = EntityGetComponent( entity_id,"VariableStorageComponent")

    if ( not variables ) then
        return nil
    end

    for i,v in ipairs(variables) do
        local name = ComponentGetValue2( v, "name" )
        if ( name == variable_name ) then
            return v
        end
    end
end

local function setVariable(entity_id, variable_name, value_type, value)
    local variable = getVariable(entity_id, variable_name)
    if(not variable) then
        log.debug("No variable name " .. variable_name .. "found")
        return
    end
    ComponentSetValue2(variable, value_type, value)
end

--- Variable Manipulation function
local function setValue(component, name, value)
    if component ~= nil then
        ComponentSetValue2(component, name, value)
    end
end

local function getValue(component, name, default)
    if component ~= nil then
        return ComponentGetValue2(component, name)
    end
    return default
end

return {
    getVariable = getVariable,
    setVariable = setVariable,
    setValue = setValue,
    getValue = getValue,
}