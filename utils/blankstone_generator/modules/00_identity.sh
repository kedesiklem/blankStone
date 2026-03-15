#!/usr/bin/env bash
# modules/00_identity.sh — identité de la pierre (REQUIS)
# Exporte STONE_NAME et STONE_FILE_ID utilisés par tous les autres modules.

register_module "identity"

# ── Variables exportées ────────────────────────────────────────────────────────
STONE_NAME=""
STONE_FILE_ID=""
STONE_FORGEABLE=0
STONE_INFUSABLE=0   # mis à 1 automatiquement par 50_infuse si recette OUTPUT définie
STONE_PURIFY_INTO=""
_PURIFY_DEFAULT="${MOD_PATH}/entities/blank_stone.xml"

# ── Wizard ─────────────────────────────────────────────────────────────────────
ask_identity() {
  dbg_enter "ask_identity"
  section "Identité"

  local raw_id
  raw_id=$(ask "ID de la pierre  (snake_case, sans 'stone_', ex: magic_fire)")
  if [[ -z "$raw_id" ]]; then
    fail "ID requis."
    exit 1
  fi

  STONE_NAME="$(to_camel "$raw_id")"
  STONE_FILE_ID="$(to_file_id "$STONE_NAME")"

  info "Entité  : ${STONE_NAME}"
  info "Fichier : ${STONE_FILE_ID}.xml"

  if stone_exists "$STONE_NAME"; then
    warn "${STONE_NAME} est déjà dans stone_registry.lua"
    ask_bool "  Continuer quand même ?" || { echo "Annulé."; exit 0; }
  fi

  echo ""
  ask_bool "Forgeable (tag 'forgeable' sur l'entité) ?" && STONE_FORGEABLE=1 || STONE_FORGEABLE=0

  STONE_PURIFY_INTO="$_PURIFY_DEFAULT"
  if ask_bool "Cible de purification personnalisée ? (défaut : blank_stone)"; then
    STONE_PURIFY_INTO="$(ask "  Chemin complet" "$_PURIFY_DEFAULT")"
  fi
}

# ── XML ────────────────────────────────────────────────────────────────────────
xml_identity() {
  dbg_enter "xml_identity"
  local tags=""
  if [[ $STONE_FORGEABLE -eq 1 ]]; then tags=' tags="forgeable"'; fi

  cat <<XML
<Entity name="${STONE_NAME}"${tags}>

  <Base file="${MOD_PATH}/entities/elemental_stone.xml">
    <PhysicsImageShapeComponent
      image_file="${MOD_PATH}/items_gfx/elemental_stone/${STONE_FILE_ID}.png"
    ></PhysicsImageShapeComponent>

    <SpriteComponent
      image_file="${MOD_PATH}/items_gfx/elemental_stone/${STONE_FILE_ID}.png"
    ></SpriteComponent>

    <ItemComponent
      item_name="\$stone_blankstone_${STONE_NAME}_name"
      ui_description="\$stone_blankstone_${STONE_NAME}_desc"
      ui_sprite="${MOD_PATH}/ui_gfx/elemental_stone/${STONE_FILE_ID}.png"
    ></ItemComponent>

    <UIInfoComponent
      name="\$stone_blankstone_${STONE_NAME}_name"
    ></UIInfoComponent>

    <AbilityComponent
      ui_name="\$stone_blankstone_${STONE_NAME}_name"
    ></AbilityComponent>
XML

  if [[ "$STONE_PURIFY_INTO" != "$_PURIFY_DEFAULT" ]]; then
    cat <<XML

    <VariableStorageComponent
      name="purifyInto"
      value_string="${STONE_PURIFY_INTO}"
    ></VariableStorageComponent>
XML
  fi

  echo ""
  echo "  </Base>"

  if [[ $STONE_INFUSABLE -eq 1 ]]; then
    cat <<XML

  <Base file="${MOD_PATH}/entities/infusable.xml" include_children="1" />
XML
  fi
}

reg_identity() { :; }
