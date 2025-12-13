local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local function getXML(entity)
    local content = ModTextFileGetContent(entity)
    return nxml.parse(content)
end

local function setXML(entity, xml)
    ModTextFileSetContent(entity, tostring(xml))
end

local function addComponent(xml, component, value_tab)
    xml:add_child(nxml.parse("<" .. component .. " " .. table.concat(
        (function()
            local t = {}
            for k, v in pairs(value_tab) do
                table.insert(t, k .. '="' .. v .. '"')
            end
            return t
        end)(),
        " "
    ) .. "/>"))
end

local function addChild(xml, component, value_tab)
    xml:add_child(nxml.parse("<Entity><" .. component .. " " .. table.concat(
        (function()
            local t = {}
            for k, v in pairs(value_tab) do
                table.insert(t, k .. '="' .. v .. '"')
            end
            return t
        end)(),
        " "
    ) .. "/></Entity>"))
end

-- Change or add a VariableStorageComponent value
local function changeOrAddValue(xml, name, new_value)
    local comps = xml:find_children("VariableStorageComponent")
    for _, comp in pairs(comps) do
        local attr_name = comp:attr("name")
        if attr_name == name then
            comp:attr("value_string", new_value)
            return
        end
    end
    -- If not found, add new component
    addComponent(xml, "VariableStorageComponent", {
        name = name,
        value_string = new_value,
    })
end

local function all_equal(t)
    if #t == 0 then return true end
    local first = t[1]
    for i = 2, #t do
        if t[i] ~= first then
            return false
        end
    end
    return true
end

return {
    getXML = getXML,
    setXML = setXML,
    addComponent = addComponent,
    addChild = addChild,
    changeOrAddValue = changeOrAddValue,
    all_equal = all_equal
}