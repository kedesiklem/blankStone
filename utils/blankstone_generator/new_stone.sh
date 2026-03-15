#!/usr/bin/env bash
# BlankStone — Générateur
#
# Usage : ./new_stone.sh <mode> [options]
#
#   Modes :
#     --stone        Créer une nouvelle pierre (wizard complet)
#     --craft        Ajouter un craft à une pierre existante
#     --list-stones  Lister les pierres existantes
#     --help         Afficher cette aide
#
#   Options :
#     --dry-run      Aperçu sans écriture (combinable avec --stone et --craft)
#     --debug        Afficher les traces d'exécution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
DEBUG=0
_mode=""

# ── Arguments ──────────────────────────────────────────────────────────────────
for _arg in "$@"; do
  case "$_arg" in
    --stone)       _mode="stone" ;;
    --craft)       _mode="craft" ;;
    --list-stones) _mode="list"  ;;
    --dry-run)     DRY_RUN=1     ;;
    --debug)       DEBUG=1       ;;
    --help|-h)     _mode="help"  ;;
    *) echo "Option inconnue : $_arg  (--help pour l'aide)" >&2; exit 1 ;;
  esac
done
unset _arg

# ── Librairies ─────────────────────────────────────────────────────────────────
source "${SCRIPT_DIR}/lib/core.sh"
source "${SCRIPT_DIR}/lib/registry.sh"

dbg "SCRIPT_DIR = ${SCRIPT_DIR}"
dbg "MOD_ROOT   = ${MOD_ROOT}"
dbg "mode       = ${_mode:-<vide>}"
dbg "DRY_RUN    = ${DRY_RUN}  DEBUG = ${DEBUG}"

# ── Dispatch ───────────────────────────────────────────────────────────────────
case "$_mode" in

  help|"")
    grep '^#' "$0" | grep -v '^#!/' | sed 's/^# \?//'
    exit 0
    ;;

  list)
    echo "Pierres dans stone_registry.lua :"
    list_stones_detailed
    exit 0
    ;;

  stone)
    dbg "Chargement des modules..."
    for _f in "${SCRIPT_DIR}/modules"/[0-9][0-9]_*.sh; do
      if [[ -f "$_f" ]]; then
        dbg "  source ${_f##*/}"
        source "$_f"
      fi
    done
    unset _f
    dbg "Modules chargés : ${MODULES[*]}"

    validate_anchors
    print_banner

    # Phase 1 : Wizard
    dbg "=== Phase 1 : Wizard ==="
    for _mod in "${MODULES[@]}"; do
      dbg "ask_${_mod}"
      "ask_${_mod}"
    done

    # Phase 2 : Assemblage XML
    dbg "=== Phase 2 : XML ==="
    STONE_XML=""
    for _mod in "${MODULES[@]}"; do
      dbg "xml_${_mod}"
      STONE_XML+="$(xml_${_mod})"
    done

    # Phase 3 : Preview
    dbg "=== Phase 3 : Preview ==="
    echo ""
    echo "╔══ Aperçu ═══════════════════════════════════════"
    preview_xml "$STONE_XML"
    echo ""
    for _mod in "${MODULES[@]}"; do
      dbg "preview_${_mod}"
      "preview_${_mod}"
    done
    echo "╚══════════════════════════════════════════════════"

    if [[ $DRY_RUN -eq 1 ]]; then
      echo ""
      info "Mode dry-run — aucun fichier modifié."
      exit 0
    fi

    # Phase 4 : Confirmation
    dbg "=== Phase 4 : Confirmation ==="
    echo ""
    ask_bool "Confirmer la création ?" o || { echo "Annulé."; exit 0; }

    # Phase 5 : Écriture
    dbg "=== Phase 5 : Écriture ==="
    backup_files
    trap rollback ERR
    echo ""

    mkdir -p "$STONE_DIR"
    _xml_out="${STONE_DIR}/${STONE_FILE_ID}.xml"
    if [[ -f "$_xml_out" ]]; then
      ask_bool "⚠  ${_xml_out##*/} existe déjà — écraser ?" || { echo "Annulé."; exit 0; }
    fi
    printf '%s\n' "$STONE_XML" > "$_xml_out"
    ok "XML      → ${_xml_out#${MOD_ROOT}/}"

    _cp_placeholder() {
      local src="$1" dst="$2"
      dbg "_cp_placeholder ${src##*/} → ${dst##*/}"
      if [[ -f "$dst" ]]; then
        warn "PNG → ${dst##*/} déjà présent, ignoré"
      elif [[ -f "$src" ]]; then
        cp "$src" "$dst"
        ok "PNG → ${dst#${MOD_ROOT}/}"
      else
        warn "PNG → placeholder introuvable : ${src#${MOD_ROOT}/}"
      fi
    }
    mkdir -p "$ITEMS_GFX_DIR" "$UI_GFX_DIR"
    _cp_placeholder "${MOD_ROOT}/files/items_gfx/placeholder_stone.png" \
                    "${ITEMS_GFX_DIR}/${STONE_FILE_ID}.png"
    _cp_placeholder "${MOD_ROOT}/files/ui_gfx/placeholder_stone.png"   \
                    "${UI_GFX_DIR}/${STONE_FILE_ID}.png"

    dbg "Écriture registres..."
    for _mod in "${MODULES[@]}"; do
      dbg "reg_${_mod}"
      "reg_${_mod}"
    done

    trap - ERR
    cleanup_backups

    echo ""
    echo "Reste à faire :"
    echo "  • Sprites PNG :"
    echo "      files/items_gfx/elemental_stone/${STONE_FILE_ID}.png"
    echo "      files/ui_gfx/elemental_stone/${STONE_FILE_ID}.png"
    for _mod in "${MODULES[@]}"; do "todo_${_mod}"; done

    # Ouverture Aseprite
    _items_png="${ITEMS_GFX_DIR}/${STONE_FILE_ID}.png"
    _ui_png="${UI_GFX_DIR}/${STONE_FILE_ID}.png"
    if command -v aseprite &>/dev/null; then
      ask_bool "Ouvrir les sprites dans Aseprite maintenant ?" o && \
        aseprite "$_items_png" "$_ui_png" &
    else
      warn "Aseprite introuvable dans le PATH — ouvrir manuellement."
    fi
    echo ""
    ;;

  craft)
    dbg "Chargement des modules (mode craft)..."
    for _f in "${SCRIPT_DIR}/modules"/[0-9][0-9]_*.sh; do
      if [[ -f "$_f" ]]; then
        dbg "  source ${_f##*/}"
        source "$_f"
      fi
    done
    unset _f

    source "${SCRIPT_DIR}/lib/craft_wizard.sh"
    validate_anchors
    print_banner
    run_craft_wizard
    ;;

esac
