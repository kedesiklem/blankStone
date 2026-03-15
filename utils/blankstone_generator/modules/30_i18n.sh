#!/usr/bin/env bash
# modules/30_i18n.sh — traductions CSV (REQUIS)
# Format CSV : key,en,,,,,(fr-fr),,,,,,,,

register_module "i18n"

I18N_NAME_EN=""
I18N_NAME_FR=""
I18N_DESC_EN=""
I18N_DESC_FR=""

ask_i18n() {
  section "Traductions"
  I18N_NAME_EN=$(ask "Nom EN")
  I18N_NAME_FR=$(ask "Nom FR (vide = à remplir plus tard)" "")
  I18N_DESC_EN=$(ask "Description EN")
  I18N_DESC_FR=$(ask "Description FR (vide = à remplir plus tard)" "")
}

xml_i18n() { :; }  # pas de contribution XML

reg_i18n() {
  local key_name="stone_blankstone_${STONE_NAME}_name"
  local key_desc="stone_blankstone_${STONE_NAME}_desc"

  if [[ ! -f "$TRANSLATIONS_FILE" ]]; then
    warn "CSV introuvable — lignes à ajouter manuellement dans translations.csv :"
    echo "  ${key_name},$(csv_val "$I18N_NAME_EN"),,,,,$(csv_val "$I18N_NAME_FR"),,,,,,,,"
    echo "  ${key_desc},$(csv_val "$I18N_DESC_EN"),,,,,$(csv_val "$I18N_DESC_FR"),,,,,,,,"
    return 0
  fi

  if grep -q "^${key_name}," "$TRANSLATIONS_FILE"; then
    warn "CSV → clé déjà présente, ignorée (${key_name})"
    return 0
  fi

  printf "%s,%s,,,,,%s,,,,,,,\n" \
    "$key_name" "$(csv_val "$I18N_NAME_EN")" "$(csv_val "$I18N_NAME_FR")" \
    >> "$TRANSLATIONS_FILE"
  printf "%s,%s,,,,,%s,,,,,,,\n" \
    "$key_desc" "$(csv_val "$I18N_DESC_EN")" "$(csv_val "$I18N_DESC_FR")" \
    >> "$TRANSLATIONS_FILE"
  ok "CSV      → translations.csv (+2 lignes)"
}

preview_i18n() {
  local key_name="stone_blankstone_${STONE_NAME}_name"
  local key_desc="stone_blankstone_${STONE_NAME}_desc"
  info "[CSV] ${key_name} = \"${I18N_NAME_EN}\" / \"${I18N_NAME_FR:-<à compléter>}\""
  info "[CSV] ${key_desc} = \"${I18N_DESC_EN}\" / \"${I18N_DESC_FR:-<à compléter>}\""
}
