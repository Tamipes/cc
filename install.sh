#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(realpath .)"
DEST_DIR="/var/static/computercraft"

echo "Linking from $SRC_DIR to $DEST_DIR"

# Find all files and directories recursively
find "$SRC_DIR" \
    -path '*/.git*' -prune -o \
    -print0 |
while IFS= read -r -d '' SRC_PATH; do
    # Compute relative path
    REL_PATH="${SRC_PATH#$SRC_DIR/}"
    DEST_PATH="$DEST_DIR/$REL_PATH"

    if [ -d "$SRC_PATH" ]; then
        # Create destination directory if it doesn't exist
        mkdir -p "$DEST_PATH"
    elif [ -f "$SRC_PATH" ]; then
        # If it's a file, create a hard link if necessary
        if [ -e "$DEST_PATH" ]; then
            # Check if it's already the same inode (i.e., hardlinked)
            if [ "$(stat -c %i "$SRC_PATH")" -eq "$(stat -c %i "$DEST_PATH")" ]; then
                continue  # Already hardlinked, skip
            else
                rm -f "$DEST_PATH"
            fi
        fi
        ln "$SRC_PATH" "$DEST_PATH"
    fi
done

echo "Done."
