---@diagnostic disable: name-style-check
dofile_once("data/scripts/lib/mod_settings.lua")
dofile_once("mods/blankStone/files/scripts/storage_stone/utils/keycodes_tables.lua")

local mod_version = "1.16.5"

local mod_id = "blankStone"
local mod_prfx = mod_id .. "."
local T = {}
local D = {}
local current_language_last_frame = nil

local mod_id_hash = 0
for i = 1, #mod_id do
	local char = mod_id:sub(i, i)
	mod_id_hash = mod_id_hash + char:byte() * i
end

local gui_id = mod_id_hash * 1000
local function id()
	gui_id = gui_id + 1
	return gui_id
end

---------------------------------------------
--              Helpers
---------------------------------------------

local U = {
	whitebox = "data/debug/whitebox.png",
	empty = "data/debug/empty.png",
	offset = 0,
	max_y = 300,
	min_y = 50,
	keycodes = {},
	waiting_for_input = "",
}
do -- helpers
	function U.set_setting(setting_name, value)
		ModSettingSet(mod_prfx .. setting_name, value)
		ModSettingSetNextValue(mod_prfx .. setting_name, value, false)
	end

	function U.get_setting(setting_name)
		return ModSettingGet(mod_prfx .. setting_name)
	end

	function U.get_setting_next(setting_name)
		return ModSettingGetNextValue(mod_prfx .. setting_name)
	end

	function U.calculate_elements_offset(array, gui)
		local should_destroy = false
		if not gui then
			gui = GuiCreate()
			GuiStartFrame(gui)
			should_destroy = true
		end
		local max_width = 10
		for _, setting in ipairs(array) do
			if setting.category_id then
				local cat_max_width = U.calculate_elements_offset(setting.settings, gui)
				max_width = math.max(max_width, cat_max_width)
			end
			if setting.ui_name then
				local name_length = GuiGetTextDimensions(gui, setting.ui_name)
				max_width = math.max(max_width, name_length)
			end
		end
		if should_destroy then GuiDestroy(gui) end
		return max_width + 3
	end

	function U.set_default(all)
		for setting, value in pairs(D) do
			if U.get_setting(setting) == nil or all then U.set_setting(setting, value) end
		end
	end

	-- Builds keycodes lookup tables from InputCodes provided by keycodes_tables.lua
	function U.gather_key_codes()
		U.keycodes = {
			kb = {},
			mouse = {},
		}
		for key, value in pairs(InputCodes.Key) do
			U.keycodes.kb[tostring(value)] = string.upper(InputCodes.KeyName[key] or key)
		end
		for mouse, value in pairs(InputCodes.Mouse) do
			U.keycodes.mouse[tostring(value)] = string.upper(InputCodes.MouseName[mouse] or mouse)
		end
	end

	function U.pending_input()
		for code, _ in pairs(U.keycodes.kb) do
			if InputIsKeyJustDown(code) then return code, "kb" end
		end
		for code, _ in pairs(U.keycodes.mouse) do
			if InputIsMouseButtonJustDown(code) then return code, "mouse" end
		end
	end

	function U.reset_settings()
		local count = ModSettingGetCount()
		local setting_list = {}
		for i = 0, count do
			local setting_id = ModSettingGetAtIndex(i)
			if setting_id and setting_id:find("^blankStone%.") then
				setting_list[#setting_list + 1] = setting_id
			end
		end
		for i = 1, #setting_list do
			ModSettingRemove(setting_list[i])
		end
		U.set_default(true)
	end
end

---------------------------------------------
--            GUI Helpers
---------------------------------------------

local G = {}
do -- gui helpers
	function G.button_options(gui)
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.ForceFocusable)
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.HandleDoubleClickAsClick)
	end

	function G.yellow_if_hovered(gui, hovered)
		if hovered then GuiColorSetForNextWidget(gui, 1, 1, 0.7, 1) end
	end

	function G.button(gui, x_pos, text, color)
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
		GuiText(gui, x_pos, 0, "")
		local _, _, _, x, y = GuiGetPreviousWidgetInfo(gui)
		text = "[" .. text .. "]"
		local width, height = GuiGetTextDimensions(gui, text)
		G.button_options(gui)
		GuiImageNinePiece(gui, id(), x, y, width, height, 0)
		local clicked, _, hovered = GuiGetPreviousWidgetInfo(gui)
		if color then
			local r, g, b = unpack(color)
			GuiColorSetForNextWidget(gui, r, g, b, 1)
		end
		G.yellow_if_hovered(gui, hovered)
		GuiText(gui, x_pos, 0, text)
		return clicked
	end

	function G.on_clicks(setting_name, value, default)
		if InputIsMouseButtonJustDown(1) then U.set_setting(setting_name, value) end
		if InputIsMouseButtonJustDown(2) then
			GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
			U.set_setting(setting_name, default)
		end
	end

	function G.toggle_checkbox_boolean(gui, setting_name)
		local text = T[setting_name]
		local _, _, _, prev_x, y, prev_w = GuiGetPreviousWidgetInfo(gui)
		local x = prev_x + prev_w + 1
		local value = U.get_setting_next(setting_name)
		local offset_w = GuiGetTextDimensions(gui, text) + 8

		GuiZSetForNextWidget(gui, -1)
		G.button_options(gui)
		GuiImageNinePiece(gui, id(), x + 2, y, offset_w, 10, 10, U.empty, U.empty) -- hover box
		local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
		G.tooltip(gui, setting_name)

		GuiZSetForNextWidget(gui, 1)
		GuiImageNinePiece(gui, id(), x + 2, y + 2, 6, 6) -- check box

		GuiText(gui, 4, 0, "")
		if value then
			GuiColorSetForNextWidget(gui, 0, 0.8, 0, 1)
			GuiText(gui, 0, 0, "V")
			GuiText(gui, 0, 0, " ")
			G.yellow_if_hovered(gui, hovered)
		else
			GuiColorSetForNextWidget(gui, 0.8, 0, 0, 1)
			GuiText(gui, 0, 0, "X")
			GuiText(gui, 0, 0, " ")
			G.yellow_if_hovered(gui, hovered)
		end
		GuiText(gui, 0, 0, text)
		if hovered then G.on_clicks(setting_name, not value, D[setting_name]) end
	end

	function G.mod_setting_number(gui, setting)
		GuiLayoutBeginHorizontal(gui, 0, 0, true, 0, 0)
		GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)
		local _, _, _, x_start, y_start = GuiGetPreviousWidgetInfo(gui)
		local w = GuiGetTextDimensions(gui, setting.ui_name)
		local value = tonumber(U.get_setting_next(setting.id)) or setting.value_default
		local multiplier = setting.value_display_multiplier or 1
		local value_new =
			GuiSlider(gui, id(), U.offset - w + 6, 0, "", value, setting.value_min, setting.value_max, setting.value_default, multiplier, " ", 64)
		GuiColorSetForNextWidget(gui, 0.81, 0.81, 0.81, 1)
		local format = setting.format or ""
		GuiText(gui, 3, 0, tostring(math.floor(value * multiplier)) .. format)
		GuiLayoutEnd(gui)
		local _, _, _, x_end, _, t_w = GuiGetPreviousWidgetInfo(gui)
		GuiImageNinePiece(gui, id(), x_start, y_start, x_end - x_start + t_w, 8, 0, U.empty, U.empty)
		G.tooltip(gui, setting.id, setting.scope)
		return value, value_new
	end

	function G.tooltip(gui, setting_name, scope)
		local description = T[setting_name .. "_d"]
		local value = U.get_setting_next(setting_name)
		local value_now = U.get_setting(setting_name)

		if value ~= value_now then
			if scope == MOD_SETTING_SCOPE_RUNTIME_RESTART then
				if description then
					GuiTooltip(gui, description, "$menu_modsettings_changes_restart")
				else
					GuiTooltip(gui, "$menu_modsettings_changes_restart", "")
				end
				return
			elseif scope == MOD_SETTING_SCOPE_NEW_GAME then
				if description then
					GuiTooltip(gui, description, "$menu_modsettings_changes_worldgen")
				else
					GuiTooltip(gui, "$menu_modsettings_changes_worldgen", "")
				end
				return
			end
		end

		if description then GuiTooltip(gui, description, "") end
	end
