#!/usr/bin/env bash
# modules/25_lua_component.sh — LuaComponent script spécifique à cette pierre

register_module "lua_component"

LUA_ENABLED=0
LUA_SCRIPT=""
LUA_TAGS="enabled_in_hand,enabled_in_inventory"
LUA_EVERY="6"
LUA_KICK=0   # 1 = script_kick  0 = script_source_file

ask_lua_component() {
  ask_bool "LuaComponent script spécifique ?" && LUA_ENABLED=1 || { LUA_ENABLED=0; return 0; }
  echo "  Scripts disponibles dans files/scripts/stone_specific_script/ :"
  ls "${MOD_ROOT}/files/scripts/stone_specific_script/" 2>/dev/null | sed 's/^/    /' || echo "    (dossier introuvable)"
  echo ""
  LUA_SCRIPT=$(ask "  Nom du script (dans stone_specific_script/)")
  LUA_TAGS=$(ask "  _tags" "enabled_in_hand,enabled_in_inventory")
  LUA_EVERY=$(ask "  execute_every_n_frame" "6")
  ask_bool "  Utiliser script_kick ? (sinon script_source_file)" && LUA_KICK=1 || LUA_KICK=0
}

xml_lua_component() {
  if [[ $LUA_ENABLED -eq 0 ]]; then return 0; fi
  local attr="script_source_file"
  if [[ $LUA_KICK -eq 1 ]]; then attr="script_kick"; fi
  cat <<XML


  <LuaComponent
    _tags="${LUA_TAGS}"
    ${attr}="${MOD_PATH}/scripts/stone_specific_script/${LUA_SCRIPT}"
    execute_every_n_frame="${LUA_EVERY}"
  ></LuaComponent>
XML
}

reg_lua_component()     { :; }
preview_lua_component() {
  if [[ $LUA_ENABLED -eq 0 ]]; then return 0; fi
  local attr="script_source_file"
  if [[ $LUA_KICK -eq 1 ]]; then attr="script_kick"; fi
  info "LuaComponent : ${LUA_SCRIPT}  ${attr}  every=${LUA_EVERY}"
}

todo_lua_component() {
  if [[ $LUA_ENABLED -eq 0 ]]; then return 0; fi
  local f="${MOD_ROOT}/files/scripts/stone_specific_script/${LUA_SCRIPT}"
  if [[ ! -f "$f" ]]; then echo "  • Créer le script Lua : files/scripts/stone_specific_script/${LUA_SCRIPT}"; fi
}
