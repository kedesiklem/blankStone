#!/usr/bin/env bash
# modules/40_stone_reg.sh — entrée dans stone_registry.lua (REQUIS)

register_module "stone_reg"

STONE_REG_LEVEL="1"
STONE_REG_CATEGORY="elemental"
STONE_REG_MSG_SUCCESS=""
STONE_REG_MSG_FAIL=""
STONE_REG_COND_ORBS=""
STONE_REG_COND_PURITY=0

ask_stone_reg() {
  section "stone_registry.lua"

  echo "  Niveaux disponibles : 1 | 5 | 7 | 9 | 10 | 11"
  STONE_REG_LEVEL=$(ask "Level" "1")

  echo "  Catégories : elemental | special | vanilla | book"
  STONE_REG_CATEGORY=$(ask "Category" "elemental")

  # Messages de craft custom
  STONE_REG_MSG_SUCCESS=""; STONE_REG_MSG_FAIL=""
  if ask_bool "Messages custom lors du craft ?"; then
    STONE_REG_MSG_SUCCESS=$(ask "  Clé succès (\$text_... — vide = message par défaut)" "")
    STONE_REG_MSG_FAIL=$(ask "  Clé échec  (\$text_... — vide = message par défaut)" "")
  fi

  # Conditions custom
  STONE_REG_COND_ORBS=""; STONE_REG_COND_PURITY=0
  if ask_bool "Conditions custom pour obtenir la pierre ? (sinon déduit du level)"; then
    STONE_REG_COND_ORBS=$(ask "  Nombre d'orbes requis (vide = hérité du level)" "")
    ask_bool "  Pureté requise ?" && STONE_REG_COND_PURITY=1 || STONE_REG_COND_PURITY=0
  fi
}

xml_stone_reg() { :; }  # pas de contribution XML

reg_stone_reg() {
  if [[ ! -f "$STONE_REGISTRY_FILE" ]]; then
    warn "REGISTRY → introuvable, ajouter manuellement dans stone_registry.lua"
    return 0
  fi

  if grep -q "\[\"${STONE_NAME}\"\]" "$STONE_REGISTRY_FILE"; then
    warn "REGISTRY → ${STONE_NAME} déjà présent, ignoré"
    return 0
  fi

  # Entrée principale STONE_DATA
  local entry
  entry="    [\"${STONE_NAME}\"] = {
        path = elemental_stone_path .. \"${STONE_FILE_ID}\",
        level = ${STONE_REG_LEVEL},
        category = \"${STONE_REG_CATEGORY}\",
    },"
  insert_before "$STONE_REGISTRY_FILE" "$ANCHOR_STONE_DATA" "$entry"

  # Messages custom (optionnel)
  if [[ -n "$STONE_REG_MSG_SUCCESS" || -n "$STONE_REG_MSG_FAIL" ]]; then
    local s="${STONE_REG_MSG_SUCCESS:-\$text_blankstone_default_success}"
    local f="${STONE_REG_MSG_FAIL:-\$text_blankstone_default_fail}"
    local msg_entry
    msg_entry="    [\"${STONE_NAME}\"] = {
        success = \"${s}\",
        fail    = \"${f}\",
    },"
    insert_before "$STONE_REGISTRY_FILE" "$ANCHOR_STONE_MSG" "$msg_entry"
  fi

  # Conditions custom (optionnel)
  if [[ -n "$STONE_REG_COND_ORBS" || $STONE_REG_COND_PURITY -eq 1 ]]; then
    local cond_parts=""
    if [[ -n "$STONE_REG_COND_ORBS" ]]; then cond_parts="orbs = ${STONE_REG_COND_ORBS}"; fi
    if [[ $STONE_REG_COND_PURITY -eq 1 ]]; then
      cond_parts="${cond_parts:+${cond_parts}, }purity = true"
    fi
    local cond_entry="    [\"${STONE_NAME}\"] = { ${cond_parts} },"
    insert_before "$STONE_REGISTRY_FILE" "$ANCHOR_STONE_COND" "$cond_entry"
  fi

  ok "REGISTRY → stone_registry.lua"
}

preview_stone_reg() {
  info "[REGISTRY] ${STONE_NAME} → level=${STONE_REG_LEVEL}, category=${STONE_REG_CATEGORY}"
  if [[ -n "$STONE_REG_MSG_SUCCESS" ]]; then info "  message.success = ${STONE_REG_MSG_SUCCESS}"; fi
  if [[ -n "$STONE_REG_MSG_FAIL" ]]; then info "  message.fail    = ${STONE_REG_MSG_FAIL}"; fi
  if [[ -n "$STONE_REG_COND_ORBS" ]]; then info "  condition.orbs  = ${STONE_REG_COND_ORBS}"; fi
  if [[ $STONE_REG_COND_PURITY -eq 1 ]]; then info "  condition.purity = true"; fi
}
