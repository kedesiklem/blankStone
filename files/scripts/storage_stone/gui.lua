-- =============================================================================
--  gui.lua
--  Panneau d'inventaire StorageStone — drag & drop interne à la pierre.
--
--  DRAG PIERRE → PIERRE / MONDE
--    GuiImageButton + GUI_OPTION.IsExtraDraggable sur chaque slot.
--    draw_x/draw_y dans GuiGetPreviousWidgetInfo SONT la position du widget
--    draggé (= curseur GUI). Quand ils reviennent à 0,0 → drag terminé →
--    dragging_possible_swap = true.
-- =============================================================================

dofile( "data/scripts/lib/utilities.lua" )
local storage = dofile_once("mods/blankStone/files/scripts/storage_stone/storage.lua")

-- ============================================================================
--  Constantes
-- ============================================================================

local SLOT_SIZE     = 20
local SLOTS_PER_ROW = 4
local TITLE_H       = 11

local SPRITE_PATH = "mods/blankStone/files/ui_gfx/inventory/"

local SPRITE_SLOT     = SPRITE_PATH .. "full_inventory_box.png"
local SPRITE_SLOT_HOV = SPRITE_PATH .. "full_inventory_box_highlight.png"
local SPRITE_INVIS    = SPRITE_PATH .. "invisible20x20.png"

-- Z-order (plus petit = devant dans Noita GUI)
local Z_TIP  = 1
local Z_DRAG = 2
local Z_ITEM = 5
local Z_SLOT = 8

-- ============================================================================
--  State du module
-- ============================================================================

local _gui = nil

-- Compteur d'IDs GUI stables frame-to-frame (pattern BagOfMany)
local _id_ctr   = 0
local _reserved = {}
local function nid()
    _id_ctr = _id_ctr + 1
    while _reserved[_id_ctr] do _id_ctr = _id_ctr + 1 end
    return _id_ctr
end
local function reserve_id(i) _reserved[i] = true end
local function reset_ids() _id_ctr = 0; _reserved = {} end

-- dragged_item : item en cours de drag depuis la pierre
local dragged_item = {
    item               = nil,
    bag                = nil,  -- stone_id
    position           = nil,  -- slot dans la pierre (1-based)
    position_x         = 0,
    position_y         = 0,
    initial_position_x = 0,
    initial_position_y = 0,
}

-- hovered_item : slot de la pierre sous le curseur
local hovered_item = {
    item     = nil,
    bag      = nil,
    position = nil,
}

local dragging_possible_swap = false
local dragged_invis_gui_id   = nil
local dragged_item_gui_id    = nil

local function reset_state()
    for k in pairs(dragged_item) do dragged_item[k] = nil end
    dragged_item.position_x         = 0
    dragged_item.position_y         = 0
    dragged_item.initial_position_x = 0
    dragged_item.initial_position_y = 0

    for k in pairs(hovered_item) do hovered_item[k] = nil end

    dragging_possible_swap = false
    dragged_invis_gui_id   = nil
    dragged_item_gui_id    = nil
end

-- ============================================================================
--  Helpers position
-- ============================================================================

-- Position GUI du slot i dans le panneau de la pierre (1-based).
local function slot_pos(i, ox, oy)
    local col = (i - 1) % SLOTS_PER_ROW
    local row = math.floor((i - 1) / SLOTS_PER_ROW)
    return ox + col * SLOT_SIZE, oy + row * SLOT_SIZE
end

-- Position du panneau pierre (depuis settings).
local function panel_origin()
    return tonumber(ModSettingGet("blankStone.panel_x")) or 185,
           tonumber(ModSettingGet("blankStone.panel_y")) or 27
end

-- ============================================================================
--  Helpers potion
-- ============================================================================

-- Retourne true si l'entité est une potion (a un contenu liquide).
local function is_potion(entity_id)
    return EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent") ~= nil
       and EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")    ~= nil
end

-- Applique la couleur de la potion au prochain widget GUI.
-- Reproduit add_potion_color de BagOfMany.
local function apply_potion_color(entity_id)
    local color = GameGetPotionColorUint(entity_id)
    if color and color ~= 0 then
        local b = bit.rshift(bit.band(color, 0xFF0000), 16) / 0xFF
        local g = bit.rshift(bit.band(color, 0xFF00),   8) / 0xFF
        local r = bit.band(color, 0xFF)                    / 0xFF
        GuiColorSetForNextWidget(_gui, r, g, b, 1)
    end
end

