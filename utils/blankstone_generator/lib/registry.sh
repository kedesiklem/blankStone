#!/usr/bin/env bash
# lib/registry.sh — lecture des registres existants

# Retourne la liste dédoublonnée et triée des noms de pierres
list_stones() {
  if [[ ! -f "$STONE_REGISTRY_FILE" ]]; then
    echo "(stone_registry.lua introuvable)"
    return 1
  fi
  grep -oP '^\s+\["\K[^"]+(?="\]\s*=\s*\{)' "$STONE_REGISTRY_FILE" 2>/dev/null | sort -u
}

# Retourne 0 si la pierre existe dans stone_registry.lua
stone_exists() {
  [[ -f "$STONE_REGISTRY_FILE" ]] && grep -qP "^\s+\[\"${1}\"\]" "$STONE_REGISTRY_FILE"
}

# Retourne la liste triée des clés de hints
list_hints() {
  if [[ ! -f "$HINT_REGISTRY_FILE" ]]; then
    echo "(hint_registry.lua introuvable)"
    return 1
  fi
  grep -oP '^\s+\["\K[^"]+(?="\]\s*=\s*\{)' "$HINT_REGISTRY_FILE" 2>/dev/null | sort -u
}

# Retourne 0 si le hint existe dans hint_registry.lua
hint_exists() {
  [[ -f "$HINT_REGISTRY_FILE" ]] && grep -qP "^\s+\[\"${1}\"\]" "$HINT_REGISTRY_FILE"
}

# Retourne 0 si un bloc source existe dans infuse_registry.lua
infuse_source_exists() {
  [[ -f "$INFUSE_REGISTRY_FILE" ]] && grep -qP "^\s+\[\"${1}\"\]\s*=\s*\{" "$INFUSE_REGISTRY_FILE"
}

# Affiche les pierres avec leur level et category
list_stones_detailed() {
  if [[ ! -f "$STONE_REGISTRY_FILE" ]]; then
    echo "(stone_registry.lua introuvable)"
    return 1
  fi
  awk '
    /^\s+\["[^"]+"\]\s*=\s*\{/ {
      match($0, /\["([^"]+)"\]/, name)
      n = name[1]
      getline; if ($0 ~ /level/) { match($0, /level\s*=\s*([0-9]+)/, lv); level = lv[1] } else level = "?"
      getline; if ($0 ~ /category/) { match($0, /category\s*=\s*"([^"]+)"/, cat); category = cat[1] } else category = "?"
      printf "  %-30s level=%-3s category=%s\n", n, level, category
    }
  ' "$STONE_REGISTRY_FILE" | sort -u
}
