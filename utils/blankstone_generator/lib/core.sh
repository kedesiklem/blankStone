#!/usr/bin/env bash
# lib/core.sh — constantes, helpers, backup/rollback

# ── Racine du mod ──────────────────────────────────────────────────────────────
# SCRIPT_DIR = mods/blankStone/utils/blankstone_generator/
# MOD_ROOT   = mods/blankStone/
MOD_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# ── Chemins Noita-interne (dans les XML) ───────────────────────────────────────
MOD_PATH="mods/blankStone/files"

# ── Chemins sur disque ─────────────────────────────────────────────────────────
STONE_REGISTRY_FILE="${MOD_ROOT}/files/scripts/stone_factory/stone_registry.lua"
INFUSE_REGISTRY_FILE="${MOD_ROOT}/files/scripts/stone_factory/craft_registry/infuse_registry.lua"
FUSE_REGISTRY_FILE="${MOD_ROOT}/files/scripts/stone_factory/craft_registry/fuse_registry.lua"
FORGE_REGISTRY_FILE="${MOD_ROOT}/files/scripts/stone_factory/craft_registry/forge_registry.lua"
HINT_REGISTRY_FILE="${MOD_ROOT}/files/scripts/stone_factory/hint_registry.lua"
TRANSLATIONS_FILE="${MOD_ROOT}/translations.csv"

STONE_DIR="${MOD_ROOT}/files/entities/elemental_stone"
ITEMS_GFX_DIR="${MOD_ROOT}/files/items_gfx/elemental_stone"
UI_GFX_DIR="${MOD_ROOT}/files/ui_gfx/elemental_stone"

# ── Ancres d'insertion ─────────────────────────────────────────────────────────
ANCHOR_STONE_DATA="-- Vanilla Stones"
ANCHOR_STONE_MSG="-- ##ANCHOR_STONE_MSG_END##"
ANCHOR_STONE_COND="^    default = {"
ANCHOR_INFUSE_END="-- ##ANCHOR_INFUSE_END##"
ANCHOR_FUSE_END="-- ##ANCHOR_FUSE_END##"
ANCHOR_FORGE_END="-- ##ANCHOR_FORGE_END##"
ANCHOR_HINT_END="-- ##ANCHOR_HINT_END##"

# ── Fichiers à sauvegarder ─────────────────────────────────────────────────────
BACKUP_FILES=(
  "$STONE_REGISTRY_FILE"
  "$INFUSE_REGISTRY_FILE"
  "$FUSE_REGISTRY_FILE"
  "$FORGE_REGISTRY_FILE"
  "$HINT_REGISTRY_FILE"
  "$TRANSLATIONS_FILE"
)

# ── Registre des modules ───────────────────────────────────────────────────────
MODULES=()

register_module() {
  MODULES+=("$1")
  dbg "Module enregistré : $1"
  eval "preview_${1}() { :; }" 2>/dev/null || true
  eval "todo_${1}()    { :; }" 2>/dev/null || true
}

# ── Debug ──────────────────────────────────────────────────────────────────────
DEBUG=0

dbg() {
  if [[ $DEBUG -eq 1 ]]; then
    echo "  [DBG] $*" >&2
  fi
}

dbg_enter() { dbg "→ ${1}()"; }
dbg_exit()  { dbg "← ${1}() rc=$?"; }

# ── UI ─────────────────────────────────────────────────────────────────────────
print_banner() {
  clear 2>/dev/null || true
  echo ""
  echo "  ╔══════════════════════════════════════╗"
  echo "  ║  BlankStone — Générateur de pierre   ║"
  echo "  ╚══════════════════════════════════════╝"
  if [[ $DRY_RUN -eq 1 ]]; then echo "  ⚑  MODE DRY-RUN (aucun fichier modifié)"; fi
  if [[ $DEBUG  -eq 1 ]]; then echo "  ⚑  MODE DEBUG"; fi
  echo ""
}

section()  { echo ""; echo "── $* ──"; }
info()     { echo "  ℹ  $*"; }
ok()       { echo "  ✓  $*"; }
warn()     { echo "  ⚠  $*"; }
fail()     { echo "  ✗  $*"; }

ask() {
  local prompt="$1" default="${2:-}"
  local suffix=""
  if [[ -n "$default" ]]; then suffix=" [${default}]"; fi
  read -rp "  ${prompt}${suffix} : " _v
  echo "${_v:-$default}"
}

ask_bool() {
  local prompt="$1" default="${2:-n}"
  local sfx="[o/N]"
  if [[ "${default,,}" == "o" ]]; then sfx="[O/n]"; fi
  while true; do
    read -rp "  ${prompt} ${sfx} : " _b
    _b="${_b:-$default}"
    case "${_b,,}" in
      o|oui|y|yes|1) return 0 ;;
      n|non|no|0)    return 1 ;;
      *) echo "    → o ou n" ;;
    esac
  done
}

