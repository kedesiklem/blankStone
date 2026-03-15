#!/usr/bin/env bash
# lib/craft_wizard.sh — mode --craft

run_craft_wizard() {
  dbg_enter "run_craft_wizard"

  section "Craft — pierre cible"
  echo "  Pierres disponibles :"
  list_stones | pr -3 -t | sed 's/^/    /'
  echo ""

  local raw_id
  raw_id=$(ask "ID de la pierre cible (snake_case, ex: magic_fire)")
  if [[ -z "$raw_id" ]]; then
    fail "ID requis."
    exit 1
  fi

  STONE_NAME="$(to_camel "$raw_id")"
  STONE_FILE_ID="$(to_file_id "$STONE_NAME")"
  dbg "Cible : STONE_NAME=${STONE_NAME}  STONE_FILE_ID=${STONE_FILE_ID}"

  if ! stone_exists "$STONE_NAME"; then
    warn "${STONE_NAME} introuvable dans stone_registry.lua"
    ask_bool "  Continuer quand même ?" || { echo "Annulé."; exit 0; }
  fi

  info "Pierre cible : ${STONE_NAME}"
  echo ""

  echo "  Type de craft :"
  echo "    [1] Infusion INPUT  — autre pierre + matériau → cette pierre"
  echo "    [2] Infusion OUTPUT — cette pierre + matériau → autre(s) pierre(s)"
  echo "    [3] Hint d'infusion — matériau → message"
  echo "    [4] Fusion  (fuse_registry)"
  echo "    [5] Forge   (forge_registry)"
  echo ""
  read -rp "  > " _type
  dbg "Type choisi : ${_type}"

  case "$_type" in
    1) _cw_infuse_in  ;;
    2) _cw_infuse_out ;;
    3) _cw_hint       ;;
    4) _cw_fuse       ;;
    5) _cw_forge      ;;
    *) fail "Choix invalide."; exit 1 ;;
  esac
}

_cw_infuse_in() {
  dbg_enter "_cw_infuse_in"
  section "Infusion INPUT"
  echo "  Pierres disponibles comme source :"
  list_stones | pr -3 -t | sed 's/^/    /'
  echo ""

  while true; do
    _ask_infuse_in
    ask_bool "  Ajouter une autre source ?" || break
  done

  if [[ ${#INFUSE_R_SRC[@]} -eq 0 ]]; then
    warn "Aucune recette — annulé."
    exit 0
  fi
  _cw_confirm_and_write "reg_infuse_in" "preview_infuse_in"
}

_cw_infuse_out() {
  dbg_enter "_cw_infuse_out"
  section "Infusion OUTPUT"

  while true; do
    _ask_infuse_out
    ask_bool "  Ajouter un autre matériau ?" || break
  done

  if [[ ${#INFUSE_OUT_MATS[@]} -eq 0 ]]; then
    warn "Aucune recette — annulé."
    exit 0
  fi
  _cw_confirm_and_write "reg_infuse_out" "preview_infuse_out"
}

_cw_hint() {
  dbg_enter "_cw_hint"
  section "Hint d'infusion"
  _ask_infuse_hint

  if [[ ${#INFUSE_H_KEY[@]} -eq 0 ]]; then
    warn "Aucun hint — annulé."
    exit 0
  fi
  _cw_confirm_and_write "reg_infuse_hints_and_new" "preview_infuse_hints"
}

_cw_fuse() {
  dbg_enter "_cw_fuse"
  ask_fuse
  if [[ $FUSE_ENABLED -eq 0 ]]; then
    echo "Annulé."
    exit 0
  fi
  _cw_confirm_and_write "reg_fuse" "preview_fuse"
}

_cw_forge() {
  dbg_enter "_cw_forge"
  ask_forge
  if [[ $FORGE_ENABLED -eq 0 ]]; then
    echo "Annulé."
    exit 0
  fi
  _cw_confirm_and_write "reg_forge" "preview_forge"
}

_cw_confirm_and_write() {
  local reg_fn="$1" preview_fn="$2"
  dbg "_cw_confirm_and_write reg=${reg_fn} preview=${preview_fn}"

  echo ""
  echo "╔══ Aperçu ════════════════════════════════════════"
  "$preview_fn"
  echo "╚══════════════════════════════════════════════════"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo ""
    info "Mode dry-run — aucun fichier modifié."
    return 0
  fi

  echo ""
  ask_bool "Confirmer ?" o || { echo "Annulé."; exit 0; }

  backup_files
  trap rollback ERR
  echo ""

  dbg "Appel ${reg_fn}"
  "$reg_fn"

  trap - ERR
  cleanup_backups
  echo ""
}

preview_infuse_hints() {
  for i in "${!INFUSE_H_SRC[@]}"; do
    info "[INFUSE HINT] ${INFUSE_H_SRC[$i]}[\"${INFUSE_H_MAT[$i]}\"] → ${INFUSE_H_KEY[$i]}"
  done
  for i in "${!NEW_HINT_KEY[@]}"; do
    info "[NEW HINT]    ${NEW_HINT_KEY[$i]} = \"${NEW_HINT_MSG[$i]}\""
  done
}

reg_infuse_hints_and_new() {
  reg_infuse_hints
  reg_new_hints
}
