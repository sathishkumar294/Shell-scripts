#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <album artist>"
    exit 1
fi

# Set the target directory from the input arguments
TARGET_DIR="$1"

# Desired album artist
TARGET_ARTIST="$2"

# Find all .flac files in the target directory and its subdirectories
find "$TARGET_DIR" -type f -name "*.flac" | while read -r file; do
    # Extract the Album Artist metadata using metaflac
    album_artists=$(metaflac --show-tag=ALBUMARTIST "$file" | cut -d= -f2)

    # Check if the current album artist is not exactly TARGET_ARTIST
    if [[ "$album_artists" != "$TARGET_ARTIST" ]]; then
        echo "Found a file without '$TARGET_ARTIST' as the only Album Artist: $file"
        echo "Current Album Artist: $album_artists"

        # Update the ALBUMARTIST tag to only TARGET_ARTIST
        metaflac --remove-tag=ALBUMARTIST "$file"
        metaflac --set-tag=ALBUMARTIST="$TARGET_ARTIST" "$file"

        echo "Updated Album Artist to '$TARGET_ARTIST'."
        echo
    fi
done
