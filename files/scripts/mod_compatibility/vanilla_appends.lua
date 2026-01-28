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
    "physics_gold_orb_greed",
    "physics_gold_orb",
}


for _, value in pairs(vanilla_stone) do
    local path = vanilla_item_path .. value .. ".xml"
    addPurifiable(path, stone_base)

    local content = ModTextFileGetContent(path)
    local xml = nxml.parse(content)
    local modified = false

    local stone_id = value:match("([^/]+)$")

    -- VariableStorageComponent blankStoneID
    local existing = nil
    for elem in xml:each_of("VariableStorageComponent") do
        if elem:get("name") == "blankStoneID" then
            existing = elem
            break
        end
    end

    if not existing then
        xml:add_child(nxml.new_element("VariableStorageComponent", {
            name = "blankStoneID",
            value_string = stone_id,
        }))
        modified = true
    else
        log.error("blankStoneID already exists: " .. path)
    end

    -- FROM APOTHEOSIS
    -- In-inv behavior for various items
    local gameEffect = xml:first_of("GameEffectComponent")
    if gameEffect then
        gameEffect.attr._tags = gameEffect.attr._tags .. ",enabled_in_inventory"
        modified = true
    end

    if modified then
        ModTextFileSetContent(path, tostring(xml))
    end
end

ModLuaFileAppend( "data/scripts/buildings/forge_item_convert.lua", "mods/blankStone/files/scripts/buildings/anvil_appends.lua")


-- SHOP-KEEPER STONE LOOT
-- Thanks to nathansnail & userk for the edit_file advice
local enemies = {
  "data/entities/animals/necromancer_shop.xml",
  "data/entities/animals/necromancer_super.xml",
}

for _, path in pairs(enemies) do
  for xml in nxml.edit_file(path) do
    xml:add_child(nxml.new_element("LuaComponent", {
      execute_on_removed = "1",
      execute_every_n_frame = "-1",
      script_death = "mods/blankStone/files/scripts/necromancer_loot.lua"
    }))
  end
end