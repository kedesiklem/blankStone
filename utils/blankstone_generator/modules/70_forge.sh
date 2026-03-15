#!/usr/bin/env bash
# modules/70_forge.sh — forge_registry.lua (recette d'enclume)

register_module "forge"

FORGE_ENABLED=0
FORGE_SPELLS=()   # IDs de sorts forgés
FORGE_ITEMS=()    # chemins XML d'items forgés
FORGE_MSG_TITLE=""
FORGE_MSG_DESC=""

# ── Wizard ─────────────────────────────────────────────────────────────────────
ask_forge() {
  FORGE_ENABLED=0
  ask_bool "Recette de forge (forge_registry) ?" || return 0
  FORGE_ENABLED=1

  section "forge_registry.lua"

  echo "  — Sorts produits (vide pour terminer) :"
  while true; do
    local s; s=$(ask "  + Spell ID (ex: BLANKSTONE_STONE_FUSER)" ""); [[ -z "$s" ]] && break
    FORGE_SPELLS+=("$s")
  done

  echo ""
  echo "  — Items produits (chemin XML, vide pour terminer) :"
  echo "    Préfixe suggéré : mods/blankStone/files/entities/elemental_stone/"
  while true; do
    local it; it=$(ask "  + Chemin XML" ""); [[ -z "$it" ]] && break
    FORGE_ITEMS+=("$it")
  done

  if [[ ${#FORGE_SPELLS[@]} -eq 0 && ${#FORGE_ITEMS[@]} -eq 0 ]]; then
    warn "Aucun sort ni item renseigné — recette de forge ignorée"
    FORGE_ENABLED=0
    return 0
  fi

  if ask_bool "Message custom lors de la forge ?"; then
    FORGE_MSG_TITLE=$(ask "  Clé titre (\$text_blankstone_...)" "")
    FORGE_MSG_DESC=$(ask "  Clé desc  (\$text_blankstone_...)" "")
  fi
}

# ── XML ────────────────────────────────────────────────────────────────────────
xml_forge() { :; }

# ── Registre ───────────────────────────────────────────────────────────────────
reg_forge() {
  if [[ $FORGE_ENABLED -eq 0 ]]; then return 0; fi

  if [[ ! -f "$FORGE_REGISTRY_FILE" ]]; then
    warn "FORGE → introuvable, ajouter manuellement dans forge_registry.lua"
    return 0
  fi

  local spells_block=""
  if [[ ${#FORGE_SPELLS[@]} -gt 0 ]]; then
    local spell_lines=""
    for s in "${FORGE_SPELLS[@]}"; do spell_lines+="        \"${s}\",
"; done
    spells_block="        spells = {
${spell_lines}        },
"
  fi

  local items_block=""
  if [[ ${#FORGE_ITEMS[@]} -gt 0 ]]; then
    local item_lines=""
    for it in "${FORGE_ITEMS[@]}"; do item_lines+="        \"${it}\",
"; done
    items_block="        items = {
${item_lines}        },
"
  fi

  local msg_block=""
  if [[ -n "$FORGE_MSG_TITLE" ]]; then
    msg_block="        message = {
            title = \"${FORGE_MSG_TITLE}\",
            desc  = \"${FORGE_MSG_DESC}\",
        },
"
  fi

  local entry
  entry="    [\"${STONE_NAME}\"] = {
${spells_block}${items_block}${msg_block}    },"

  insert_before "$FORGE_REGISTRY_FILE" "$ANCHOR_FORGE_END" "$entry"
  ok "FORGE    → forge_registry.lua"
}

# ── Preview ────────────────────────────────────────────────────────────────────
preview_forge() {
  if [[ $FORGE_ENABLED -eq 0 ]]; then return 0; fi
  [[ ${#FORGE_SPELLS[@]} -gt 0 ]] && info "[FORGE] spells: ${FORGE_SPELLS[*]}"
  [[ ${#FORGE_ITEMS[@]}  -gt 0 ]] && info "[FORGE] items:  ${FORGE_ITEMS[*]}"
}
