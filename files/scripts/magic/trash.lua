local trash = GetUpdatedEntityID()
local mscs = EntityGetComponentIncludingDisabled(trash, "MaterialSuckerComponent")

if mscs then
    for _, msc in ipairs(mscs) do
        ComponentSetValue2(msc, "mAmountUsed", 0)
    end
end