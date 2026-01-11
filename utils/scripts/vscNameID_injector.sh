#!/bin/bash

# LLM code

# Dossier à parcourir (par défaut le dossier courant)
FOLDER="${1:-.}"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Parcours du dossier: $FOLDER"
echo "----------------------------------------"

# Compteurs
files_processed=0
entities_found=0
entities_modified=0

# Parcourir tous les fichiers XML
while IFS= read -r file; do
    ((files_processed++))
    echo -e "${YELLOW}Traitement:${NC} $file"
    
    # Vérifier si le fichier contient une balise Entity
    if ! grep -q '<Entity' "$file"; then
        echo "  Aucune entité trouvée, skip"
        echo ""
        continue
    fi
    
    # Extraire le nom de l'entité
    entity_name=$(grep -oP '<Entity\s+name="\K[^"]+' "$file" | head -1)
    
    if [ -z "$entity_name" ]; then
        echo "  Aucun nom d'entité trouvé"
        echo ""
        continue
    fi
    
    ((entities_found++))
    echo -e "  ${GREEN}✓${NC} Entité trouvée: $entity_name"
    
    # Vérifier si le VariableStorageComponent avec blankStoneID existe déjà
    if grep -q 'name="blankStoneID"' "$file"; then
        echo -e "    ${YELLOW}⚠${NC} VariableStorageComponent (blankStoneID) déjà présent"
        echo ""
        continue
    fi
    
    # Créer un fichier temporaire
    temp_file=$(mktemp)
    
    # Utiliser awk pour insérer le composant avant la balise </Entity> fermante
    awk -v entity_name="$entity_name" '
    /<\/Entity>/ {
        # Insérer le VariableStorageComponent avec indentation appropriée
        print "  <VariableStorageComponent"
        print "    name=\"blankStoneID\""
        print "    value_string=\"" entity_name "\""
        print "  ></VariableStorageComponent>"
        print ""
    }
    { print }
    ' "$file" > "$temp_file"
    
    # Remplacer le fichier original
    mv "$temp_file" "$file"
    ((entities_modified++))
    echo -e "    ${GREEN}→${NC} VariableStorageComponent ajouté"
    echo ""
    
done < <(find "$FOLDER" -type f -name "*.xml")

echo "----------------------------------------"
echo -e "${GREEN}Résumé:${NC}"
echo "  Fichiers traités: $files_processed"
echo "  Entités trouvées: $entities_found"
echo "  Entités modifiées: $entities_modified"