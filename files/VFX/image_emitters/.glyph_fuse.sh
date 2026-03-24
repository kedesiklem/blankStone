#!/bin/bash

# Usage: ./merge.sh <image2>

IMAGE1="glyphs/yellow.png"
IMAGE2="$1"
IMAGE3="glyphs/green.png"
BASENAME=$(basename "${IMAGE2%.*}")
OUTPUT_PNG="${BASENAME}.png"
OUTPUT_XML="${BASENAME}.xml"

if [ -z "$IMAGE2" ]; then
    echo "Usage: $0 <image2>"
    exit 1
fi

if [ ! -f "$IMAGE2" ]; then
    echo "Erreur : '$IMAGE2' introuvable"
    exit 1
fi

convert "$IMAGE2" "$IMAGE1" -compose Atop -composite \
        "$IMAGE3" +swap -compose Over -composite \
        -background black -flatten "$OUTPUT_PNG"

echo "DONE : $OUTPUT_PNG"

echo -e "<Entity>\n    <Base file=\"mods/blankStone/files/VFX/image_emitters/glyph.xml\">\n        <ParticleEmitterComponent\n            emitted_material_name=\"spark_red\"\n            image_animation_file=\"mods/blankStone/files/VFX/image_emitters/$OUTPUT_PNG\"\n        ></ParticleEmitterComponent>\n    </Base>\n</Entity>" > "$OUTPUT_XML"

echo "DONE : $OUTPUT_XML"