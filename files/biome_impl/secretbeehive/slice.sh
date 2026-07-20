#!/usr/bin/env bash
#
# slice.sh
#
# Decoupe une ou plusieurs images en tuiles <= 512x512 (limite dure du
# moteur Noita pour un <PixelScene material_filename=...>), numerotees dans
# le meme ordre que buildTiledMaterialScene() dans pixel_scene_injector.lua
# (gauche -> droite puis haut -> bas, a partir de 1). Le nom de base de
# sortie est deduit automatiquement du nom du fichier source (sans
# extension) - pas besoin de le preciser.
#
# Toute image deja <= 512x512 est ignoree (silencieux), donc tu peux relancer
# ./slice.sh *.png autant de fois que tu veux, meme sur un dossier qui
# contient deja des tuiles issues d'un run precedent : elles sont ignorees
# au lieu d'etre re-decoupees.
#
# Usage:
#   ./slice.sh [--outdir DIR] [--tile-size N] fichier1.png [fichier2.png ...]
#
# Exemples:
#   ./slice.sh *.png
#     material.png   -> material1.png, material2.png, ...   (a cote de material.png)
#     texture.png    -> texture1.png, texture2.png, ...
#     background.png -> background1.png, background2.png, ...
#
#   ./slice.sh --outdir biome_impl/secretbeehive *.png
#
# Necessite ImageMagick ("convert" ou "magick").

set -euo pipefail

TILE_SIZE=512
OUTDIR=""   # vide = a cote de chaque fichier source

usage() {
    echo "Usage: $0 [--outdir DIR] [--tile-size N] fichier1.png [fichier2.png ...]"
    echo "  Exemple : $0 *.png"
    exit 1
}

while [[ "${1:-}" == --* ]]; do
    case "$1" in
        --outdir)
            OUTDIR="${2:?--outdir necessite un argument}"
            shift 2
            ;;
        --tile-size)
            TILE_SIZE="${2:?--tile-size necessite un argument}"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

[[ $# -eq 0 ]] && usage

if command -v magick >/dev/null 2>&1; then
    IDENTIFY=(magick identify)
    CONVERT=(magick)
elif command -v convert >/dev/null 2>&1; then
    IDENTIFY=(identify)
    CONVERT=(convert)
else
    echo "Erreur : ImageMagick n'est pas installe (ni 'magick' ni 'convert'/'identify')." >&2
    exit 1
fi

slice_one() {
    local src="$1"

    if [[ ! -f "$src" ]]; then
        echo "Ignore (introuvable) : $src" >&2
        return
    fi

    local dir base outdir width height cols rows
    dir="$(dirname "$src")"
    base="$(basename "$src")"
    base="${base%.*}"
    outdir="${OUTDIR:-$dir}"

    read -r width height < <("${IDENTIFY[@]}" -format "%w %h\n" "$src")

    cols=$(( (width + TILE_SIZE - 1) / TILE_SIZE ))
    rows=$(( (height + TILE_SIZE - 1) / TILE_SIZE ))

    if [[ $cols -le 1 && $rows -le 1 ]]; then
        # Deja assez petite - couvre aussi bien les images qui n'ont jamais
        # eu besoin d'etre decoupees que les tuiles produites par un run precedent.
        echo "Ignore (deja <= ${TILE_SIZE}x${TILE_SIZE}, ${width}x${height}) : $src"
        return
    fi

    echo "Source : $src (${width}x${height}) -> ${cols}x${rows} tuile(s) de ${TILE_SIZE}x${TILE_SIZE} max"
    mkdir -p "$outdir"

    local tile_n=0 row col x y out
    for (( row=0; row<rows; row++ )); do
        for (( col=0; col<cols; col++ )); do
            tile_n=$((tile_n + 1))
            x=$(( col * TILE_SIZE ))
            y=$(( row * TILE_SIZE ))
            out="$outdir/${base}${tile_n}.png"

            "${CONVERT[@]}" "$src" \
                -crop "${TILE_SIZE}x${TILE_SIZE}+${x}+${y}" +repage \
                -background none -gravity NorthWest -extent "${TILE_SIZE}x${TILE_SIZE}" \
                "$out"

            echo "  tuile $tile_n (col=$col row=$row) @ (${x},${y}) -> $out"
        done
    done
}

for src in "$@"; do
    slice_one "$src"
done

echo "Termine."