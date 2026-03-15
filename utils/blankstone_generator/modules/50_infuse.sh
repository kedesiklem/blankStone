#!/usr/bin/env bash
# modules/50_infuse.sh — infuse_registry.lua + hint_registry.lua
#
# Gère trois types d'entrées :
#   - Recettes INPUT  : autre pierre + matériau → cette pierre
#   - Recettes OUTPUT : cette pierre + matériau → autre(s) pierre(s)
#   - Hints           : matériau → message (sans produire de pierre)
#
# Les recettes OUTPUT déduisent automatiquement STONE_INFUSABLE=1.
# _ensure_infusable() vérifie/patche le XML de toute pierre source INPUT.

register_module "infuse"

# ── Variables ──────────────────────────────────────────────────────────────────

# INPUT : autre pierre → cette pierre
INFUSE_R_SRC=()
INFUSE_R_MAT=()

# OUTPUT : cette pierre → autre(s) pierre(s)
INFUSE_OUT_MATS=()
INFUSE_OUT_KEYS=()   # "key1,key2,..." par recette

# Hints
INFUSE_H_SRC=()
INFUSE_H_MAT=()
INFUSE_H_KEY=()

# Nouveaux hints à créer dans hint_registry.lua
NEW_HINT_KEY=()
NEW_HINT_MSG=()

INFUSE_ENABLED=0

# ── Wizard ─────────────────────────────────────────────────────────────────────
ask_infuse() {
  INFUSE_ENABLED=0
  ask_bool "Ajouter des recettes d'infusion ?" || return 0
  INFUSE_ENABLED=1

  section "Infusions"
  echo "  Pierres disponibles :"
  list_stones | pr -3 -t | sed 's/^/    /'
  echo ""

  while true; do
    echo "  Type :"
    echo "    [1] INPUT  — autre pierre + matériau → cette pierre"
    echo "    [2] OUTPUT — cette pierre + matériau → autre(s) pierre(s)"
    echo "    [3] Hint   — matériau → message (sans produire de pierre)"
    echo "    [vide] Terminer"
    read -rp "  > " _dir
    [[ -z "$_dir" ]] && break

    case "$_dir" in
      1) _ask_infuse_in  ;;
      2) _ask_infuse_out ;;
      3) _ask_infuse_hint ;;
      *) echo "  → 1, 2, 3 ou vide" ;;
    esac
  done
}

_ask_infuse_in() {
  local src; src=$(ask "    Source stone (ex: blankStone)")
  if [[ -z "$src" ]]; then return 0; fi
  while true; do
    local mat; mat=$(ask "    + Matériau (vide pour terminer)" "")
    [[ -z "$mat" ]] && break
    INFUSE_R_SRC+=("$src")
    INFUSE_R_MAT+=("$mat")
  done
}

_ask_infuse_out() {
  local mat; mat=$(ask "    Matériau déclencheur")
  if [[ -z "$mat" ]]; then return 0; fi
  local keys=""
  while true; do
    local k; k=$(ask "    + Pierre produite (vide pour terminer)" "")
    [[ -z "$k" ]] && break
    keys="${keys:+${keys},}${k}"
  done
  if [[ -z "$keys" ]]; then
    warn "  Aucune pierre produite — ignoré"
    return 0
  fi
  INFUSE_OUT_MATS+=("$mat")
  INFUSE_OUT_KEYS+=("$keys")
  STONE_INFUSABLE=1   # déduit directement
}

_ask_infuse_hint() {
  echo "    Hints existants :"
  list_hints | pr -3 -t | sed 's/^/      /'
  echo ""
  local src; src=$(ask "    Source stone" "blankStone")
  local mat; mat=$(ask "    Matériau déclencheur")
  local hkey; hkey=$(ask "    Clé du hint (ex: hint_blankstone_useless)")
  INFUSE_H_SRC+=("$src")
  INFUSE_H_MAT+=("$mat")
  INFUSE_H_KEY+=("$hkey")
  if ! hint_exists "$hkey"; then
    warn "  '${hkey}' n'existe pas dans hint_registry.lua"
    if ask_bool "  Créer ce hint maintenant ?"; then
      local hmsg; hmsg=$(ask "  Clé i18n du message")
      NEW_HINT_KEY+=("$hkey")
      NEW_HINT_MSG+=("$hmsg")
    fi
  fi
}

# ── XML ────────────────────────────────────────────────────────────────────────
xml_infuse() { :; }

# ── Registres ──────────────────────────────────────────────────────────────────

reg_infuse() {
  dbg_enter "reg_infuse"
  if [[ $INFUSE_ENABLED -eq 0 ]]; then return 0; fi
  reg_infuse_in
  reg_infuse_out
  reg_new_hints
}

