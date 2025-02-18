#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    echo "List flac files in a directory with more than one album artists."
    echo "Useful when trying to find which files to update album artits"
    exit 1
fi

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
