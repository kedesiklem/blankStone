local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local function getXML(entity)
    local content = ModTextFileGetContent(entity)
    return nxml.parse(content)
end

local function setXML(entity, xml)
    ModTextFileSetContent(entity, tostring(xml))
end

local function changeParent(xml, new_parent)
    local old_parent

    local base = xml:first_of("Base")
    if base and base.attr then
        old_parent = base.attr.file
        base.attr.file = new_parent
    else
        xml:add_child({ name = "Base", attr = { file = new_parent } })
    end

    return old_parent
end


local function changeOrAddValue(xml, name, new_value)
    local var_comp = xml:first_of("VariableStorageComponent", function(c) return c.attr.name == name end)
    if var_comp and var_comp.attr then
        for k, v in pairs(var_comp.attr) do
            if k:find("value_") == 1 then
                var_comp.attr[k] = new_value
            end
        end
    else
        xml:add_child({
            name = "VariableStorageComponent",
            attr = {
                name = name,
                value_int = new_value
            }
        })
    end
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
    changeParent = changeParent,
    changeOrAddValue = changeOrAddValue,
    all_equal = all_equal
}