end

---------------------------------------------
--            Settings GUI
---------------------------------------------

local S = {}
do -- Settings GUI
	function S.mod_setting_number_integer(_, gui, _, _, setting)
		local value, value_new = G.mod_setting_number(gui, setting)
		value_new = math.floor(value_new + 0.5)
		if value ~= value_new then U.set_setting(setting.id, value_new) end
	end

	function S.mod_setting_better_boolean(_, gui, _, _, setting)
		GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)
		G.tooltip(gui, setting.id)
		for _, setting_id in ipairs(setting.checkboxes) do
			GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset + 8, 0, true, 0, 0)
			GuiText(gui, 0, 0, "")
			G.toggle_checkbox_boolean(gui, setting_id)
			GuiLayoutEnd(gui)
		end
	end

	function S.get_input(_, gui, _, _, setting)
		local setting_id = setting.id
		local type_string = setting_id .. "_type"
		local input_type = tostring(U.get_setting(type_string))
		local key = (U.keycodes[input_type] and U.keycodes[input_type][tostring(U.get_setting(setting_id))]) or "hwuh?"
		local current_key = "[" .. key .. "]"

		if U.waiting_for_input == setting_id then
			current_key = GameTextGetTranslatedOrNot("$menuoptions_configurecontrols_pressakey")
			local new_key, new_type = U.pending_input()
			if new_key and new_type then
				U.set_setting(setting_id, new_key)
				U.set_setting(type_string, new_type)
				U.waiting_for_input = ""
			end
		end

		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
		GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)

		GuiLayoutBeginHorizontal(gui, U.offset, 0, true, 0, 0)
		GuiText(gui, 8, 0, "")
		local _, _, _, x, y = GuiGetPreviousWidgetInfo(gui)
		local w, h = GuiGetTextDimensions(gui, current_key)
		G.button_options(gui)
		GuiImageNinePiece(gui, id(), x, y, w, h, 0)
		local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
		if hovered then
			GuiColorSetForNextWidget(gui, 1, 1, 0.7, 1)
			GuiTooltip(gui, T[setting_id .. "_d"] or "", GameTextGetTranslatedOrNot("$menuoptions_reset_keyboard"))
			if InputIsMouseButtonJustDown(1) then U.waiting_for_input = setting_id end
			if InputIsMouseButtonJustDown(2) then
				GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
				U.set_setting(setting_id, D[setting_id])
				U.set_setting(type_string, "kb")
				U.waiting_for_input = ""
			end
		end
		GuiText(gui, 0, 0, current_key)
		GuiLayoutEnd(gui)
	end

	function S.reset_stuff(_, gui, _, _, setting)
		local fn = U[setting.id]
		if not fn then
			GuiText(gui, mod_setting_group_x_offset, 0, "ERR")
			return
		end
		if G.button(gui, mod_setting_group_x_offset, T.reset, { 1, 0.4, 0.4 }) then fn() end
	end