# Registre INPUT : vérifie infusabilité de la source puis insère
reg_infuse_in() {
  dbg_enter "reg_infuse_in"
  if [[ ${#INFUSE_R_SRC[@]} -eq 0 ]]; then return 0; fi
  if [[ ! -f "$INFUSE_REGISTRY_FILE" ]]; then
    warn "INFUSE → introuvable, ajouter manuellement infuse_registry.lua"
    return 0
  fi

  # Vérification d'infusabilité sur toutes les sources uniques
  local _seen_src=()
  for src in "${INFUSE_R_SRC[@]}"; do
    [[ "$src" == "blankStone" ]] && continue
    local _dup=0
    for _s in "${_seen_src[@]:-}"; do [[ "$_s" == "$src" ]] && _dup=1 && break; done
    if [[ $_dup -eq 0 ]]; then _seen_src+=("$src"); _ensure_infusable "$src"; fi
  done

  for i in "${!INFUSE_R_SRC[@]}"; do
    local src="${INFUSE_R_SRC[$i]}" mat="${INFUSE_R_MAT[$i]}"
    local line="        [\"${mat}\"] = {stone_keys = {\"${STONE_NAME}\"}},"
    if [[ "$src" == "blankStone" ]]; then
      if grep -qF -- "-- HINT" "$INFUSE_REGISTRY_FILE"; then
        insert_before "$INFUSE_REGISTRY_FILE" "^        -- HINT" "$line"
      else
        insert_before "$INFUSE_REGISTRY_FILE" "$ANCHOR_INFUSE_END" "$line"
      fi
    else
      _insert_infuse_entry "$src" "$line"
    fi
  done
  ok "INFUSE IN  → infuse_registry.lua"
}

# Registre OUTPUT : crée le bloc [CettePierre] dans infuse_registry
reg_infuse_out() {
  dbg_enter "reg_infuse_out"
  if [[ ${#INFUSE_OUT_MATS[@]} -eq 0 ]]; then return 0; fi
  if [[ ! -f "$INFUSE_REGISTRY_FILE" ]]; then
    warn "INFUSE_OUT → introuvable, ajouter manuellement infuse_registry.lua"
    return 0
  fi

  if infuse_source_exists "$STONE_NAME"; then
    warn "INFUSE_OUT → bloc [\"${STONE_NAME}\"] déjà présent dans infuse_registry, ignoré"
    return 0
  fi

  local lines=""
  for i in "${!INFUSE_OUT_MATS[@]}"; do
    local keys_lua=""
    IFS=',' read -ra _keys <<< "${INFUSE_OUT_KEYS[$i]}"
    for k in "${_keys[@]}"; do
      keys_lua="${keys_lua:+${keys_lua}, }\"${k}\""
    done
    lines+="        [\"${INFUSE_OUT_MATS[$i]}\"] = {stone_keys = {${keys_lua}}},
"
  done

  local block
  block="    [\"${STONE_NAME}\"] = {
${lines}    },"
  insert_before "$INFUSE_REGISTRY_FILE" "$ANCHOR_INFUSE_END" "$block"
  ok "INFUSE OUT → infuse_registry.lua ([\"${STONE_NAME}\"] +${#INFUSE_OUT_MATS[@]} recette(s))"
}

# Hints dans infuse_registry
reg_infuse_hints() {
  dbg_enter "reg_infuse_hints"
  if [[ ${#INFUSE_H_SRC[@]} -eq 0 ]]; then return 0; fi
  for i in "${!INFUSE_H_SRC[@]}"; do
    local src="${INFUSE_H_SRC[$i]}" mat="${INFUSE_H_MAT[$i]}" hkey="${INFUSE_H_KEY[$i]}"
    local line="        [\"${mat}\"] = {hint_key = \"${hkey}\"},"
    if [[ "$src" == "blankStone" ]]; then
      insert_before "$INFUSE_REGISTRY_FILE" "$ANCHOR_INFUSE_END" "$line"
    else
      _insert_infuse_entry "$src" "$line"
    fi
  done
  ok "INFUSE HINT → infuse_registry.lua"
}

# Nouveaux hints dans hint_registry.lua
reg_new_hints() {
  dbg_enter "reg_new_hints"
  reg_infuse_hints
  if [[ ${#NEW_HINT_KEY[@]} -eq 0 ]]; then return 0; fi
  if [[ ! -f "$HINT_REGISTRY_FILE" ]]; then
    warn "HINT → introuvable, ajouter manuellement hint_registry.lua"
    for i in "${!NEW_HINT_KEY[@]}"; do
      echo "    [\"${NEW_HINT_KEY[$i]}\"] = { message = \"${NEW_HINT_MSG[$i]}\" },"
    done
    return 0
  fi
  for i in "${!NEW_HINT_KEY[@]}"; do
    local hkey="${NEW_HINT_KEY[$i]}" hmsg="${NEW_HINT_MSG[$i]}"
    if hint_exists "$hkey"; then warn "HINT → '${hkey}' déjà présent, ignoré"; continue; fi
    local entry
    entry="    [\"${hkey}\"] = {
        message = \"${hmsg}\",
    },"
    insert_before "$HINT_REGISTRY_FILE" "$ANCHOR_HINT_END" "$entry"
    ok "HINT       → hint_registry.lua (+${hkey})"
  done
}

# ── Helpers d'insertion ────────────────────────────────────────────────────────

# Insère une ligne dans le bloc [source] de infuse_registry.
# Crée le bloc si absent. Avertit si la source est inconnue.
_insert_infuse_entry() {
  dbg_enter "_insert_infuse_entry (src=$1)"
  local src="$1" line="$2"
  if infuse_source_exists "$src"; then
    insert_after "$INFUSE_REGISTRY_FILE" "\[\"${src}\"\] = {" "$line"
  elif stone_exists "$src"; then
    local block
    block="    [\"${src}\"] = {
${line}
    },"
    insert_before "$INFUSE_REGISTRY_FILE" "$ANCHOR_INFUSE_END" "$block"
    info "  (bloc [\"${src}\"] créé dans infuse_registry)"
  else
    warn "INFUSE → source \"${src}\" introuvable dans stone_registry — à ajouter manuellement :"
    echo "    [\"${src}\"] = { ${line} },"
  fi
}

# Vérifie que la pierre source possède infusable.xml dans son XML.
# Si absent : backup + patch automatique + notification.
_ensure_infusable() {
  dbg_enter "_ensure_infusable ($1)"
  local src="$1"
  local fid; fid="$(to_file_id "${src}")"
  local xml_path="${MOD_ROOT}/files/entities/elemental_stone/${fid}.xml"

  if [[ ! -f "$xml_path" ]]; then
    warn "INFUSE → ${src} : XML introuvable (${fid}.xml) — vérifier manuellement l'infusabilité"
    return 0
  fi
  if grep -qF -- "infusable.xml" "$xml_path"; then return 0; fi

  # Pas infusable → patch
  BACKUP_FILES+=("$xml_path")
  cp "$xml_path" "${xml_path}.bak"
  local infusable_line="  <Base file=\"${MOD_PATH}/entities/infusable.xml\" include_children=\"1\" />"
  insert_after "$xml_path" "^  </Base>" "$infusable_line"
  warn "INFUSE → ${src} n'était pas infusable — infusable.xml ajouté dans ${fid}.xml"
}

# ── Preview ────────────────────────────────────────────────────────────────────
preview_infuse() {
  if [[ $INFUSE_ENABLED -eq 0 ]]; then return 0; fi
  preview_infuse_in
  preview_infuse_out
  for i in "${!INFUSE_H_SRC[@]}"; do
    info "[INFUSE HINT] ${INFUSE_H_SRC[$i]}[\"${INFUSE_H_MAT[$i]}\"] → ${INFUSE_H_KEY[$i]}"
  done
  for i in "${!NEW_HINT_KEY[@]}"; do
    info "[NEW HINT]    ${NEW_HINT_KEY[$i]} = \"${NEW_HINT_MSG[$i]}\""
  done
}

preview_infuse_in() {
  if [[ ${#INFUSE_R_SRC[@]} -eq 0 ]]; then return 0; fi
  for i in "${!INFUSE_R_SRC[@]}"; do
    local src="${INFUSE_R_SRC[$i]}"
    local note=""
    if [[ "$src" != "blankStone" ]]; then
      local fid; fid="$(to_file_id "$src")"
      local xp="${MOD_ROOT}/files/entities/elemental_stone/${fid}.xml"
      if [[ ! -f "$xp" ]]; then
        note="  ⚠ XML introuvable"
      elif ! grep -qF -- "infusable.xml" "$xp"; then
        note="  → infusable.xml sera ajouté"
      fi
    fi
    info "[INFUSE IN]  ${src}[\"${INFUSE_R_MAT[$i]}\"] → \"${STONE_NAME}\"${note}"
  done
}

preview_infuse_out() {
  if [[ ${#INFUSE_OUT_MATS[@]} -eq 0 ]]; then return 0; fi
  for i in "${!INFUSE_OUT_MATS[@]}"; do
    info "[INFUSE OUT] ${STONE_NAME}[\"${INFUSE_OUT_MATS[$i]}\"] → {${INFUSE_OUT_KEYS[$i]}}"
  done
  info "  → pierre marquée infusable automatiquement"
}

todo_infuse() {
  for i in "${!NEW_HINT_KEY[@]}"; do
    echo "  • Traduire le hint dans translations.csv : ${NEW_HINT_MSG[$i]}"
  done
}
