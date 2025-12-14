--- Mod Compatibility: Change vanilla stone items to be purifiable stones

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local T = dofile_once("mods/blankStone/files/scripts/tools.lua")

local stone_base = "mods/blankStone/files/entities/purifiable.xml"

local function addPurifiable(entity, new_parent)
    local xml = T.getXML(entity)
    T.addComponent(xml, "Base", { file = new_parent })
    T.setXML(entity, xml)
end

local  vanilla_item_path = "data/entities/items/pickup/"
local vanilla_stone = {
    "sun/sunseed",
    "wandstone",
    "waterstone",
    "brimstone",
    "thunderstone",
    "stonestone",
    "poopstone",
}

for _, value in pairs(vanilla_stone) do
    addPurifiable(vanilla_item_path .. value .. ".xml", stone_base)
end



-- FROM APOTHEOSIS
-- In-inv behavior for various items

do
  local content = ModTextFileGetContent("data/entities/items/pickup/wandstone.xml")
  local xml = nxml.parse(content)
  local attrs = xml:first_of("GameEffectComponent").attr
  attrs._tags = attrs._tags .. ",enabled_in_inventory"
  ModTextFileSetContent("data/entities/items/pickup/wandstone.xml", tostring(xml))
end

do
	local content = ModTextFileGetContent("data/entities/items/pickup/brimstone.xml")
	local xml = nxml.parse(content)
  xml.attr.tags = xml.attr.tags .. ",effect_protection"
	local attrs = xml:first_of("GameEffectComponent").attr
	attrs._tags = attrs._tags .. ",enabled_in_inventory,effect_protection"
	ModTextFileSetContent("data/entities/items/pickup/brimstone.xml", tostring(xml))
end
do
	local content = ModTextFileGetContent("data/entities/items/pickup/thunderstone.xml")
	local xml = nxml.parse(content)
  xml.attr.tags = xml.attr.tags .. ",effect_protection"
	local attrs = xml:first_of("GameEffectComponent").attr
	attrs._tags = attrs._tags .. ",enabled_in_inventory,effect_protection"
	ModTextFileSetContent("data/entities/items/pickup/thunderstone.xml", tostring(xml))
end
do
	local content = ModTextFileGetContent("data/entities/items/pickup/waterstone.xml")
	local xml = nxml.parse(content)
  xml.attr.tags = xml.attr.tags .. ",effect_protection"
	local attrs = xml:first_of("GameEffectComponent").attr
	attrs._tags = attrs._tags .. ",enabled_in_inventory,effect_protection"
	ModTextFileSetContent("data/entities/items/pickup/waterstone.xml", tostring(xml))
end
do
  local content = ModTextFileGetContent("data/entities/items/pickup/sun/sunseed.xml")
  local xml = nxml.parse(content)
  local attrs = xml:first_of("GameEffectComponent").attr
  attrs._tags = attrs._tags .. ",enabled_in_inventory"
  ModTextFileSetContent("data/entities/items/pickup/sun/sunseed.xml", tostring(xml))
end
do
	local content = ModTextFileGetContent("data/entities/items/pickup/sun/sunstone.xml")
	local xml = nxml.parse(content)
	local attrs = xml:first_of("GameEffectComponent").attr
	attrs._tags = attrs._tags .. ",enabled_in_inventory"
	ModTextFileSetContent("data/entities/items/pickup/sun/sunstone.xml", tostring(xml))
end