-- Retourne la liste des matériaux d'une potion, triés par quantité décroissante.
-- Reproduit get_potion_contents de BagOfMany.
local function get_potion_contents(entity_id)
    local materials = {}
    local suc = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    local inv = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if not suc or not inv then return materials end

    local capacity = ComponentGetValue2(suc, "barrel_size")
    local counts   = ComponentGetValue2(inv, "count_per_material_type")
    for i = 1, #counts do
        if counts[i] > 0 then
            table.insert(materials, {
                name   = CellFactory_GetUIName(i - 1),
                amount = (counts[i] / capacity) * 100,
            })
        end
    end
    table.sort(materials, function(a, b) return a.amount > b.amount end)
    return materials
end

-- ============================================================================
--  Tooltip
-- ============================================================================

local function draw_tooltip(item, sx, sy)
    local name = storage.get_item_name(item)
    local desc = storage.get_item_desc(item)
    if name == "?" and desc == "" then return end
    GuiBeginAutoBox(_gui)
    GuiLayoutBeginVertical(_gui, sx, sy + SLOT_SIZE + 2, true)
    GuiZSetForNextWidget(_gui, Z_TIP)
    GuiText(_gui, 0, 0, name)
    if desc ~= "" and desc ~= name then
        GuiColorSetForNextWidget(_gui, 0.72, 0.72, 0.72, 1.0)
        GuiZSetForNextWidget(_gui, Z_TIP)
        GuiText(_gui, 0, 0, desc)
    end
    -- Contenu de la potion
    if is_potion(item) then
        local contents = get_potion_contents(item)
        if #contents > 0 then
            for _, mat in ipairs(contents) do
                GuiColorSetForNextWidget(_gui, 0.85, 0.95, 1.0, 1.0)
                GuiZSetForNextWidget(_gui, Z_TIP)
                GuiText(_gui, 0, 0, string.format("%s  %.0f%%", mat.name, mat.amount))
            end
        else
            GuiColorSetForNextWidget(_gui, 0.55, 0.55, 0.55, 1.0)
            GuiZSetForNextWidget(_gui, Z_TIP)
            GuiText(_gui, 0, 0, "empty")
        end
    end
    GuiLayoutEnd(_gui)
    GuiZSetForNextWidget(_gui, Z_TIP + 1)
    GuiEndAutoBoxNinePiece(_gui)
end

-- ============================================================================
--  Phase 1 : boutons invisibles IsExtraDraggable sur les slots pierre
--
--  Reproduit draw_inventory_v2_invisible de BagOfMany.
--  draw_x/draw_y = position GUI du widget draggé par Noita.
--  Retournent à 0,0 quand le drag se termine.
-- ============================================================================

