#!/bin/bash

[[ "$1" == "-h" || "$1" == "--help" ]] && {
    echo "Usage: $0 IMAGE OUTPUT_DIR [COLS=7]"
    exit 0
}

[[ $# -lt 2 ]] && { echo "Usage: $0 IMAGE OUTPUT_DIR [COLS=7]" >&2; exit 1; }

mkdir -p "$2"
convert "$1" -crop ${3:-8}x1@ "$2/tile-%d.png"