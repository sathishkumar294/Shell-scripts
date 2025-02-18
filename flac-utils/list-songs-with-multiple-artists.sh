#!/bin/bash

# Set the target directory
TARGET_DIR="$1"

# Find all .flac files in the target directory and its subdirectories
find "$TARGET_DIR" -type f -name "*.flac" | while read -r file; do
    # Extract the Album Artist metadata using metaflac
    album_artists=$(metaflac --show-tag=ALBUMARTIST "$file" | cut -d= -f2)

    # Check if there are multiple album artists
    if [[ "$album_artists" == *", "* ]]; then
        echo "File: $file"
        echo "Album Artists: $album_artists"
        echo
    fi
done
