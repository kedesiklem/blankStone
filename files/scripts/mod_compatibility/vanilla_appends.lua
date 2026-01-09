--- Mod Compatibility: Change vanilla stone items to be purifiable stones

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local T = dofile_once("mods/blankStone/files/scripts/nxml_tools.lua")
local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

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

    -- FROM APOTHEOSIS
    -- In-inv behavior for various items
    local content = ModTextFileGetContent(vanilla_item_path .. value .. ".xml")
    local xml = nxml.parse(content)
    local gameEffect = xml:first_of("GameEffectComponent")
    if gameEffect then
        local attrs = gameEffect.attr
        attrs._tags = attrs._tags .. ",enabled_in_inventory"
        ModTextFileSetContent(vanilla_item_path .. value .. ".xml", tostring(xml))
    end
end

ModLuaFileAppend( "data/scripts/buildings/forge_item_convert.lua", "mods/blankStone/files/scripts/buildings/anvil_appends.lua")

-- SHOP-KEEPER STONE LOOT

local enemies = {
  "data/entities/animals/necromancer_shop.xml",
  "data/entities/animals/necromancer_super.xml",
}

for _, path in pairs(enemies) do
  local content = ModTextFileGetContent(path)
  local xml = nxml.parse(content)

  xml:add_child(nxml.new_element("LuaComponent", {
    execute_on_removed = "1",
    execute_every_n_frame = "-1",
    script_death = "mods/blankStone/files/scripts/necromancer_loot.lua"
  }))

  ModTextFileSetContent(path, tostring(xml))
end