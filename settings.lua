---@diagnostic disable: name-style-check
dofile_once("data/scripts/lib/mod_settings.lua")

local mod_id   = "blankStone"
local mod_prfx = mod_id .. "."

local mod_id_hash = 0
for i = 1, #mod_id do
    mod_id_hash = mod_id_hash + mod_id:sub(i, i):byte() * i
end
local gui_id = mod_id_hash * 1000
local function id()
    gui_id = gui_id + 1
    return gui_id
end

-- =============================================================================
-- DEFAULTS
-- =============================================================================

local D = {
    storage_pickup_key      = "10",  -- G
    storage_pickup_key_type = "kb",

    -- Position du panneau StorageStone.
    -- Augmente panel_x pour décaler vers la droite si les baguettes chevauchent.
    -- Les positions vanilla (UI_BARS_POS_X/Y) sont lues depuis MagicNumbers
    -- automatiquement — aucun setting nécessaire.
    panel_x = 187,
    panel_y = 45,
}

-- =============================================================================
-- U — Utilitaires
-- =============================================================================

local U = {
    keycodes          = {},
    keycodes_file     = "data/scripts/debug/keycodes.lua",
    waiting_for_input = "",
    offset            = 0,
}

function U.set_setting(name, value)
    ModSettingSet(mod_prfx .. name, value)
    ModSettingSetNextValue(mod_prfx .. name, value, false)
end

function U.get_setting(name)
    return ModSettingGet(mod_prfx .. name)
end

function U.set_default(all)
    for setting, value in pairs(D) do
        if U.get_setting(setting) == nil or all then
            U.set_setting(setting, value)
        end
    end
end

function U.gather_key_codes()
    U.keycodes = { kb = {}, mouse = {} }
    local content = ModTextFileGetContent(U.keycodes_file)
    for line in content:gmatch("Key_.-\n") do
        local _, key, code = line:match("(Key_)(.+) = (%d+)")
        if key and code then U.keycodes.kb[code] = key:upper() end
    end
    for line in content:gmatch("Mouse_.-\n") do
        local _, key, code = line:match("(Mouse_)(.+) = (%d+)")
        if key and code then U.keycodes.mouse[code] = key:upper() end
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

function U.calculate_elements_offset(array, gui)
    if not gui then
        gui = GuiCreate()
        GuiStartFrame(gui)
    end
    local max_width = 10
    for _, setting in ipairs(array) do
        if setting.category_id then
            local w = U.calculate_elements_offset(setting.settings, gui)
            max_width = math.max(max_width, w)
        end
        if setting.ui_name and setting.ui_name ~= "" then
            local w = GuiGetTextDimensions(gui, setting.ui_name)
            max_width = math.max(max_width, w)
        end
    end
    GuiDestroy(gui)
    return max_width + 3
end

-- =============================================================================
-- G — GUI helpers
-- =============================================================================

local G = {}

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

-- =============================================================================
-- Reset functions
-- =============================================================================

function U.reset_storage_key()
    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
    U.set_setting("storage_pickup_key", D.storage_pickup_key)
    U.set_setting("storage_pickup_key_type", D.storage_pickup_key_type)
    U.waiting_for_input = ""
end

function U.reset_panel_pos()
    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
    U.set_setting("panel_x", D.panel_x)
    U.set_setting("panel_y", D.panel_y)
end

-- =============================================================================
-- S — Widgets custom
-- =============================================================================

local S = {}

function S.get_input(_, gui, _, _, setting)
    local setting_id  = setting.id
    local type_string = setting_id .. "_type"
    local input_type  = tostring(U.get_setting(type_string))
    local key         = U.keycodes[input_type]
                        and U.keycodes[input_type][tostring(U.get_setting(setting_id))] or "?"
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
        GuiTooltip(gui, setting.ui_description or "", "")
        if InputIsMouseButtonJustDown(1) then U.waiting_for_input = setting_id end
    end
    GuiText(gui, 0, 0, current_key)
    GuiLayoutEnd(gui)
end

