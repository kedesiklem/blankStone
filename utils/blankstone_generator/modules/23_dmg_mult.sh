#!/usr/bin/env bash
# modules/23_dmg_mult.sh — multiplicateur d'un type de dégâts (damage_type_multiplier_stone.lua)

register_module "dmg_mult"

DMG_MULT_ENABLED=0
DMG_MULT_TYPE=""
DMG_MULT_VAL="0.0"

ask_dmg_mult() {
  ask_bool "Multiplicateur de type de dégâts (ex: réduction feu) ?" && DMG_MULT_ENABLED=1 || { DMG_MULT_ENABLED=0; return 0; }
  DMG_MULT_TYPE=$(ask "  protected_damage_type (ex: fire, explosion, melee)")
  DMG_MULT_VAL=$(ask "  new_mult (0.0 = immunité, 1.0 = normal, 2.0 = double)" "0.0")
}

xml_dmg_mult() {
  if [[ $DMG_MULT_ENABLED -eq 0 ]]; then return 0; fi
  cat <<XML


  <!-- === DAMAGE TYPE MULTIPLIER === -->
  <LuaComponent
    _tags="enabled_in_hand,enabled_in_inventory"
    script_source_file="${MOD_PATH}/scripts/status_effects/damage_type_multiplier_stone.lua"
    execute_every_n_frame="30"
  ></LuaComponent>

  <!-- Required -->
  <VariableStorageComponent
    name="protected_damage_type"
    value_string="${DMG_MULT_TYPE}"
  ></VariableStorageComponent>

  <!-- Optional : Default value = 0.0 -->
  <VariableStorageComponent
    name="new_mult"
    value_float="${DMG_MULT_VAL}"
  ></VariableStorageComponent>
  <!-- ============================== -->
XML
}

reg_dmg_mult()     { :; }
preview_dmg_mult() {
  if [[ $DMG_MULT_ENABLED -eq 0 ]]; then return 0; fi
  info "Dmg multiplier : type=${DMG_MULT_TYPE} → mult=${DMG_MULT_VAL}"
}