local function draw_stone_invisible_buttons(stone_id, capacity, ox, oy, p2item)
    for i = 1, capacity do
        local sx, sy = slot_pos(i, ox, oy)

        -- Le slot source du drag actif : bouton non-draggable uniquement pour
        -- la détection du hover (permet de re-poser sur ce même slot = annuler).
        if dragged_item.position == i and dragged_item.bag == stone_id then
            GuiOptionsAddForNextWidget(_gui, GUI_OPTION.NoPositionTween)
            GuiOptionsAddForNextWidget(_gui, GUI_OPTION.NoSound)
            GuiOptionsAddForNextWidget(_gui, GUI_OPTION.DrawNoHoverAnimation)
            GuiZSetForNextWidget(_gui, 1)
            GuiImageButton(_gui, nid(), sx, sy, "", SPRITE_INVIS)
            local _, _, hov = GuiGetPreviousWidgetInfo(_gui)
            if hov then
                hovered_item.bag      = stone_id
                hovered_item.position = i
                hovered_item.item     = p2item[i]
                GuiZSetForNextWidget(_gui, Z_SLOT - 1)
                GuiImage(_gui, nid(), sx - 1, sy - 1, SPRITE_SLOT_HOV, 1, 1.1, 1)
            end
            goto continue
        end

        GuiOptionsAddForNextWidget(_gui, GUI_OPTION.IsExtraDraggable)
        GuiOptionsAddForNextWidget(_gui, GUI_OPTION.NoPositionTween)
        GuiOptionsAddForNextWidget(_gui, GUI_OPTION.ClickCancelsDoubleClick)
        GuiOptionsAddForNextWidget(_gui, GUI_OPTION.NoSound)
        GuiOptionsAddForNextWidget(_gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiZSetForNextWidget(_gui, 1)
        GuiImageButton(_gui, nid(), sx, sy, "", SPRITE_INVIS)
        local clicked, right_clicked, hov, _, _, _, _, draw_x, draw_y =
            GuiGetPreviousWidgetInfo(_gui)

        -- Début de drag : le widget a commencé à se déplacer
        if not dragged_item.item
        and draw_x ~= nil and draw_y ~= nil
        and (draw_x ~= 0 or draw_y ~= 0)
        and (math.abs(draw_x - sx) > 1 or math.abs(draw_y - sy) > 1) then
            dragged_item.bag                = stone_id
            dragged_item.position           = i
            dragged_item.item               = p2item[i]
            dragged_item.position_x         = draw_x
            dragged_item.position_y         = draw_y
            dragged_item.initial_position_x = sx
            dragged_item.initial_position_y = sy
            dragged_invis_gui_id = _id_ctr
            reserve_id(dragged_invis_gui_id)
        end

        -- Fin de drag : draw retourne à 0,0 alors qu'on trackait ce slot
        if dragged_item.position == i and dragged_item.bag == stone_id
        and draw_x ~= nil and math.floor(draw_x) == 0 and math.floor(draw_y) == 0 then
            dragging_possible_swap = true
        end

        -- Clic gauche simple sur slot occupé → drop au sol
        if clicked and not dragged_item.item and p2item[i] then
            storage.drop(stone_id, p2item[i])
        end

        -- Clic droit → drop au sol
        if right_clicked and p2item[i] then
            storage.drop(stone_id, p2item[i])
        end

        -- Hover : enregistrer le slot cible pour le swap
        if hov then
            hovered_item.bag      = stone_id
            hovered_item.position = i
            hovered_item.item     = p2item[i]

            if dragged_item.item then
                GuiZSetForNextWidget(_gui, Z_SLOT - 1)
                GuiImage(_gui, nid(), sx - 1, sy - 1, SPRITE_SLOT_HOV, 1, 1.1, 1)
            end
        end

        ::continue::
    end
end

-- ============================================================================
--  Phase 2 : rendu des sprites items de la pierre
-- ============================================================================

local function draw_stone_items(stone_id, capacity, ox, oy, p2item)
    for i = 1, capacity do
        local item = p2item[i]
        if not item then goto continue end

        -- L'item du slot source est rendu par draw_dragged_item
        if dragged_item.position == i and dragged_item.bag == stone_id then
            if not dragged_item.item then dragged_item.item = item end
            dragged_item_gui_id = nid()
            reserve_id(dragged_item_gui_id)
            goto continue
        end

        local sx, sy = slot_pos(i, ox, oy)
        local sprite = storage.get_sprite_file(item)
        local ok, iw, ih = pcall(GuiGetImageDimensions, _gui, sprite, 1)
        if not ok or iw == 0 then iw = SLOT_SIZE; ih = SLOT_SIZE end

        local pad_x = math.floor((SLOT_SIZE - iw) / 2)
        local pad_y = math.floor((SLOT_SIZE - ih) / 2)

        -- Légère élévation + tooltip si survolé sans drag actif
        local lift = 0
        if hovered_item.position == i and hovered_item.bag == stone_id
        and not dragged_item.item then
            lift = 1
            draw_tooltip(item, sx, sy)
        end

        GuiZSetForNextWidget(_gui, Z_ITEM)
        if is_potion(item) then apply_potion_color(item) end
        GuiImage(_gui, nid(), sx + pad_x, sy + pad_y - lift, sprite, 1, 1, 1)

        ::continue::
    end
end

-- ============================================================================
--  Phase 3 : item flottant de la pierre (suit le curseur via IsExtraDraggable)
--
--  Reproduit draw_inventory_dragged_item_v2 de BagOfMany.
--  Réutilise dragged_invis_gui_id pour que Noita maintienne le tracking du drag.
-- ============================================================================

local function draw_dragged_item()
    if not dragged_invis_gui_id or not dragged_item_gui_id then return end
    if not dragged_item.item then return end

    -- Bouton invisible avec le MÊME ID que le slot source : Noita continue
    -- de tracker le même drag et met à jour draw_x/draw_y
    GuiOptionsAddForNextWidget(_gui, GUI_OPTION.IsExtraDraggable)
    GuiOptionsAddForNextWidget(_gui, GUI_OPTION.NoPositionTween)
    GuiOptionsAddForNextWidget(_gui, GUI_OPTION.ClickCancelsDoubleClick)
    GuiOptionsAddForNextWidget(_gui, GUI_OPTION.NoSound)
    GuiOptionsAddForNextWidget(_gui, GUI_OPTION.DrawNoHoverAnimation)
    GuiZSetForNextWidget(_gui, 1)
    GuiImageButton(_gui, dragged_invis_gui_id, 0, 0, "", SPRITE_INVIS)
    local _, _, _, _, _, _, _, draw_x, draw_y = GuiGetPreviousWidgetInfo(_gui)

    if draw_x == nil or (math.floor(draw_x) == 0 and math.floor(draw_y) == 0) then
        dragging_possible_swap = true
        return
    end

    dragged_item.position_x = draw_x
    dragged_item.position_y = draw_y

    local sprite = storage.get_sprite_file(dragged_item.item)
    local ok, iw, ih = pcall(GuiGetImageDimensions, _gui, sprite, 1)
    if not ok or iw == 0 then iw = SLOT_SIZE; ih = SLOT_SIZE end

    GuiZSetForNextWidget(_gui, Z_DRAG)
    if is_potion(dragged_item.item) then apply_potion_color(dragged_item.item) end
    GuiImageButton(_gui, dragged_item_gui_id,
        draw_x + math.floor((SLOT_SIZE - iw) / 2),
        draw_y + math.floor((SLOT_SIZE - ih) / 2),
        "", sprite)
end

-- ============================================================================
--  Résolution du swap
--
--  Gère uniquement les déplacements internes à la pierre et le drop au sol.
--  Termine par GuiDestroy/GuiCreate (obligatoire comme dans BagOfMany).
-- ============================================================================

local function resolve_swap(stone_id)
    if dragged_item.bag == stone_id and dragged_item.item then

        if hovered_item.bag == stone_id and hovered_item.position
        and hovered_item.position ~= dragged_item.position then
            -- Pierre → autre slot pierre : déplacement ou swap
            storage.move_to_position(stone_id, dragged_item.item, hovered_item.position)

        elseif hovered_item.bag ~= stone_id or not hovered_item.position then
            -- Pierre → dehors : drop au sol
            storage.drop(stone_id, dragged_item.item)
        end
        -- Même slot : ne rien faire
    end

    reset_state()
    GuiDestroy(_gui)
    _gui = GuiCreate()
end

-- ============================================================================
--  API publique
-- ============================================================================

local Gui = {}

function Gui.draw(player_id, stone_id, inv_open)
    if not inv_open then reset_state(); return end
    if not stone_id or not EntityGetIsAlive(stone_id) then reset_state(); return end

    if not _gui then _gui = GuiCreate() end

    GuiStartFrame(_gui)
    GuiOptionsAdd(_gui, GUI_OPTION.NoPositionTween)
    reset_ids()

    -- Reset des flags recalculés chaque frame
    for k in pairs(hovered_item) do hovered_item[k] = nil end

    local capacity = storage.get_capacity(stone_id)
    local items    = storage.get_items(stone_id)
    local ox, oy_t = panel_origin()
    local oy       = oy_t + TITLE_H + 2

    -- Lookup position → item
    local p2item = {}
    for _, it in ipairs(items) do
        local p = storage.get_item_position(it)
        if p then p2item[p] = it end
    end

    -- -----------------------------------------------------------------------
    --  Titre
    -- -----------------------------------------------------------------------
    GuiZSetForNextWidget(_gui, Z_ITEM)
    GuiColorSetForNextWidget(_gui, 0.92, 0.80, 0.55, 1.0)
    GuiText(_gui, ox, oy_t,
        GameTextGet("$stone_blankstone_storageStone_name") or "Storage Stone")

    -- -----------------------------------------------------------------------
    --  Fond des slots
    -- -----------------------------------------------------------------------
    for i = 1, capacity do
        local sx, sy = slot_pos(i, ox, oy)
        GuiZSetForNextWidget(_gui, Z_SLOT)
        GuiImage(_gui, nid(), sx, sy, SPRITE_SLOT, 1, 1, 1)
    end

    -- -----------------------------------------------------------------------
    --  Phase 1 : boutons IsExtraDraggable (capture drag depuis pierre)
    -- -----------------------------------------------------------------------
    draw_stone_invisible_buttons(stone_id, capacity, ox, oy, p2item)

    -- -----------------------------------------------------------------------
    --  Phase 2 : sprites des items de la pierre
    -- -----------------------------------------------------------------------
    draw_stone_items(stone_id, capacity, ox, oy, p2item)

    -- -----------------------------------------------------------------------
    --  Phase 3 : item flottant (drag depuis pierre)
    -- -----------------------------------------------------------------------
    draw_dragged_item()

    -- -----------------------------------------------------------------------
    --  Résolution du swap (dernière chose de la frame)
    -- -----------------------------------------------------------------------
    if dragging_possible_swap then
        resolve_swap(stone_id)
    end
end

function Gui.cleanup()
    if _gui then GuiDestroy(_gui) end
    _gui = nil
    reset_state()
end

return Gui