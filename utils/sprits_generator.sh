#!/bin/bash

# made by LLM [from Kededsiklem]
# Script de génération de sprites colorés - Version bash simple
# Dépendances: ImageMagick (convert, identify)

# Configuration
SPRITES_DIR="./sprites"
MATERIALS_DIR="./materials" 
OUTPUT_DIR="./output"
LOG_FILE="./generation.log"

# Créer les dossiers s'ils n'existent pas
mkdir -p "$SPRITES_DIR" "$MATERIALS_DIR" "$OUTPUT_DIR"

# Fonction pour extraire la couleur moyenne d'un matériau
get_average_color() {
    local material_file="$1"
    
    # Utiliser ImageMagick pour obtenir la couleur moyenne (ignore les pixels transparents)
    local color=$(convert "$material_file" -alpha off -format "%[fx:mean.r*255]" info: \
                   | awk '{printf "%d", $1}')
    local avg_r=$color
    local avg_g=$(convert "$material_file" -alpha off -format "%[fx:mean.g*255]" info: \
                   | awk '{printf "%d", $1}')
    local avg_b=$(convert "$material_file" -alpha off -format "%[fx:mean.b*255]" info: \
                   | awk '{printf "%d", $1}')
    
    echo "$avg_r $avg_g $avg_b"
}

# Fonction pour appliquer le masque de couleur
apply_color_mask() {
    local sprite_file="$1"
    local material_file="$2"
    local output_file="$3"
    
    echo "Traitement: $sprite_file avec $material_file -> $output_file" | tee -a "$LOG_FILE"
    
    # Extraire la couleur moyenne du matériau
    read r g b <<< $(get_average_color "$material_file")
    
    # Obtenir les dimensions du sprite
    local size=$(identify -format "%wx%h" "$sprite_file")
    
    # Créer une image temporaire avec la couleur moyenne
    convert -size "$size" xc:"rgb($r,$g,$b)" temp_color.png
    
    # Redimensionner le matériau aux dimensions du sprite
    convert "$material_file" -resize "$size"! temp_material_resized.png
    
    # Créer le masque de luminosité à partir du sprite (convertir en niveaux de gris)
    convert "$sprite_file" -colorspace Gray temp_luminosity.png
    
    # Appliquer la couleur avec luminosité (50% couleur + 50% matériau)
    # Étape 1: Appliquer la luminosité à la couleur de base
    convert temp_color.png temp_luminosity.png -compose Multiply -composite temp_colored.png
    
    # Étape 2: Appliquer la luminosité au matériau
    convert temp_material_resized.png temp_luminosity.png -compose Multiply -composite temp_material_shaded.png
    
    # Étape 3: Mélanger 50/50 couleur et matériau
    convert temp_colored.png temp_material_shaded.png -define compose:args=50,50 -compose Blend -composite temp_blended.png
    
    # Étape 4: Conserver la transparence originale du sprite
    convert temp_blended.png \( "$sprite_file" -alpha Extract \) -alpha Off -compose CopyOpacity -composite "$output_file"
    
    # Nettoyer les fichiers temporaires
    rm -f temp_*.png
    
    echo "✓ Succès: $output_file" | tee -a "$LOG_FILE"
}

# Fonction pour traiter tous les sprites avec tous les matériaux
process_batch() {
    local sprites=("$SPRITES_DIR"/*.png)
    local materials=("$MATERIALS_DIR"/*.png)
    
    if [ ${#sprites[@]} -eq 0 ] || [ "${sprites[0]}" = "$SPRITES_DIR/*.png" ]; then
        echo "❌ Aucun sprite trouvé dans $SPRITES_DIR/"
        return 1
    fi
    
    if [ ${#materials[@]} -eq 0 ] || [ "${materials[0]}" = "$MATERIALS_DIR/*.png" ]; then
        echo "❌ Aucun matériau trouvé dans $MATERIALS_DIR/"
        return 1
    fi
    
    echo "🎯 Début du traitement batch..." | tee -a "$LOG_FILE"
    echo "Sprites: ${#sprites[@]}, Matériaux: ${#materials[@]}" | tee -a "$LOG_FILE"
    
    local count=0
    for sprite in "${sprites[@]}"; do
        for material in "${materials[@]}"; do
            local sprite_name=$(basename "${sprite%.*}")
            local material_name=$(basename "${material%.*}")
            local output_file="$OUTPUT_DIR/${sprite_name}_${material_name}.png"
            
            apply_color_mask "$sprite" "$material" "$output_file"
            ((count++))
        done
    done
    
    echo "✅ Génération terminée: $count images créées dans $OUTPUT_DIR" | tee -a "$LOG_FILE"
}

# Fonction pour traiter une seule combinaison
process_single() {
    local sprite="$1"
    local material="$2"
    local output="$3"
    
    if [ -z "$output" ]; then
        local sprite_name=$(basename "${sprite%.*}")
        local material_name=$(basename "${material%.*}")
        output="$OUTPUT_DIR/${sprite_name}_${material_name}.png"
    fi
    
    apply_color_mask "$sprite" "$material" "$output"
}

# Afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Afficher cette aide"
    echo "  -s, --sprite FILE   Sprite à traiter (fichier PNG)"
    echo "  -m, --material FILE Matériau à utiliser (fichier image)"
    echo "  -o, --output FILE   Fichier de sortie (optionnel)"
    echo "  -b, --batch         Traiter tous les sprites avec tous les matériaux"
    echo ""
    echo "Exemples:"
    echo "  $0 --batch"
    echo "  $0 --sprite sprites/stone.png --material materials/wood.jpg --output result.png"
    echo ""
    echo "Structure des dossiers:"
    echo "  $SPRITES_DIR/    # Sprites PNG à traiter"
    echo "  $MATERIALS_DIR/  # Images matériaux"
    echo "  $OUTPUT_DIR/     # Résultats générés"
}

# Point d'entrée principal
main() {
    # Vérifier que ImageMagick est installé
    if ! command -v convert &> /dev/null || ! command -v identify &> /dev/null; then
        echo "❌ ImageMagick n'est pas installé."
        echo "📦 Installation:"
        echo "  Ubuntu/Debian: sudo apt install imagemagick"
        echo "  macOS: brew install imagemagick"
        echo "  CentOS/RHEL: sudo yum install ImageMagick"
        exit 1
    fi
    
    # Initialiser le log
    echo "=== Début de la génération $(date) ===" > "$LOG_FILE"
    
    # Traitement des arguments
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--batch)
                process_batch
                exit 0
                ;;
            -s|--sprite)
                SPRITE_FILE="$2"
                shift 2
                ;;
            -m|--material)
                MATERIAL_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            *)
                echo "❌ Argument inconnu: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Traitement single
    if [ -n "$SPRITE_FILE" ] && [ -n "$MATERIAL_FILE" ]; then
        process_single "$SPRITE_FILE" "$MATERIAL_FILE" "$OUTPUT_FILE"
    else
        echo "❌ Paramètres manquants"
        show_help
        exit 1
    fi
}

# Lancer le script
main "$@"