--- Mod Compatibility: Change vanilla stone items to be purifiable stones

local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local T = dofile_once("mods/blankStone/files/scripts/nxml_tools.lua")
local nxml = dofile_once("mods/blankStone/lib/nxml.lua")

local stone_base = "mods/blankStone/files/entities/purifiable.xml"

local function addPurifiable(path, new_parent)
    local xml = T.getXML(path)
    T.addComponent(xml, "Base", { file = new_parent })
    T.setXML(path, xml)
end

local  vanilla_item_path = "items/pickup/"
local vanilla_stone = {
    vanilla_item_path .. "sun/sunseed",
    vanilla_item_path .. "wandstone",
    vanilla_item_path .. "waterstone",
    vanilla_item_path .. "brimstone",
    vanilla_item_path .. "thunderstone",
    vanilla_item_path .. "stonestone",
    vanilla_item_path .. "poopstone",
    vanilla_item_path .. "physics_gold_orb_greed",
    vanilla_item_path .. "physics_gold_orb",
    vanilla_item_path .. "moon",

    "projectiles/deck/rock"
}


for _, value in pairs(vanilla_stone) do
    local path = "data/entities/" .. value .. ".xml"
    addPurifiable(path, stone_base)

    local stone_id = value:match("([^/]+)$")

    -- see https://github.com/NathanSnail/luanxml
    for xml in nxml.edit_file(path) do
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
        else
            log.error("blankStoneID already exists: " .. path)
        end

        -- FROM APOTHEOSIS
        -- In-inventory behavior for various items
        local gameEffect = xml:first_of("GameEffectComponent")
        if gameEffect then
            local tags = gameEffect.attr._tags or ""
            if not tags:find("enabled_in_inventory") then
                gameEffect.attr._tags = tags .. ",enabled_in_inventory"
            end
        end

        local guarded_hooks = {
            script_kick = "kick",
            script_damage_received = "damage_received",
        }
        for elem in xml:each_of("LuaComponent") do
            for field, function_name in pairs(guarded_hooks) do
                local script_path = elem:get(field)
                if script_path and script_path ~= "" then
                    local tags = elem.attr._tags or ""
                    if not tags:find("enabled_in_inventory") then
                        elem.attr._tags = tags .. ",enabled_in_inventory"
                    end
                    ModLuaFileAppend(script_path, "mods/blankStone/files/scripts/storage_stone/utils/guard_" .. function_name .. ".lua")
                    log.info("BlankStone: guarded " .. field .. " (" .. script_path .. ") on " .. path)
                end
            end
        end
    end
end

ModLuaFileAppend( "data/scripts/buildings/forge_item_convert.lua", "mods/blankStone/files/scripts/buildings/anvil_appends.lua")
ModLuaFileAppend( "data/scripts/perks/perk.lua", "mods/blankStone/files/scripts/perks/perk_appends.lua" )

--  =============================================================
--               ORB ROOM HIDDEN MESSAGES
--  =============================================================
local ORB_HOOK_TEMPLATE = [[
local spawn_orb_original = spawn_orb
function spawn_orb(x, y)
    spawn_orb_original(x, y)
    EntityLoad("mods/blankStone/files/scripts/biomes/hidden_message/orb_%NB%/orb_%NB%.xml", x, y)
end
]]

for i = 0, 11 do
    local nb = string.format("%02d", i)

    -- Path to the target orb room script for this orb number.
    local target_file = "data/scripts/biomes/orbrooms/orbroom_" .. nb .. ".lua"

    -- Bake 'nb' into a generated in-memory file (no physical file needed on disk).
    local generated_path = "mods/blankStone/files/generated/orb_append_" .. nb .. ".lua"
    local content = ORB_HOOK_TEMPLATE:gsub("%%NB%%", nb)
    ModTextFileSetContent(generated_path, content)

    -- Attach the generated hook to the target orb room script.
    ModLuaFileAppend(target_file, generated_path)
end
--  =============================================================

-- Thanks to nathansnail & userk for the edit_file advice
do -- SHOP-KEEPER STONE LOOT
    local enemies = {
    "data/entities/animals/necromancer_shop.xml",
    "data/entities/animals/necromancer_super.xml",
    }

    for _, path in pairs(enemies) do
    for xml in nxml.edit_file(path) do
        xml:add_child(nxml.new_element("LuaComponent", {
        execute_on_removed = "1",
        execute_every_n_frame = "-1",
        script_death = "mods/blankStone/files/scripts/animals/necromancer_loot.lua"
        }))
    end
    end
end

do -- ALCHEMIST LOOT
    local enemies = {
    "data/entities/animals/boss_alchemist/boss_alchemist.xml",
    }

    for _, path in pairs(enemies) do
    for xml in nxml.edit_file(path) do
        xml:add_child(nxml.new_element("LuaComponent", {
        execute_on_removed = "1",
        execute_every_n_frame = "-1",
        script_death = "mods/blankStone/files/scripts/animals/alchemist_loot.lua"
        }))
    end
    end
end

do -- DRAGON LOOT
    local enemies = {
    "data/entities/animals/boss_dragon.xml",
    }

    for _, path in pairs(enemies) do
    for xml in nxml.edit_file(path) do
        xml:add_child(nxml.new_element("LuaComponent", {
        execute_on_removed = "1",
        execute_every_n_frame = "-1",
        script_death = "mods/blankStone/files/scripts/animals/dragon_loot.lua"
        }))
    end
    end
end

do -- Player Editor
	local path = "data/entities/player_base.xml"

	for xml in nxml.edit_file(path) do
		-- Adds a Parallel World checker to the player
		xml:add_child(nxml.new_element("LuaComponent", {
			script_source_file = "mods/blankStone/files/scripts/magic/pw_enter_check.lua",
			execute_every_n_frame = "120",
			execute_times = "-1",
			remove_after_executed = "0",
		}))
	end
end
