#!/usr/bin/env bash
# BlankStone — générateur de pierre élémentaire
# Usage : ./new_stone.sh
# Depuis la racine du projet

set -euo pipefail

MOD="mods/blankStone/files"
STONE_DIR="files/entities/elemental_stone"
STONE_REGISTRY="files/scripts/stone_factory/stone_registry.lua"
INFUSE_REGISTRY="files/scripts/stone_factory/craft_registry/infuse_registry.lua"
FUSE_REGISTRY="files/scripts/stone_factory/craft_registry/fuse_registry.lua"
FORGE_REGISTRY="files/scripts/stone_factory/craft_registry/forge_registry.lua"
CSV="translations.csv"

# Ancres d'insertion dans les fichiers Lua — doivent correspondre aux commentaires réels
ANCHOR_STONE_DATA_END="-- Vanilla Stones"        # stone_registry : fin de STONE_DATA elemental
ANCHOR_STONE_MSG_END="-- ##ANCHOR_STONE_MSG_END##"  # stone_registry : fin de STONE_MESSAGES (intérieur du tableau)
ANCHOR_STONE_COND_END="^    default = {"          # stone_registry : avant la condition default
ANCHOR_INFUSE_HINT="^        -- HINT"             # infuse_registry : séparateur recettes/hints blankStone
ANCHOR_INFUSE_END="-- ##ANCHOR_INFUSE_END##"      # infuse_registry : fin de STONE_TO_MATERIAL_TO_STONE
ANCHOR_FUSE_END="-- ##ANCHOR_FUSE_END##"          # fuse_registry   : fin de FUSE_RECIPES
ANCHOR_FORGE_END="-- ##ANCHOR_FORGE_END##"        # forge_registry  : fin de FORGE_RECIPES

# ── helpers ───────────────────────────────────────────────────────────────────

ask() {
  local prompt="$1" default="${2:-}"
  local suffix=""
  [[ -n "$default" ]] && suffix=" [$default]"
  read -rp "$prompt$suffix : " val
  echo "${val:-$default}"
}

ask_bool() {
  local prompt="$1" default="${2:-n}"
  local suffix="[o/N]"
  [[ "$default" == "o" ]] && suffix="[O/n]"
  while true; do
    read -rp "$prompt $suffix : " val
    val="${val:-$default}"
    case "${val,,}" in
      o|oui|y|yes|1) return 0 ;;
      n|non|no|0)    return 1 ;;
      *) echo "  → o ou n" ;;
    esac
  done
}

to_camel() {
  local input="$1" result="" first=1
  IFS='_' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    if [[ $first -eq 1 ]]; then result="$part"; first=0
    else result="${result}${part^}"; fi
  done
  echo "${result}Stone"
}

to_file_id() {
  local name="${1%Stone}"
  echo "stone_$(echo "$name" | sed 's/\([A-Z]\)/_\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^_//')"
}

csv_val() {
  local v="$1"
  if [[ "$v" == *","* || "$v" == *'"'* || "$v" == *"\\n"* ]]; then
    v="${v//\"/\"\"}"
    echo "\"${v}\""
  else
    echo "$v"
  fi
}

# Sauvegarde les fichiers Lua qui seront modifiés
backup_files() {
  for f in "$STONE_REGISTRY" "$INFUSE_REGISTRY" "$FUSE_REGISTRY" "$FORGE_REGISTRY"; do
    [[ -f "$f" ]] && cp "$f" "${f}.bak"
  done
}

# Supprime les .bak après succès
cleanup_backups() {
  for f in "$STONE_REGISTRY" "$INFUSE_REGISTRY" "$FUSE_REGISTRY" "$FORGE_REGISTRY"; do
    [[ -f "${f}.bak" ]] && rm "${f}.bak"
  done
}

# Restaure les .bak et quitte en cas d'erreur
rollback() {
  echo ""
  echo "✗ Erreur — restauration des fichiers originaux..."
  for f in "$STONE_REGISTRY" "$INFUSE_REGISTRY" "$FUSE_REGISTRY" "$FORGE_REGISTRY"; do
    [[ -f "${f}.bak" ]] && mv "${f}.bak" "$f" && echo "  restauré : $f"
  done
  exit 1
}

