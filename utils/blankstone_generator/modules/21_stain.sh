#!/usr/bin/env bash
# modules/21_stain.sh — effet de teinture sur le joueur (staining.xml)

register_module "stain"

STAIN_ENABLED=0
STAIN_MAT=""
STAIN_INT="32"

ask_stain() {
  ask_bool "Staining (teindre le joueur d'un matériau) ?" && STAIN_ENABLED=1 || { STAIN_ENABLED=0; return 0; }
  STAIN_MAT=$(ask "  Matériau (ex: poison, water)")
  STAIN_INT=$(ask "  Intensité" "32")
}

xml_stain() {
  if [[ $STAIN_ENABLED -eq 0 ]]; then return 0; fi
  cat <<XML


  <!-- Stain effect -->
  <Base file="${MOD_PATH}/entities/staining.xml">
    <VariableStorageComponent
      name="stain_effect"
      value_string="${STAIN_MAT}"
      value_int="${STAIN_INT}"
    ></VariableStorageComponent>
  </Base>
XML
}

reg_stain()     { :; }
preview_stain() {
  if [[ $STAIN_ENABLED -eq 0 ]]; then return 0; fi
  info "Stain : ${STAIN_MAT} (intensité ${STAIN_INT})"
}
