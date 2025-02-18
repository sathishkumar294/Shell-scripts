#!/bin/bash

# Check if an argument is provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <folder_path>"
    echo "Lists the ports used by docker services in docker compose files found by recursive scan of the specified folder."
    echo "Optional : log level (info=default, debug)"
    exit 1
fi

# Temporary file to store the output
temp_file=$(mktemp)

# Header for the output table
printf "%-20s %-15s %-15s\n" "Service" "Port" "Internal Port" > "$temp_file"

# INPUT DIRECTORY
SCAN_DIR=$1

# Log level
LOG_LEVEL=${2:-info}

# Function to print debug messages
debug_log() {
    if [ "$LOG_LEVEL" = "debug" ]; then
        echo "[DEBUG] $1"
    fi
}
info_log() {
    if [ "$LOG_LEVEL" = "info" ] || [ "$LOG_LEVEL" = "debug" ]; then
        echo "[INFO] $1"
    fi
}

# Function to process docker-compose.yml
process_compose_file() {
    local compose_file=$1

    # Navigate to the directory containing the docker-compose.yml
    local dir=$(dirname "$compose_file")
    cd "$dir" || return

    # Remove comments and empty lines before processing
    local cleaned_file=$(mktemp)
    sed '/^\s*#/d; /^\s*$/d' docker-compose.yml > "$cleaned_file"

    # Parse the cleaned docker-compose.yml for service names
    local services
    services=$(yq eval '.services | keys' "$cleaned_file" 2>/dev/null | sed 's/- //g' || echo "")

    # Check if services were found
    if [ -n "$services" ]; then
        for service in $services; do
            debug_log "Processing $service from $compose_file"
            # Get ports for each service and filter valid port mappings
            local ports
            ports=$(yq eval ".services.$service.ports[]" "$cleaned_file" 2>/dev/null | grep -oP '^\d+:\d+$' || echo "")

            # If ports are found, extract and print them
            if [ -n "$ports" ]; then
                for port_mapping in $ports; do
                    local external_port internal_port
                    external_port=$(echo $port_mapping | cut -d':' -f1)
                    internal_port=$(echo $port_mapping | cut -d':' -f2)
                    printf "%-20s %-15s %-15s\n" "$service" "$external_port" "$internal_port" >> "$temp_file"
                done
            fi
        done
    fi

    # Clean up the temporary file
    rm "$cleaned_file"

    # Go back to the original directory
    cd - > /dev/null
}

# Loop through all directories containing docker-compose.yml
skip_dir=$SCAN_DIR/portainer-ce/data

info_log "Directory to scan : $SCAN_DIR"
info_log "Log level         : $LOG_LEVEL"

find $SCAN_DIR -path $skip_dir -prune -o -name "docker-compose.yml" -print | while read -r compose_file; do
    # Process each compose file
    process_compose_file "$compose_file"
done

# Sort the output by the Port column and display it
sort -k2,2n "$temp_file"

# Clean up the temporary file
rm "$temp_file"