-- Widget entier avec boutons [-]/[+]
function S.int_input(_, gui, _, _, setting)
    local val  = tonumber(U.get_setting(setting.id)) or setting.value_default
    local min  = setting.value_min  or -9999
    local max  = setting.value_max  or  9999
    local step = setting.step       or  1

    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)
    GuiLayoutBeginHorizontal(gui, U.offset, 0, true, 0, 0)

    GuiText(gui, 4, 0, "")
    local _, _, _, bx, by = GuiGetPreviousWidgetInfo(gui)
    local bw, bh = GuiGetTextDimensions(gui, "[-]")
    G.button_options(gui)
    GuiImageNinePiece(gui, id(), bx, by, bw, bh, 0)
    local clicked_minus, _, hov_m = GuiGetPreviousWidgetInfo(gui)
    G.yellow_if_hovered(gui, hov_m)
    GuiText(gui, 0, 0, "[-]")
    if clicked_minus then U.set_setting(setting.id, math.max(min, val - step)) end

    GuiText(gui, 2, 0, tostring(val) .. (setting.suffix or ""))

    GuiText(gui, 2, 0, "")
    local _, _, _, px, py = GuiGetPreviousWidgetInfo(gui)
    local pw, ph = GuiGetTextDimensions(gui, "[+]")
    G.button_options(gui)
    GuiImageNinePiece(gui, id(), px, py, pw, ph, 0)
    local clicked_plus, _, hov_p = GuiGetPreviousWidgetInfo(gui)
    G.yellow_if_hovered(gui, hov_p)
    GuiText(gui, 0, 0, "[+]")
    if clicked_plus then U.set_setting(setting.id, math.min(max, val + step)) end

    GuiLayoutEnd(gui)
end

function S.reset_stuff(_, gui, _, _, setting)
    local fn = U[setting.id]
    if not fn then
        GuiText(gui, mod_setting_group_x_offset, 0, "ERR: " .. tostring(setting.id))
        return
    end
    local text = "[Reset]"
    GuiText(gui, mod_setting_group_x_offset, 0, "")
    local _, _, _, x, y = GuiGetPreviousWidgetInfo(gui)
    local w, h = GuiGetTextDimensions(gui, text)
    G.button_options(gui)
    GuiImageNinePiece(gui, id(), x, y, w, h, 0)
    local clicked, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then GuiColorSetForNextWidget(gui, 1, 0.4, 0.4, 1)
    else             GuiColorSetForNextWidget(gui, 0.8, 0.3, 0.3, 1) end
    GuiText(gui, mod_setting_group_x_offset, 0, text)
    if clicked then fn() end
end

-- =============================================================================
-- build_settings
-- =============================================================================

local function build_settings()
    local settings = {
        -- ---- Touche de pickup ------------------------------------------------
        {
            id             = "storage_pickup_key",
            not_setting    = true,
            ui_name        = "Pickup Key",
            ui_description = "Key or mouse button to pick up nearby items into the held Storage Stone.",
            value_default  = D.storage_pickup_key,
            ui_fn          = S.get_input,
        },
        {
            id          = "reset_storage_key",
            not_setting = true,
            ui_fn       = S.reset_stuff,
        },

        -- ---- Position du panneau ---------------------------------------------
        -- Déplace le panneau si il chevauche les baguettes ou un autre élément.
        -- La position de l'inventaire vanilla est lue automatiquement depuis
        -- MagicNumbers (UI_BARS_POS_X / UI_BARS_POS_Y) — aucun réglage manuel.
        {
            id             = "panel_x",
            not_setting    = true,
            ui_name        = "Panel X",
            ui_description = "Horizontal position of the Storage Stone inventory panel. Increase to move right of wands.",
            value_default  = D.panel_x,
            value_min      = 0,
            value_max      = 420,
            step           = 1,
            ui_fn          = S.int_input,
        },
        {
            id             = "panel_y",
            not_setting    = true,
            ui_name        = "Panel Y",
            ui_description = "Vertical position of the Storage Stone inventory panel.",
            value_default  = D.panel_y,
            value_min      = 0,
            value_max      = 220,
            step           = 1,
            ui_fn          = S.int_input,
        },
        {
            id          = "reset_panel_pos",
            not_setting = true,
            ui_fn       = S.reset_stuff,
        },
    }
    U.offset = U.calculate_elements_offset(settings)
    return settings
end

-- =============================================================================
-- Fonctions requises par Noita
-- =============================================================================

function ModSettingsUpdate(init_scope)
    U.set_default(false)
    U.waiting_for_input = false
    mod_settings = build_settings()
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

-- =============================================================================
-- Init
-- =============================================================================

U.gather_key_codes()
mod_settings = build_settings()