end

---------------------------------------------
--            Translations
---------------------------------------------

local translations = {
	["English"] = {
		-- Keybinding
		pickup_input_code = "Pickup Key",
		pickup_input_code_d = "Hotkey to pickup items into bags",
		-- Position sliders
		pos_x = "Horizontal position",
		pos_y = "Vertical position",
		alchemy_pos_x = "Alchemy horizontal position",
		alchemy_pos_y = "Alchemy vertical position",
		-- Display boolean group
		display_options = "Display options",
		show_bags_without_inventory_open = "Show bags without inventory",
		show_bags_without_inventory_open_d = "Show the bags inventory even when the inventory is not open",
		locked = "Lock inventory",
		locked_d = "When false, the bag button can be dragged to a new position",
		keep_tooltip_open = "Keep tooltip open",
		keep_tooltip_open_d = "Show the bag inventory when hovered and then keep it open",
		dropdown_style = "Dropdown navigation",
		dropdown_style_d = "Automatically change the bag displayed when hovering it",
		-- Wrap sliders
		bag_slots_inventory_wrap = "Inventory slots wrap",
		bag_slots_inventory_wrap_d = "Number of inventory slots before newline in ui",
		spells_slots_inventory_wrap = "Spells slots wrap",
		spells_slots_inventory_wrap_d = "Number of spells in wand tooltip before newline in ui",
		-- Color sliders
		bag_image_red = "Red",
		bag_image_red_d = "Red channel of the bag ui background",
		bag_image_green = "Green",
		bag_image_green_d = "Green channel of the bag ui background",
		bag_image_blue = "Blue",
		bag_image_blue_d = "Blue channel of the bag ui background",
		bag_image_alpha = "Alpha",
		bag_image_alpha_d = "Alpha channel of the bag ui background",
		-- Inventory interaction boolean group
		inventory_interaction = "Inventory interaction",
		dragging_allowed = "Dragging allowed",
		dragging_allowed_d = "Allows to drag items in the inventory bag",
		vanilla_dragging_allowed = "Vanilla interaction",
		vanilla_dragging_allowed_d = "Allows to drag items from the vanilla inventory to bags and vice versa",
		-- UI options boolean group
		inventory_ui_options = "UI options",
		only_show_bag_button_when_held = "Show button when held",
		only_show_bag_button_when_held_d = "Only show the bag button when a bag item is held",
		show_drop_all_inventory_button = "Show drop all button",
		show_drop_all_inventory_button_d = "Display the drop all inventory button at the end of the inventory UI",
		show_change_sorting_direction_button = "Show sorting button",
		show_change_sorting_direction_button_d = "Display the change sorting direction button at the end of the inventory UI",
		-- Sorting boolean group
		inventory_sorting = "Sorting",
		sorting_type = "Sort by pickup time",
		sorting_type_d = "ON: Sort by time of pickup / OFF: Sort by positions",
		sorting_order = "Ascending order",
		sorting_order_d = "ON: Newer items at end of bag / OFF: Newer items at beginning",
		-- Allowed items boolean group
		allowed_items = "Allowed items",
		allow_spells = "Allow spells",
		allow_spells_d = "Allow spells to be stored in the storage stone",
		allow_wands = "Allow wands",
		allow_wands_d = "Allow wands to be stored in the storage stone",
		allow_potions = "Allow potions",
		allow_potions_d = "Allow potions to be stored in the storage stone",
		allow_items = "Allow items",
		allow_items_d = "Allow items (evil eye, sunseed...) to be stored in the storage stone",
		allow_bags_inception = "Allow storage stone",
		allow_bags_inception_d = "Allow storage stone to be stored in storage stone",
		-- Pickup restrictions boolean group
		pickup_restrictions = "Pickup restrictions",
		allow_holy_mountain_wand_stealing = "Allow HM wand stealing",
		allow_holy_mountain_wand_stealing_d = "Allow bags to steal wands in holy mountains",
		allow_holy_mountain_spell_stealing = "Allow HM spell stealing",
		allow_holy_mountain_spell_stealing_d = "Allow bags to steal spells in holy mountains",
		allow_tower_wand_stealing = "Allow tower wand stealing",
		allow_tower_wand_stealing_d = "Allow bags to steal tower wands",
		allow_sampo_stealing = "Allow sampo pickup",
		allow_sampo_stealing_d = "Allow bags to pickup the sampo",
		-- Storage stone size sliders
		universal_storageStone_size = "Storage stone size",
		universal_storageStone_size_d = "Size of the storage stone inventory",
		upgraded_universal_storageStone_size = "Upgraded size",
		upgraded_universal_storageStone_size_d = "Size of the storage stone inventory when upgraded",
		-- Misc slider
		drop_orderly_distance = "Drop orderly distance",
		drop_orderly_distance_d = "Distance between items when using drop all in orderly fashion",
		-- Abilities boolean group
		bag_abilities_label = "Abilities",
		universal_bag_alchemy_table = "Alchemy table",
		universal_bag_alchemy_table_d = "Storage stone has the alchemy table gui available",
		-- Reset
		reset_settings = "Reset settings",
		reset = "Reset",
	},
}

