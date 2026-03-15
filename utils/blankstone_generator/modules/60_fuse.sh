#!/usr/bin/env bash
# modules/60_fuse.sh — fuse_registry.lua (recette de fusion)
#
# Format ingrédient/catalyst : name:NomPierre:quantité  ou  tag:expression:quantité
#   ex: name:voidStone:1    tag:brimstone|thunderstone:2
# Les résultats incluent toujours cette pierre + éventuellement d'autres.

register_module "fuse"

FUSE_ENABLED=0
FUSE_ING_TYPE=(); FUSE_ING_VAL=(); FUSE_ING_CNT=()   # ingrédients
FUSE_CAT_TYPE=(); FUSE_CAT_VAL=(); FUSE_CAT_CNT=()   # catalyseurs (optionnel)
FUSE_EXTRA_RESULTS=()   # clés de pierres supplémentaires dans results (hors cette pierre)
FUSE_RADIUS="20"
FUSE_MSG_TITLE=""
FUSE_MSG_DESC=""

# ── Wizard ─────────────────────────────────────────────────────────────────────
ask_fuse() {
  FUSE_ENABLED=0
  ask_bool "Recette de fusion (fuse_registry) ?" || return 0
  FUSE_ENABLED=1

  section "fuse_registry.lua"

  echo "  Pierres disponibles :"
  list_stones | pr -3 -t | sed 's/^/    /'
  echo ""
  echo "  Format ingrédient/catalyst : name:NomPierre:quantité  ou  tag:expression:quantité"
  echo "  Exemples : name:voidStone:1   tag:brimstone|thunderstone:2"
  echo ""

  # Ingrédients
  echo "  — Ingrédients (vide pour terminer) :"
  while true; do
    local raw; raw=$(ask "  + Ingrédient" ""); [[ -z "$raw" ]] && break
    _parse_fuse_entry "$raw" FUSE_ING_TYPE FUSE_ING_VAL FUSE_ING_CNT
  done

  # Catalyseurs (optionnel)
  echo ""
  echo "  — Catalyseurs (optionnel, vide pour terminer) :"
  while true; do
    local raw; raw=$(ask "  + Catalyst" ""); [[ -z "$raw" ]] && break
    _parse_fuse_entry "$raw" FUSE_CAT_TYPE FUSE_CAT_VAL FUSE_CAT_CNT
  done

  # Résultats supplémentaires (en plus de cette pierre)
  echo ""
  echo "  — Résultats supplémentaires produits (ex: blankStone comme sous-produit) :"
  while true; do
    local extra; extra=$(ask "  + Clé pierre supplémentaire" ""); [[ -z "$extra" ]] && break
    FUSE_EXTRA_RESULTS+=("$extra")
  done

  FUSE_RADIUS=$(ask "Radius de détection" "20")

  # Message optionnel
  if ask_bool "Message custom lors de la fusion ?"; then
    FUSE_MSG_TITLE=$(ask "  Clé titre (\$text_blankstone_...)" "")
    FUSE_MSG_DESC=$(ask "  Clé desc  (\$text_blankstone_...)" "")
  fi
}

# Parse "name:val:count" ou "tag:val:count" et appende aux tableaux donnés
_parse_fuse_entry() {
  local raw="$1"
  local -n _type_arr=$2 _val_arr=$3 _cnt_arr=$4
  local t v c
  IFS=':' read -r t v c <<< "$raw"
  _type_arr+=("$t")
  _val_arr+=("$v")
  _cnt_arr+=("${c:-1}")
}

# ── XML ────────────────────────────────────────────────────────────────────────
xml_fuse() { :; }

