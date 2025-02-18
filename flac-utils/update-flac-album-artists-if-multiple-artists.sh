#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <artist>"
    exit 1
fi

# Set the target directory and artist name from the input arguments
TARGET_DIR="$1"
ARTIST="$2"

# Find all .flac files in the target directory and its subdirectories
find "$TARGET_DIR" -type f -name "*.flac" | while read -r file; do
    # Extract the Album Artist metadata using metaflac
    album_artists=$(metaflac --show-tag=ALBUMARTIST "$file" | cut -d= -f2)

    # Check if there are multiple album artists and one of them is the input artist
    if [[ "$album_artists" == *", "* && "$album_artists" == *"$ARTIST"* ]]; then
        echo "Updating Album Artist to '$ARTIST' for file: $file"

        # Update the ALBUMARTIST tag to only the specified artist
        metaflac --remove-tag=ALBUMARTIST "$file"
        metaflac --set-tag=ALBUMARTIST="$ARTIST" "$file"

        echo "Updated Album Artist to '$ARTIST'."
        echo
    fi
done
