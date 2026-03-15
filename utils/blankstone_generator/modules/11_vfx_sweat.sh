#!/usr/bin/env bash
# modules/11_vfx_sweat.sh — particules de "sueur" (matériau drainé en boucle)
# Supporte plusieurs emitters.

register_module "vfx_sweat"

SWEAT_MATS=()
SWEAT_CMINS=()
SWEAT_CMAXS=()

ask_vfx_sweat() {
  # Pas de section header : même groupe VFX que halo
  while ask_bool "Sweat emitter (particules de matériau) ?"; do
    local mat; mat=$(ask "  Matériau émis (ex: water, poison)")
    local cmin; cmin=$(ask "  count_min" "2")
    local cmax; cmax=$(ask "  count_max" "5")
    SWEAT_MATS+=("$mat"); SWEAT_CMINS+=("$cmin"); SWEAT_CMAXS+=("$cmax")
  done
}

xml_vfx_sweat() {
  if [[ ${#SWEAT_MATS[@]} -eq 0 ]]; then return 0; fi
  for i in "${!SWEAT_MATS[@]}"; do
    cat <<XML

  <Base file="${MOD_PATH}/VFX/sweat.xml">
    <ParticleEmitterComponent
      emitted_material_name="${SWEAT_MATS[$i]}"
      count_min="${SWEAT_CMINS[$i]}"
      count_max="${SWEAT_CMAXS[$i]}"
    ></ParticleEmitterComponent>
  </Base>
XML
  done
}

reg_vfx_sweat()     { :; }
preview_vfx_sweat() {
  for i in "${!SWEAT_MATS[@]}"; do
    info "VFX sweat #$((i+1)) : ${SWEAT_MATS[$i]} (${SWEAT_CMINS[$i]}–${SWEAT_CMAXS[$i]})"
  done
}