# Insère $text AVANT la première ligne qui matche $pattern
insert_before() {
  local file="$1" pattern="$2" text="$3"
  local tmp; tmp=$(mktemp)
  awk -v pat="$pattern" -v ins="$text" '
    !done && $0 ~ pat { print ins; done=1 }
    { print }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# Insère $text APRÈS la première ligne qui matche $pattern
insert_after() {
  local file="$1" pattern="$2" text="$3"
  local tmp; tmp=$(mktemp)
  awk -v pat="$pattern" -v ins="$text" '
    { print }
    !done && $0 ~ pat { print ins; done=1 }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# ── blocs XML ─────────────────────────────────────────────────────────────────

xml_identity() {
  local name="$1" file_id="$2" forgeable="$3"
  local tags=""
  [[ "$forgeable" == "1" ]] && tags=' tags="forgeable"'
  cat <<XML
<Entity name="${name}"${tags}>

  <Base file="${MOD}/entities/elemental_stone.xml">
    <PhysicsImageShapeComponent
      image_file="${MOD}/items_gfx/elemental_stone/${file_id}.png"
    ></PhysicsImageShapeComponent>

    <SpriteComponent
      image_file="${MOD}/items_gfx/elemental_stone/${file_id}.png"
    ></SpriteComponent>

    <ItemComponent
      item_name="\$stone_blankstone_${name}_name"
      ui_description="\$stone_blankstone_${name}_desc"
      ui_sprite="${MOD}/ui_gfx/elemental_stone/${file_id}.png"
    ></ItemComponent>

    <UIInfoComponent
      name="\$stone_blankstone_${name}_name"
    ></UIInfoComponent>

    <AbilityComponent
      ui_name="\$stone_blankstone_${name}_name"
    ></AbilityComponent>
XML
}

xml_purify_into() {
  cat <<XML

    <VariableStorageComponent
      name="purifyInto"
      value_string="${1}"
    ></VariableStorageComponent>
XML
}

xml_infusable() {
  cat <<XML

  <Base file="${MOD}/entities/infusable.xml" include_children="1" />
XML
}

xml_halo() {
  cat <<XML


  <!-- VFX -->
  <Base file="${MOD}/VFX/halo.xml">
    <SpriteParticleEmitterComponent
      color.r="${1}" color.g="${2}" color.b="${3}" color.a="${4}"
      color_change.r="0" color_change.g="0" color_change.b="0" color_change.a="-1.5"
      additive="1"
      emissive="1"
    ></SpriteParticleEmitterComponent>
  </Base>
XML
}

xml_sweat() {
  cat <<XML

  <Base file="${MOD}/VFX/sweat.xml">
    <ParticleEmitterComponent
      emitted_material_name="${1}"
      count_min="${2}"
      count_max="${3}"
    ></ParticleEmitterComponent>
  </Base>
XML
}

xml_ray() {
  cat <<XML

  <Base file="${MOD}/VFX/ray.xml">
    <SpriteParticleEmitterComponent
      color.r="${1}" color.g="${2}" color.b="${3}"
      count_min="${4}"
      count_max="${5}"
    ></SpriteParticleEmitterComponent>
  </Base>
XML
}

xml_game_effect() {
  local effect="$1" tags="${2:-enabled_in_hand,enabled_in_inventory}"
  cat <<XML


  <!-- effect -->
  <GameEffectComponent
    _tags="${tags}"
    effect="${effect}"
    frames="-1"
  ></GameEffectComponent>
XML
}

xml_staining() {
  cat <<XML


  <!-- Stain effect -->
  <Base file="${MOD}/entities/staining.xml">
    <VariableStorageComponent
      name="stain_effect"
      value_string="${1}"
      value_int="${2}"
    ></VariableStorageComponent>
  </Base>
XML
}

xml_material_immunity() {
  cat <<XML


  <!-- === MATERIAL IMMUNITY ======== -->
  <LuaComponent
    _tags="enabled_in_hand,enabled_in_inventory"
    script_source_file="${MOD}/scripts/status_effects/material_immunity_stone.lua"
    execute_every_n_frame="30"
  ></LuaComponent>

  <!-- Required -->
  <VariableStorageComponent
    name="protected_material"
    value_string="${1}"
  ></VariableStorageComponent>

  <!-- Optional : Default value = 0.0 -->
  <VariableStorageComponent
    name="new_material_dmg"
    value_string="${2}"
  ></VariableStorageComponent>
  <!-- ============================== -->
XML
}

xml_dmg_multiplier() {
  cat <<XML


  <!-- === STATUS EFFECT IMMUNITY === -->
  <LuaComponent
    _tags="enabled_in_hand,enabled_in_inventory"
    script_source_file="${MOD}/scripts/status_effects/damage_type_multiplier_stone.lua"
    execute_every_n_frame="30"
  ></LuaComponent>

  <!-- Required -->
  <VariableStorageComponent
    name="protected_damage_type"
    value_string="${1}"
  ></VariableStorageComponent>

  <!-- Optional : Default value = 0.0 -->
  <VariableStorageComponent
    name="new_mult"
    value_float="${2}"
  ></VariableStorageComponent>
  <!-- ============================== -->
XML
}

xml_magic_convert() {
  local from_m="$1" to_m="$2" radius="${3:-30}" min_r="${4:-}"
  local min_line=""
  [[ -n "$min_r" ]] && min_line="
    min_radius=\"${min_r}\""
  cat <<XML


  <!-- magical properties -->
  <MagicConvertMaterialComponent
    _tags="enabled_in_world,enabled_in_hand"
    from_material="${from_m}"
    to_material="${to_m}"
    is_circle="1"
    radius="${radius}"${min_line}
    kill_when_finished="0"
    loop="1"
  ></MagicConvertMaterialComponent>
XML
}

xml_lua() {
  local script="$1" tags="$2" every_n="$3" kick="$4"
  local attr="script_source_file"
  [[ "$kick" == "1" ]] && attr="script_kick"
  cat <<XML


  <LuaComponent
    _tags="${tags}"
    ${attr}="${MOD}/scripts/stone_specific_script/${script}"
    execute_every_n_frame="${every_n}"
  ></LuaComponent>
XML
}

xml_id() {
  cat <<XML


  <VariableStorageComponent
    name="blankStoneID"
    value_string="${1}"
  ></VariableStorageComponent>

</Entity>
XML
}

# ── wizard ────────────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════"
echo "  BlankStone — nouveau générateur"
echo "══════════════════════════════════"
echo ""

raw_id=$(ask "ID de la pierre (snake_case sans 'stone_', ex: magic_fire)")
[[ -z "$raw_id" ]] && { echo "ID requis."; exit 1; }

name=$(to_camel "$raw_id")
file_id=$(to_file_id "$name")
echo "  → Entité  : $name"
echo "  → Fichier : ${file_id}.xml"
echo ""

forgeable=0; ask_bool "Forgeable ?"  && forgeable=1
infusable=0; ask_bool "Infusable ?"  && infusable=1

purify_default="${MOD}/entities/blank_stone.xml"
purify_path="$purify_default"
if ask_bool "purifyInto personnalisé ? (défaut: blank_stone)"; then
  purify_path=$(ask "  Chemin complet" "$purify_default")
fi

echo ""
echo "── VFX ──"

use_halo=0; halo_r="" halo_g="" halo_b="" halo_a=""
if ask_bool "Halo ?" o; then
  use_halo=1
  echo "  Couleur (r g b a, ex: 0.3 0.8 0.3 0.25)"
  read -rp "  > " halo_r halo_g halo_b halo_a
fi

sweat_mats=(); sweat_cmins=(); sweat_cmaxs=()
while ask_bool "Ajouter un sweat emitter ?"; do
  s_mat=$(ask "  Matériau"); s_min=$(ask "  count_min" "2"); s_max=$(ask "  count_max" "5")
  sweat_mats+=("$s_mat"); sweat_cmins+=("$s_min"); sweat_cmaxs+=("$s_max")
done

use_ray=0; ray_r="" ray_g="" ray_b="" ray_min="" ray_max=""
if ask_bool "Ray emitter ?"; then
  use_ray=1
  echo "  Couleur (r g b, ex: 0.7 0.0 0.3)"
  read -rp "  > " ray_r ray_g ray_b
  ray_min=$(ask "  count_min" "2"); ray_max=$(ask "  count_max" "5")
fi

echo ""
echo "── Effets ──"

effects=()
while ask_bool "Ajouter un GameEffect ?"; do
  eff=$(ask "  Nom (ex: PROTECTION_FIRE)"); effects+=("$eff")
done

use_stain=0; stain_mat="" stain_int=""
if ask_bool "Staining ?"; then
  use_stain=1
  stain_mat=$(ask "  Matériau"); stain_int=$(ask "  Intensité" "32")
fi

use_mat_immunity=0; prot_mat="" prot_dmg=""
if ask_bool "Material immunity ?"; then
  use_mat_immunity=1
  prot_mat=$(ask "  protected_material"); prot_dmg=$(ask "  new_material_dmg" "0.0")
fi

use_dmg_mult=0; dmg_type="" dmg_mult=""
if ask_bool "Damage type multiplier ?"; then
  use_dmg_mult=1
  dmg_type=$(ask "  protected_damage_type"); dmg_mult=$(ask "  new_mult" "0.0")
fi

use_magic_convert=0; mc_from="" mc_to="" mc_radius="" mc_min_r=""
if ask_bool "MagicConvertMaterialComponent ?"; then
  use_magic_convert=1
  mc_from=$(ask "  from_material ou tag"); mc_to=$(ask "  to_material")
  mc_radius=$(ask "  radius" "30"); mc_min_r=$(ask "  min_radius (vide = aucun)" "")
fi

use_lua=0; lua_script="" lua_tags="" lua_every="" lua_kick=0
if ask_bool "LuaComponent script spécifique ?"; then
  use_lua=1
  lua_script=$(ask "  Script (dans stone_specific_script/)")
  lua_tags=$(ask "  _tags" "enabled_in_hand,enabled_in_inventory")
  lua_every=$(ask "  execute_every_n_frame" "6")
  lua_kick=0; ask_bool "  script_kick ? (sinon script_source_file)" && lua_kick=1
fi

echo ""
echo "── Traductions ──"
i18n_name_en=$(ask "Nom EN")
i18n_name_fr=$(ask "Nom FR (vide = à remplir)" "")
i18n_desc_en=$(ask "Description EN")
i18n_desc_fr=$(ask "Description FR (vide = à remplir)" "")

echo ""
echo "── stone_registry.lua ──"
reg_level=$(ask "Level (1/5/7/9/10/11)" "1")
reg_category=$(ask "Category (elemental/special/vanilla/book)" "elemental")

reg_msg_success="" reg_msg_fail=""
if ask_bool "Messages custom au craft ?"; then
  reg_msg_success=$(ask "  Clé succès (vide = défaut)" "")
  reg_msg_fail=$(ask "  Clé échec  (vide = défaut)" "")
fi

reg_cond_orbs="" reg_cond_purity=0
if ask_bool "Conditions custom ? (sinon déduit du level)"; then
  reg_cond_orbs=$(ask "  Orbs requis (vide = hérité du level)" "")
  ask_bool "  Purity requise ?" && reg_cond_purity=1
fi

echo ""
echo "── infuse_registry.lua ──"
echo "  Ajouter autant de sources d'infusion que nécessaire (blankStone, autre pierre...)"
echo "  Laisser vide pour terminer"

# Chaque entrée = (source, matériau, is_hint)
# Stocké dans trois tableaux parallèles
infuse_sources=(); infuse_mats=(); infuse_hints=()
infuse_has_hint=0

while true; do
  src=$(ask "  Source stone (ex: blankStone)" "")
  [[ -z "$src" ]] && break

  # Matériaux vides = hint, matériaux fournis = vraie recette
  echo "  Matériaux déclencheurs — supporte [tags] et mat1|mat2"
  echo "  (laisser vide sans rien entrer = hint uniquement)"
  src_mats=()
  while true; do
    mat=$(ask "  + Matériau" ""); [[ -z "$mat" ]] && break
    src_mats+=("$mat")
  done

  is_hint=0
  [[ ${#src_mats[@]} -eq 0 ]] && is_hint=1
  [[ $is_hint -eq 1 ]] && infuse_has_hint=1

  for mat in "${src_mats[@]}"; do
    infuse_sources+=("$src")
    infuse_mats+=("$mat")
    infuse_hints+=("$is_hint")
  done
done

echo ""
echo "── fuse_registry.lua ──"
use_fuse=0; fuse_ingredients=(); fuse_catalysts=(); fuse_radius="20"
if ask_bool "Ajouter une recette de fusion ?"; then
  use_fuse=1
  fuse_radius=$(ask "  Radius" "20")
  # Format : type:valeur:quantité
  #   type    = name  (pierre par nom exact)   ou  tag  (expression tag/pipe)
  #   valeur  = nom de la pierre               ou  expression (ex: mat1|mat2)
  #   quantité= entier (défaut 1 si omis)
  # Exemples : name:levitatiumStone:1   tag:brimstone|thunderstone:2
  # v2 : ajouter une option pour lister les pierres existantes depuis stone_registry
  echo "  Ingrédients — format  name:NomPierre:quantité  ou  tag:expression:quantité"
  echo "  (vide = terminer)"
  while true; do
    raw=$(ask "  + Ingrédient" ""); [[ -z "$raw" ]] && break
    fuse_ingredients+=("$raw")
  done
  echo "  Catalystes (même format, vide = aucun)"
  while true; do
    raw=$(ask "  + Catalyst" ""); [[ -z "$raw" ]] && break
    fuse_catalysts+=("$raw")
  done
fi

echo ""
echo "── forge_registry.lua ──"
use_forge=0; forge_spells="" forge_items=""
if ask_bool "Ajouter une recette de forge ?"; then
  use_forge=1
  forge_spells=$(ask "  Spells forgés (séparés par virgule, vide = aucun)" "")
  forge_items=$(ask "  Items forgés (chemins, séparés par virgule, vide = aucun)" "")
fi

# ── assemblage XML ────────────────────────────────────────────────────────────

xml=""
xml+="$(xml_identity "$name" "$file_id" "$forgeable")"
[[ "$purify_path" != "$purify_default" ]] && xml+="$(xml_purify_into "$purify_path")"
xml+="
  </Base>
"
[[ $infusable  -eq 1 ]] && xml+="$(xml_infusable)"
[[ $use_halo   -eq 1 ]] && xml+="$(xml_halo "$halo_r" "$halo_g" "$halo_b" "$halo_a")"
for i in "${!sweat_mats[@]}"; do
  xml+="$(xml_sweat "${sweat_mats[$i]}" "${sweat_cmins[$i]}" "${sweat_cmaxs[$i]}")"
done
[[ $use_ray           -eq 1 ]] && xml+="$(xml_ray "$ray_r" "$ray_g" "$ray_b" "$ray_min" "$ray_max")"
for eff in "${effects[@]}"; do xml+="$(xml_game_effect "$eff")"; done
[[ $use_stain         -eq 1 ]] && xml+="$(xml_staining "$stain_mat" "$stain_int")"
[[ $use_mat_immunity  -eq 1 ]] && xml+="$(xml_material_immunity "$prot_mat" "$prot_dmg")"
[[ $use_dmg_mult      -eq 1 ]] && xml+="$(xml_dmg_multiplier "$dmg_type" "$dmg_mult")"
[[ $use_magic_convert -eq 1 ]] && xml+="$(xml_magic_convert "$mc_from" "$mc_to" "$mc_radius" "$mc_min_r")"
[[ $use_lua           -eq 1 ]] && xml+="$(xml_lua "$lua_script" "$lua_tags" "$lua_every" "$lua_kick")"
xml+="$(xml_id "$name")"

# ── écriture XML ──────────────────────────────────────────────────────────────

# Sauvegarde avant toute modification — rollback automatique sur erreur
backup_files
trap rollback ERR

mkdir -p "$STONE_DIR"
out="${STONE_DIR}/${file_id}.xml"
if [[ -f "$out" ]]; then
  ask_bool "⚠  ${out} existe déjà — écraser ?" || { echo "Annulé."; exit 0; }
fi
echo "$xml" > "$out"

echo ""
echo "── Résultat ──"
echo "✓ XML      → $out"

# ── i18n ──────────────────────────────────────────────────────────────────────

key_name="stone_blankstone_${name}_name"
key_desc="stone_blankstone_${name}_desc"

if [[ ! -f "$CSV" ]]; then
  echo "⚠  CSV     → introuvable, lignes à ajouter manuellement :"
  echo "   ${key_name},$(csv_val "$i18n_name_en"),,,,,$(csv_val "$i18n_name_fr"),,,,,,,,"
  echo "   ${key_desc},$(csv_val "$i18n_desc_en"),,,,,$(csv_val "$i18n_desc_fr"),,,,,,,,"
elif grep -q "^${key_name}," "$CSV"; then
  echo "⚠  CSV     → clé déjà présente, ignorée"
else
  printf "%s,%s,,,,,%s,,,,,,,\n" \
    "$key_name" "$(csv_val "$i18n_name_en")" "$(csv_val "$i18n_name_fr")" >> "$CSV"
  printf "%s,%s,,,,,%s,,,,,,,\n" \
    "$key_desc" "$(csv_val "$i18n_desc_en")" "$(csv_val "$i18n_desc_fr")" >> "$CSV"
  echo "✓ CSV      → $CSV"
fi

# ── stone_registry.lua ────────────────────────────────────────────────────────

if [[ ! -f "$STONE_REGISTRY" ]]; then
  echo "⚠  REGISTRY → introuvable, ajouter manuellement"
elif grep -q "\[\"${name}\"\]" "$STONE_REGISTRY"; then
  echo "⚠  REGISTRY → ${name} déjà présent, ignoré"
else
  stone_entry="    [\"${name}\"] = {\n        path = elemental_stone_path .. \"${file_id}\",\n        level = ${reg_level},\n        category = \"${reg_category}\",\n    },"
  insert_before "$STONE_REGISTRY" "$ANCHOR_STONE_DATA_END" "$stone_entry"

  if [[ -n "$reg_msg_success" || -n "$reg_msg_fail" ]]; then
    s="${reg_msg_success:-\$text_blankstone_default_success}"
    f="${reg_msg_fail:-\$text_blankstone_default_fail}"
    msg_entry="    [\"${name}\"] = {\n        success = \"${s}\",\n        fail    = \"${f}\",\n    },"
    insert_before "$STONE_REGISTRY" "$ANCHOR_STONE_MSG_END" "$msg_entry"
  fi

  if [[ -n "$reg_cond_orbs" || $reg_cond_purity -eq 1 ]]; then
    cond_parts=""
    [[ -n "$reg_cond_orbs"    ]] && cond_parts="orbs = ${reg_cond_orbs}"
    [[ $reg_cond_purity -eq 1 ]] && cond_parts="${cond_parts:+${cond_parts}, }purity = true"
    cond_entry="    [\"${name}\"] = { ${cond_parts} },"
    insert_before "$STONE_REGISTRY" "$ANCHOR_STONE_COND_END" "$cond_entry"
  fi

  echo "✓ REGISTRY → $STONE_REGISTRY"
fi

# ── infuse_registry.lua ───────────────────────────────────────────────────────

if [[ ${#infuse_sources[@]} -gt 0 ]]; then
  if [[ ! -f "$INFUSE_REGISTRY" ]]; then
    echo "⚠  INFUSE  → introuvable, ajouter manuellement"
  else
    for i in "${!infuse_sources[@]}"; do
      src="${infuse_sources[$i]}"
      mat="${infuse_mats[$i]}"
      hint="${infuse_hints[$i]}"

      if [[ "$hint" -eq 1 ]]; then
        line="        [\"${mat}\"] = {hint_key = \"hint_blankstone_${raw_id}\"},"
      else
        line="        [\"${mat}\"] = {stone_keys = {\"${name}\"}},"
      fi

      if [[ "$src" == "blankStone" ]]; then
        insert_before "$INFUSE_REGISTRY" "$ANCHOR_INFUSE_HINT" "$line"
      else
        if ! grep -q "\[\"${src}\"\] = {" "$INFUSE_REGISTRY"; then
          if [[ -f "$STONE_REGISTRY" ]] && ! grep -q "\[\"${src}\"\]" "$STONE_REGISTRY"; then
            echo "⚠  INFUSE  → source \"${src}\" introuvable dans stone_registry"
            echo "             Ajouter manuellement dans infuse_registry :"
            echo "             [\"${src}\"] = {"
            echo "                 ${line}"
            echo "             },"
          else
            new_block="    [\"${src}\"] = {\n${line}\n    },"
            insert_before "$INFUSE_REGISTRY" "$ANCHOR_INFUSE_END" "$new_block"
            echo "  (bloc [\"${src}\"] créé dans infuse_registry)"
          fi
        else
          insert_after "$INFUSE_REGISTRY" "\[\"${src}\"\] = {" "$line"
        fi
      fi
    done
    echo "✓ INFUSE   → $INFUSE_REGISTRY"
  fi
fi

# ── fuse_registry.lua ─────────────────────────────────────────────────────────

if [[ $use_fuse -eq 1 ]]; then
  if [[ ! -f "$FUSE_REGISTRY" ]]; then
    echo "⚠  FUSE    → introuvable, ajouter manuellement"
  else
    ing_lines=""
    for raw in "${fuse_ingredients[@]}"; do
      IFS=':' read -r ing_type ing_val ing_count <<< "$raw"
      ing_lines="${ing_lines}            { ${ing_type} = \"${ing_val}\", count = ${ing_count:-1} },\n"
    done

    cat_block=""
    if [[ ${#fuse_catalysts[@]} -gt 0 ]]; then
      cat_lines=""
      for raw in "${fuse_catalysts[@]}"; do
        IFS=':' read -r cat_type cat_val cat_count <<< "$raw"
        cat_lines="${cat_lines}            { ${cat_type} = \"${cat_val}\", count = ${cat_count:-1} },\n"
      done
      cat_block="        catalysts = {\n${cat_lines}        },\n"
    fi

    fuse_block="    { -- ${name}\n        ingredients = {\n${ing_lines}        },\n${cat_block}        radius = ${fuse_radius},\n        results = {\n            { key = \"${name}\", offset_y = -10 },\n        },\n        on_success = function() end\n    },"
    insert_before "$FUSE_REGISTRY" "$ANCHOR_FUSE_END" "$fuse_block"
    echo "✓ FUSE     → $FUSE_REGISTRY"
  fi
fi

# ── forge_registry.lua ────────────────────────────────────────────────────────

if [[ $use_forge -eq 1 ]]; then
  if [[ ! -f "$FORGE_REGISTRY" ]]; then
    echo "⚠  FORGE   → introuvable, ajouter manuellement"
  else
    spell_block=""
    if [[ -n "$forge_spells" ]]; then
      spell_lines=""
      IFS=',' read -ra spells <<< "$forge_spells"
      for s in "${spells[@]}"; do
        s="${s// /}"
        spell_lines="${spell_lines}        \"${s}\",\n"
      done
      spell_block="        spells = {\n${spell_lines}        },\n"
    fi

    item_block=""
    if [[ -n "$forge_items" ]]; then
      item_lines=""
      IFS=',' read -ra items_arr <<< "$forge_items"
      for it in "${items_arr[@]}"; do
        it="${it// /}"
        item_lines="${item_lines}        \"${it}\",\n"
      done
      item_block="        items = {\n${item_lines}        },\n"
    fi

    forge_entry="    [\"${name}\"] = {\n${spell_block}${item_block}    },"
    insert_before "$FORGE_REGISTRY" "$ANCHOR_FORGE_END" "$forge_entry"
    echo "✓ FORGE    → $FORGE_REGISTRY"
  fi
fi

# ── nettoyage ────────────────────────────────────────────────────────────────

trap - ERR   # désactiver le rollback automatique — tout s'est bien passé
cleanup_backups

# ── reste à faire ─────────────────────────────────────────────────────────────

echo ""
items_dir="files/items_gfx/elemental_stone"
ui_dir="files/ui_gfx/elemental_stone"
mkdir -p "$items_dir" "$ui_dir"

items_png="${items_dir}/${file_id}.png"
ui_png="${ui_dir}/${file_id}.png"

if [[ -f "$items_png" ]]; then
  echo "⚠  PNG     → $items_png déjà présent, ignoré"
elif [[ ! -f "files/items_gfx/placeholder_stone.png" ]]; then
  echo "⚠  PNG     → placeholder files/items_gfx/placeholder_stone.png introuvable"
else
  cp "files/items_gfx/placeholder_stone.png" "$items_png"
  echo "✓ PNG      → $items_png"
fi

if [[ -f "$ui_png" ]]; then
  echo "⚠  PNG     → $ui_png déjà présent, ignoré"
elif [[ ! -f "files/ui_gfx/placeholder_stone.png" ]]; then
  echo "⚠  PNG     → placeholder files/ui_gfx/placeholder_stone.png introuvable"
else
  cp "files/ui_gfx/placeholder_stone.png" "$ui_png"
  echo "✓ PNG      → $ui_png"
fi

echo ""
echo "Reste à faire :"
echo "  • Remplacer les placeholders par les vrais sprites :"
echo "      $items_png"
echo "      $ui_png"
[[ $infuse_has_hint -eq 1 ]] && \
  echo "  • hint_registry.lua → ajouter 'hint_blankstone_${raw_id}'"