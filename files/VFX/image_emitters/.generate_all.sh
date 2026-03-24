for file in ./glyphs/composite/*.png; do
	./.glyph_fuse.sh "$file"
done
