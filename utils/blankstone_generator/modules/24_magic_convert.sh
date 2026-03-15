#!/usr/bin/env bash
# modules/24_magic_convert.sh — MagicConvertMaterialComponent(s)
#
# Supporte :
#   - Valeur simple   : "water"          → from_material="water"
#   - Valeurs multiples : "water,lava"   → from_material_array="water,lava"
#   - Validation : autant d'éléments en "from" qu'en "to" si les deux sont arrays
#   - Plusieurs emitters (boucle)

register_module "magic_convert"

MC_FROMS=()
MC_TOS=()
MC_RADII=()
MC_MIN_RS=()

ask_magic_convert() {
  while ask_bool "MagicConvertMaterial (convertit un matériau en zone) ?"; do
    local from to radius min_r

    echo "  Valeurs séparées par des virgules pour cibler plusieurs matériaux."
    from=$(ask "  from_material(s) (ex: lava  ou  water,lava)")
    to=$(ask   "  to_material(s)   (ex: water ou  steam,water)")

    # Validation cohérence arrays
    local from_count to_count
    from_count=$(echo "$from" | tr ',' '\n' | grep -c .)
    to_count=$(echo "$to"   | tr ',' '\n' | grep -c .)
    if [[ $from_count -gt 1 || $to_count -gt 1 ]]; then
      if [[ $from_count -ne $to_count ]]; then
        warn "  Incohérence : ${from_count} from / ${to_count} to — ils doivent être égaux."
        warn "  Recette ignorée."
        continue
      fi
    fi

    radius=$(ask "  radius" "30")
    min_r=$(ask  "  min_radius (vide = absent)" "")

    MC_FROMS+=("$from")
    MC_TOS+=("$to")
    MC_RADII+=("$radius")
    MC_MIN_RS+=("$min_r")
  done
}

xml_magic_convert() {
  if [[ ${#MC_FROMS[@]} -eq 0 ]]; then return 0; fi
  for i in "${!MC_FROMS[@]}"; do
    local from="${MC_FROMS[$i]}" to="${MC_TOS[$i]}"
    local radius="${MC_RADII[$i]}" min_r="${MC_MIN_RS[$i]}"

    # Détecter si array (contient une virgule)
    local from_attr to_attr
    if [[ "$from" == *","* ]]; then
      from_attr="from_material_array"
    else
      from_attr="from_material"
    fi
    if [[ "$to" == *","* ]]; then
      to_attr="to_material_array"
    else
      to_attr="to_material"
    fi

    local min_line=""
    if [[ -n "$min_r" ]]; then
      min_line="
    min_radius=\"${min_r}\""
    fi

    cat <<XML


  <!-- Conversion de matériau #$((i+1)) -->
  <MagicConvertMaterialComponent
    _tags="enabled_in_world,enabled_in_hand"
    ${from_attr}="${from}"
    ${to_attr}="${to}"
    is_circle="1"
    radius="${radius}"${min_line}
    kill_when_finished="0"
    loop="1"
  ></MagicConvertMaterialComponent>
XML
  done
}

reg_magic_convert() { :; }

preview_magic_convert() {
  for i in "${!MC_FROMS[@]}"; do
    local note=""
    local from="${MC_FROMS[$i]}" to="${MC_TOS[$i]}"
    if [[ "$from" == *","* || "$to" == *","* ]]; then
      note=" (array)"
    fi
    info "MagicConvert #$((i+1))${note} : ${from} → ${to}  r=${MC_RADII[$i]}"
  done
}