# ── Registre ───────────────────────────────────────────────────────────────────
reg_fuse() {
  if [[ $FUSE_ENABLED -eq 0 ]]; then return 0; fi
  if [[ ${#FUSE_ING_TYPE[@]} -eq 0 ]]; then warn "FUSE → aucun ingrédient, ignoré"; return 0; fi

  if [[ ! -f "$FUSE_REGISTRY_FILE" ]]; then
    warn "FUSE → introuvable, ajouter manuellement dans fuse_registry.lua"
    return 0
  fi

  # Construction du bloc Lua
  local ing_block=""
  for i in "${!FUSE_ING_TYPE[@]}"; do
    ing_block+="            { ${FUSE_ING_TYPE[$i]} = \"${FUSE_ING_VAL[$i]}\", count = ${FUSE_ING_CNT[$i]} },
"
  done

  local cat_block=""
  if [[ ${#FUSE_CAT_TYPE[@]} -gt 0 ]]; then
    local cat_lines=""
    for i in "${!FUSE_CAT_TYPE[@]}"; do
      cat_lines+="            { ${FUSE_CAT_TYPE[$i]} = \"${FUSE_CAT_VAL[$i]}\", count = ${FUSE_CAT_CNT[$i]} },
"
    done
    cat_block="        catalysts = {
${cat_lines}        },
"
  fi

  local results_block="            { key = \"${STONE_NAME}\", offset_y = -10 },
"
  for extra in "${FUSE_EXTRA_RESULTS[@]}"; do
    results_block+="            { key = \"${extra}\", offset_y = -10 },
"
  done

  local msg_block=""
  if [[ -n "$FUSE_MSG_TITLE" ]]; then
    msg_block="        message = {
            title = \"${FUSE_MSG_TITLE}\",
            desc  = \"${FUSE_MSG_DESC}\",
        },
"
  fi

  local entry
  entry="    { -- ${STONE_NAME}
        ingredients = {
${ing_block}        },
${cat_block}        radius = ${FUSE_RADIUS},
        results = {
${results_block}        },
${msg_block}        on_success = function() end
    },"

  insert_before "$FUSE_REGISTRY_FILE" "$ANCHOR_FUSE_END" "$entry"
  ok "FUSE     → fuse_registry.lua"
}

# ── Preview ────────────────────────────────────────────────────────────────────
preview_fuse() {
  if [[ $FUSE_ENABLED -eq 0 ]]; then return 0; fi
  # Validation : vérifier que les pierres par name existent
  for i in "${!FUSE_ING_TYPE[@]}"; do
    if [[ "${FUSE_ING_TYPE[$i]}" == "name" ]] && ! stone_exists "${FUSE_ING_VAL[$i]}"; then
      warn "[FUSE] ingrédient introuvable dans stone_registry : ${FUSE_ING_VAL[$i]}"
    fi
  done
  for i in "${!FUSE_CAT_TYPE[@]}"; do
    if [[ "${FUSE_CAT_TYPE[$i]}" == "name" ]] && ! stone_exists "${FUSE_CAT_VAL[$i]}"; then
      warn "[FUSE] catalyst introuvable dans stone_registry : ${FUSE_CAT_VAL[$i]}"
    fi
  done
  for extra in "${FUSE_EXTRA_RESULTS[@]}"; do
    if ! stone_exists "$extra"; then
      warn "[FUSE] résultat supplémentaire introuvable : ${extra}"
    fi
  done
  local ing_str=""
  for i in "${!FUSE_ING_TYPE[@]}"; do
    ing_str+="${FUSE_ING_TYPE[$i]}:${FUSE_ING_VAL[$i]}×${FUSE_ING_CNT[$i]}  "
  done
  info "[FUSE] ing: ${ing_str% }"
  if [[ ${#FUSE_CAT_TYPE[@]} -gt 0 ]]; then
    local cat_str=""
    for i in "${!FUSE_CAT_TYPE[@]}"; do
      cat_str+="${FUSE_CAT_TYPE[$i]}:${FUSE_CAT_VAL[$i]}×${FUSE_CAT_CNT[$i]}  "
    done
    info "       cat: ${cat_str% }"
  fi
  local res_str="${STONE_NAME}"
  for e in "${FUSE_EXTRA_RESULTS[@]}"; do res_str+=", ${e}"; done
  info "       r=${FUSE_RADIUS}  → ${res_str}"
}
