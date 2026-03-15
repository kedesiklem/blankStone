#!/usr/bin/env bash
# modules/20_game_effect.sh — GameEffectComponent passif (ex: PROTECTION_FIRE)
# Supporte plusieurs effets.

register_module "game_effect"

GAME_EFFECTS=()        # noms des effets
GAME_EFFECT_TAGS=()    # _tags pour chaque effet

ask_game_effect() {
  section "Effets passifs"
  while ask_bool "Ajouter un GameEffect (ex: PROTECTION_FIRE) ?"; do
    local eff; eff=$(ask "  Nom de l'effet")
    local tags; tags=$(ask "  _tags" "enabled_in_hand,enabled_in_inventory")
    GAME_EFFECTS+=("$eff"); GAME_EFFECT_TAGS+=("$tags")
  done
}

xml_game_effect() {
  if [[ ${#GAME_EFFECTS[@]} -eq 0 ]]; then return 0; fi
  for i in "${!GAME_EFFECTS[@]}"; do
    cat <<XML


  <!-- Effet passif -->
  <GameEffectComponent
    _tags="${GAME_EFFECT_TAGS[$i]}"
    effect="${GAME_EFFECTS[$i]}"
    frames="-1"
  ></GameEffectComponent>
XML
  done
}

reg_game_effect()     { :; }
preview_game_effect() {
  for i in "${!GAME_EFFECTS[@]}"; do
    info "GameEffect : ${GAME_EFFECTS[$i]}  tags=${GAME_EFFECT_TAGS[$i]}"
  done
}