local mt = {
	__index = function(t, k)
		local currentLang = GameTextGetTranslatedOrNot("$current_language")
		if not translations[currentLang] then currentLang = "English" end
		return translations[currentLang][k]
	end,
}
setmetatable(T, mt)

---------------------------------------------
--              Settings
---------------------------------------------

D = {
	-- Keybinding
	pickup_input_code = "10",
	pickup_input_code_type = "kb",
	-- Position
	pos_x = 170,
	pos_y = 54,
	alchemy_pos_x = 170,
	alchemy_pos_y = 200,
	-- Display
	show_bags_without_inventory_open = false,
	locked = false,
	keep_tooltip_open = false,
	dropdown_style = false,
	-- Wrap
	bag_slots_inventory_wrap = 8,
	spells_slots_inventory_wrap = 12,
	-- Colors
	bag_image_red = 255,
	bag_image_green = 255,
	bag_image_blue = 255,
	bag_image_alpha = 255,
	-- Inventory interaction
	dragging_allowed = true,
	vanilla_dragging_allowed = true,
	-- UI options
	only_show_bag_button_when_held = true,
	show_drop_all_inventory_button = true,
	show_change_sorting_direction_button = true,
	-- Sorting
	sorting_type = false,
	sorting_order = true,
	-- Allowed items
	allow_spells = false,
	allow_wands = false,
	allow_potions = true,
	allow_items = true,
	allow_bags_inception = true,
	-- Pickup restrictions
	allow_holy_mountain_wand_stealing = false,
	allow_holy_mountain_spell_stealing = false,
	allow_tower_wand_stealing = false,
	allow_sampo_stealing = false,
	-- Storage stone sizes
	universal_storageStone_size = 8,
	upgraded_universal_storageStone_size = 16,
	-- Misc
	drop_orderly_distance = 12,
	-- Abilities
	universal_bag_alchemy_table = false,
}

