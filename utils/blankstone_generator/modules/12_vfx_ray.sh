#!/usr/bin/env bash
# modules/12_vfx_ray.sh — rayon(s) de particules (supporte plusieurs emitters)

register_module "vfx_ray"

RAY_RS=(); RAY_GS=(); RAY_BS=(); RAY_MINS=(); RAY_MAXS=()

ask_vfx_ray() {
  while ask_bool "Ray emitter (rayons de lumière) ?"; do
    echo "  Couleur RGB (0.0–1.0, ex: 0.7 0.0 0.3)"
    read -rp "  r g b > " _r _g _b
    RAY_RS+=("${_r:-0.5}"); RAY_GS+=("${_g:-0.5}"); RAY_BS+=("${_b:-0.5}")
    RAY_MINS+=("$(ask "  count_min" "2")")
    RAY_MAXS+=("$(ask "  count_max" "5")")
  done
}

xml_vfx_ray() {
  if [[ ${#RAY_RS[@]} -eq 0 ]]; then return 0; fi
  for i in "${!RAY_RS[@]}"; do
    cat <<XML

  <Base file="${MOD_PATH}/VFX/ray.xml">
    <SpriteParticleEmitterComponent
      color.r="${RAY_RS[$i]}" color.g="${RAY_GS[$i]}" color.b="${RAY_BS[$i]}"
      count_min="${RAY_MINS[$i]}"
      count_max="${RAY_MAXS[$i]}"
    ></SpriteParticleEmitterComponent>
  </Base>
XML
  done
}

reg_vfx_ray() { :; }

preview_vfx_ray() {
  for i in "${!RAY_RS[@]}"; do
    info "VFX ray #$((i+1)) : rgb(${RAY_RS[$i]}, ${RAY_GS[$i]}, ${RAY_BS[$i]}) cnt ${RAY_MINS[$i]}–${RAY_MAXS[$i]}"
  done
}
