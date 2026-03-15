#!/usr/bin/env bash
# modules/22_mat_immunity.sh — immunité à un matériau (material_immunity_stone.lua)

register_module "mat_immunity"

MAT_IMMUNITY_ENABLED=0
MAT_IMMUNITY_MAT=""
MAT_IMMUNITY_DMG="0.0"

ask_mat_immunity() {
  ask_bool "Immunité matériau (ex: immunité à la lave) ?" && MAT_IMMUNITY_ENABLED=1 || { MAT_IMMUNITY_ENABLED=0; return 0; }
  MAT_IMMUNITY_MAT=$(ask "  protected_material (ex: lava, poison)")
  MAT_IMMUNITY_DMG=$(ask "  new_material_dmg (0.0 = aucun dégât)" "0.0")
}

xml_mat_immunity() {
  if [[ $MAT_IMMUNITY_ENABLED -eq 0 ]]; then return 0; fi
  cat <<XML


  <!-- === MATERIAL IMMUNITY ======== -->
  <LuaComponent
    _tags="enabled_in_hand,enabled_in_inventory"
    script_source_file="${MOD_PATH}/scripts/status_effects/material_immunity_stone.lua"
    execute_every_n_frame="30"
  ></LuaComponent>

  <!-- Required -->
  <VariableStorageComponent
    name="protected_material"
    value_string="${MAT_IMMUNITY_MAT}"
  ></VariableStorageComponent>

  <!-- Optional : Default value = 0.0 -->
  <VariableStorageComponent
    name="new_material_dmg"
    value_string="${MAT_IMMUNITY_DMG}"
  ></VariableStorageComponent>
  <!-- ============================== -->
XML
}

reg_mat_immunity()     { :; }
preview_mat_immunity() {
  if [[ $MAT_IMMUNITY_ENABLED -eq 0 ]]; then return 0; fi
  info "Material immunity : ${MAT_IMMUNITY_MAT} → dmg=${MAT_IMMUNITY_DMG}"
}
