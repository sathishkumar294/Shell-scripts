#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <original_string> <replacement_string>"
    echo "Replace one album artist by another for all flac files in a directory."
    echo "Useful when renaming artists."
    exit 1
fi

# Set the target directory and strings from the input arguments
TARGET_DIR="$1"
ORIGINAL_STRING="$2"
REPLACEMENT_STRING="$3"

# Find all .flac files in the target directory and its subdirectories
find "$TARGET_DIR" -type f -name "*.flac" | while read -r file; do
    # Extract the Album Artist metadata using metaflac
    album_artists=$(metaflac --show-tag=ALBUMARTIST "$file" | cut -d= -f2)

    # Check if the original string is in the album artists
    if [[ "$album_artists" == *"$ORIGINAL_STRING"* ]]; then
        echo "Found '$ORIGINAL_STRING' in Album Artist for file: $file"

        # Replace the original string with the replacement string
        new_album_artists=$(echo "$album_artists" | sed "s/$ORIGINAL_STRING/$REPLACEMENT_STRING/g")

        # Update the ALBUMARTIST tag with the corrected value
        metaflac --remove-tag=ALBUMARTIST "$file"
        metaflac --set-tag=ALBUMARTIST="$new_album_artists" "$file"

        echo "Updated Album Artist to '$new_album_artists'."
        echo
    fi
done