local function build_settings()
	---@type mod_settings_global
	local settings = {
		{
			category_id = "bag_keybindings",
			ui_name = "Bag Keybindings",
			foldable = true,
			_folded = true,
			settings = {
				{
					id = "pickup_input_code",
					not_setting = true,
					ui_name = T.pickup_input_code,
					value_default = D.pickup_input_code,
					ui_fn = S.get_input,
				},
			},
		},
		{
			category_id = "bag_position_inventory",
			ui_name = "Bag General",
			foldable = true,
			_folded = true,
			settings = {
				{
					id = "pos_x",
					ui_name = T.pos_x,
					value_default = D.pos_x,
					value_min = 0,
					value_max = 1000,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "pos_y",
					ui_name = T.pos_y,
					value_default = D.pos_y,
					value_min = 0,
					value_max = 1000,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "alchemy_pos_x",
					ui_name = T.alchemy_pos_x,
					value_default = D.alchemy_pos_x,
					value_min = 0,
					value_max = 1000,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "alchemy_pos_y",
					ui_name = T.alchemy_pos_y,
					value_default = D.alchemy_pos_y,
					value_min = 0,
					value_max = 1000,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					not_setting = true,
					id = "display_options",
					ui_name = T.display_options,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = { "show_bags_without_inventory_open", "locked", "keep_tooltip_open", "dropdown_style" },
				},
				{
					id = "bag_slots_inventory_wrap",
					ui_name = T.bag_slots_inventory_wrap,
					value_default = D.bag_slots_inventory_wrap,
					value_min = 1,
					value_max = 30,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "spells_slots_inventory_wrap",
					ui_name = T.spells_slots_inventory_wrap,
					value_default = D.spells_slots_inventory_wrap,
					value_min = 1,
					value_max = 30,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "bag_image_red",
					ui_name = T.bag_image_red,
					value_default = D.bag_image_red,
					value_min = 0,
					value_max = 255,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "bag_image_green",
					ui_name = T.bag_image_green,
					value_default = D.bag_image_green,
					value_min = 0,
					value_max = 255,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "bag_image_blue",
					ui_name = T.bag_image_blue,
					value_default = D.bag_image_blue,
					value_min = 0,
					value_max = 255,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "bag_image_alpha",
					ui_name = T.bag_image_alpha,
					value_default = D.bag_image_alpha,
					value_min = 0,
					value_max = 255,
					ui_fn = S.mod_setting_number_integer,
				},
			},
		},
		{
			category_id = "bag_inventory_size",
			ui_name = "Bag Inventory",
			foldable = true,
			_folded = true,
			settings = {
				{
					not_setting = true,
					id = "inventory_interaction",
					ui_name = T.inventory_interaction,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = { "dragging_allowed", "vanilla_dragging_allowed" },
				},
				{
					not_setting = true,
					id = "inventory_ui_options",
					ui_name = T.inventory_ui_options,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = { "only_show_bag_button_when_held", "show_drop_all_inventory_button", "show_change_sorting_direction_button" },
				},
				{
					not_setting = true,
					id = "inventory_sorting",
					ui_name = T.inventory_sorting,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = { "sorting_type", "sorting_order" },
				},
				{
					not_setting = true,
					id = "allowed_items",
					ui_name = T.allowed_items,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = {
						"allow_spells", "allow_wands", "allow_potions", "allow_items",
						"allow_bags_inception",
					},
				},
				{
					not_setting = true,
					id = "pickup_restrictions",
					ui_name = T.pickup_restrictions,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = {
						"allow_holy_mountain_wand_stealing", "allow_holy_mountain_spell_stealing",
						"allow_tower_wand_stealing", "allow_sampo_stealing",
					},
				},
				{
					id = "universal_storageStone_size",
					ui_name = T.universal_storageStone_size,
					value_default = D.universal_storageStone_size,
					value_min = 1,
					value_max = 32,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "upgraded_universal_storageStone_size",
					ui_name = T.upgraded_universal_storageStone_size,
					value_default = D.upgraded_universal_storageStone_size,
					value_min = 1,
					value_max = 64,
					ui_fn = S.mod_setting_number_integer,
				},
				{
					id = "drop_orderly_distance",
					ui_name = T.drop_orderly_distance,
					value_default = D.drop_orderly_distance,
					value_min = 0,
					value_max = 20,
					ui_fn = S.mod_setting_number_integer,
				},
			},
		},
		{
			category_id = "bag_abilities",
			ui_name = "Bag Abilities",
			foldable = true,
			_folded = true,
			settings = {
				{
					not_setting = true,
					id = "bag_abilities_label",
					ui_name = T.bag_abilities_label,
					ui_fn = S.mod_setting_better_boolean,
					checkboxes = { "universal_bag_alchemy_table" },
				},
			},
		},
		{
			category_id = "blankStone_version",
			ui_name = "Version: " .. mod_version,
			foldable = false,
			_folded = true,
			settings = {},
		},
		{
			category_id = "reset_settings_cat",
			ui_name = T.reset_settings,
			foldable = true,
			_folded = true,
			settings = {
				{
					id = "reset_settings",
					not_setting = true,
					ui_fn = S.reset_stuff,
				},
			},
		},
	}
	U.offset = U.calculate_elements_offset(settings)
	return settings
end

---------------------------------------------
--                Meh
---------------------------------------------

function ModSettingsUpdate(init_scope)
	if U.get_setting("pickup_input_code") == nil then U.reset_settings() end
	U.set_default(false)
	U.waiting_for_input = false
	local current_language = GameTextGetTranslatedOrNot("$current_language")
	if current_language ~= current_language_last_frame then mod_settings = build_settings() end
	current_language_last_frame = current_language
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	GuiIdPushString(gui, mod_prfx)
	gui_id = mod_id_hash * 1000
	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
	GuiIdPop(gui)
end

U.gather_key_codes()

---@type mod_settings_global
mod_settings = build_settings()