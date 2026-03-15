#!/usr/bin/env bash
# modules/10_vfx_halo.sh — halo(s) lumineux (supporte plusieurs emitters)

register_module "vfx_halo"

HALO_RS=(); HALO_GS=(); HALO_BS=(); HALO_AS=()

ask_vfx_halo() {
  section "VFX"
  while ask_bool "Halo lumineux ?"; do
    echo "  Couleur RGBA (0.0–1.0, ex: 0.3 0.8 0.3 0.25)"
    read -rp "  r g b a > " _r _g _b _a
    HALO_RS+=("${_r:-0.5}"); HALO_GS+=("${_g:-0.5}")
    HALO_BS+=("${_b:-0.5}"); HALO_AS+=("${_a:-0.25}")
  done
}

xml_vfx_halo() {
  if [[ ${#HALO_RS[@]} -eq 0 ]]; then return 0; fi
  for i in "${!HALO_RS[@]}"; do
    cat <<XML

  <!-- VFX — Halo #$((i+1)) -->
  <Base file="${MOD_PATH}/VFX/halo.xml">
    <SpriteParticleEmitterComponent
      color.r="${HALO_RS[$i]}" color.g="${HALO_GS[$i]}" color.b="${HALO_BS[$i]}" color.a="${HALO_AS[$i]}"
      color_change.r="0" color_change.g="0" color_change.b="0" color_change.a="-1.5"
      additive="1"
      emissive="1"
    ></SpriteParticleEmitterComponent>
  </Base>
XML
  done
}

reg_vfx_halo() { :; }

preview_vfx_halo() {
  for i in "${!HALO_RS[@]}"; do
    info "VFX halo #$((i+1)) : rgba(${HALO_RS[$i]}, ${HALO_GS[$i]}, ${HALO_BS[$i]}, ${HALO_AS[$i]})"
  done
}
