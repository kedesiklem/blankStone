#!/usr/bin/env bash
# modules/29_footer.sh — fermeture de l'entité XML (REQUIS, toujours en dernier des modules XML)

register_module "footer"

ask_footer() { :; }  # rien à demander

xml_footer() {
  cat <<XML


  <VariableStorageComponent
    name="blankStoneID"
    value_string="${STONE_NAME}"
  ></VariableStorageComponent>

</Entity>
XML
}

reg_footer()     { :; }
preview_footer() { :; }
