#DEST_DIR="scratch/export/"
DEST_DIR="docs/"

MARIMO=`which marimo`
NEW_EXT="html"

for FILE in "$@"; do
    # Check if the file actually exists
    if [ -f "$FILE" ]; then
        # Parameter expansion: ${FILE%.*} removes the shortest match of .* from the end
        FULL_FILENAME="${FILE##*/}"
        # 2. Strip the extension from that filename
        BASE_NAME="${FULL_FILENAME%.*}"

        #BASE_NAME="${FILE%.*}"
        NEW_NAME="${BASE_NAME}.${NEW_EXT}"
        DEST="$DEST_DIR$NEW_NAME"
        #mv "$FILE" "$NEW_NAME"
        echo "publishing $FILE -> $DEST ..."
        yes | $MARIMO export html-wasm "$FILE" --output "$DEST" --mode run
    else
        echo "Error: $FILE not found, skipping."
    fi
done

