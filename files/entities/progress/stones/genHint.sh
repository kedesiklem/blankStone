set -euo pipefail

SRC_DIR="${1:-.}"
DST_DIR="${2:-$SRC_DIR}"

command -v convert >/dev/null 2>&1 || { echo "ImageMagick (convert) introuvable." >&2; exit 1; }

mkdir -p "$DST_DIR"

shopt -s nullglob
count=0
for f in "$SRC_DIR"/progress_*.png; do
    base="$(basename "$f")"
    out="$DST_DIR/${base/progress_/hint_}"

    alpha_flag="$(identify -format "%A" "$f")"
    if [ "$alpha_flag" = "False" ]; then
        echo "attention: $base n'a pas de canal alpha, hint genere sera plein cadre (rouge partout)" >&2
    fi

    convert "$f" -alpha extract -threshold 0 -type TrueColor \
        -channel G -evaluate set 0 \
        -channel B -evaluate set 0 \
        +channel "$out"

    count=$((count+1))
    echo "genere: $out"
done

echo "$count fichier(s) traite(s)."