# ── Conversions ────────────────────────────────────────────────────────────────
to_camel() {
  local input="$1" result="" first=1
  IFS='_' read -ra _parts <<< "$input"
  for _p in "${_parts[@]}"; do
    if [[ $first -eq 1 ]]; then
      result="$_p"
      first=0
    else
      result="${result}${_p^}"
    fi
  done
  echo "${result}Stone"
}

to_file_id() {
  local name="${1%Stone}"
  echo "stone_$(echo "$name" | sed 's/\([A-Z]\)/_\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^_//')"
}

# ── CSV ────────────────────────────────────────────────────────────────────────
csv_val() {
  local v="$1"
  if [[ "$v" == *","* || "$v" == *'"'* || "$v" == *$'\n'* ]]; then
    v="${v//\"/\"\"}"
    echo "\"${v}\""
  else
    echo "$v"
  fi
}

# ── Insertions fichiers ────────────────────────────────────────────────────────
insert_before() {
  local file="$1" pattern="$2" text="$3"
  dbg "insert_before [${file##*/}] pat='${pattern}'"
  local tmp_ins; tmp_ins=$(mktemp)
  local tmp_out; tmp_out=$(mktemp)
  printf '%s\n' "$text" > "$tmp_ins"
  awk -v pat="$pattern" -v ins="$tmp_ins" '
    !done && $0 ~ pat {
      while ((getline line < ins) > 0) print line
      close(ins); done=1
    }
    { print }
  ' "$file" > "$tmp_out" && mv "$tmp_out" "$file"
  rm -f "$tmp_ins"
}

insert_after() {
  local file="$1" pattern="$2" text="$3"
  dbg "insert_after  [${file##*/}] pat='${pattern}'"
  local tmp_ins; tmp_ins=$(mktemp)
  local tmp_out; tmp_out=$(mktemp)
  printf '%s\n' "$text" > "$tmp_ins"
  awk -v pat="$pattern" -v ins="$tmp_ins" '
    { print }
    !done && $0 ~ pat {
      while ((getline line < ins) > 0) print line
      close(ins); done=1
    }
  ' "$file" > "$tmp_out" && mv "$tmp_out" "$file"
  rm -f "$tmp_ins"
}

# ── Backup / Rollback ──────────────────────────────────────────────────────────
backup_files() {
  dbg "backup_files (${#BACKUP_FILES[@]} fichiers)"
  for _f in "${BACKUP_FILES[@]}"; do
    if [[ -f "$_f" ]]; then
      cp "$_f" "${_f}.bak"
      dbg "  bak: ${_f##*/}"
    fi
  done
}

cleanup_backups() {
  dbg "cleanup_backups"
  for _f in "${BACKUP_FILES[@]}"; do
    if [[ -f "${_f}.bak" ]]; then rm "${_f}.bak"; fi
  done
}

rollback() {
  echo ""
  fail "Erreur — restauration des fichiers originaux..."
  for _f in "${BACKUP_FILES[@]}"; do
    if [[ -f "${_f}.bak" ]]; then
      mv "${_f}.bak" "$_f"
      echo "    restauré : ${_f##*/}"
    fi
  done
  exit 1
}

# ── Validation des ancres ──────────────────────────────────────────────────────
validate_anchors() {
  dbg "validate_anchors"
  local _ok=1
  _check_anchor() {
    local file="$1" anchor="$2" label="$3"
    if [[ -f "$file" ]] && ! grep -qF -- "$anchor" "$file"; then
      warn "Ancre manquante dans ${label} : ${anchor}"
      _ok=0
    fi
  }
  _check_anchor "$STONE_REGISTRY_FILE"  "$ANCHOR_STONE_DATA"  "stone_registry.lua"
  _check_anchor "$STONE_REGISTRY_FILE"  "$ANCHOR_STONE_MSG"   "stone_registry.lua"
  _check_anchor "$INFUSE_REGISTRY_FILE" "$ANCHOR_INFUSE_END"  "infuse_registry.lua"
  _check_anchor "$FUSE_REGISTRY_FILE"   "$ANCHOR_FUSE_END"    "fuse_registry.lua"
  _check_anchor "$FORGE_REGISTRY_FILE"  "$ANCHOR_FORGE_END"   "forge_registry.lua"
  _check_anchor "$HINT_REGISTRY_FILE"   "$ANCHOR_HINT_END"    "hint_registry.lua"
  if [[ $_ok -eq 0 ]]; then
    echo ""
    fail "Ancres manquantes — voir SETUP.md pour les ajouter."
    exit 1
  fi
  dbg "validate_anchors OK"
}

# ── Preview XML ────────────────────────────────────────────────────────────────
preview_xml() {
  local xml="$1"
  local lines; lines=$(printf '%s\n' "$xml" | wc -l)
  echo "  [XML] ${STONE_FILE_ID}.xml (${lines} lignes)"
  printf '%s\n' "$xml" | head -40 | sed 's/^/    /'
  if [[ $lines -gt 40 ]]; then
    echo "    ... ($((lines - 40)) lignes supplémentaires)"
  fi
}
