#!/usr/bin/env bash

# Function to load profile
load_profile() {
    local profile_file="$1"
    while IFS=' = ' read -r key value; do
        case "$key" in
            HOST) export HOST="$value" ;;
            USERNAME) export USERNAME="$value" ;;
            PASSWORD) export PASSWORD="$value" ;;
            EXPIRATION_DATE) export EXPIRATION_DATE="$value" ;;
        esac
    done < <(grep -E 'HOST|USERNAME|PASSWORD|EXPIRATION_DATE' "$profile_file")

    # Update settings.ini with the loaded values
    sed -i "s|^host = .*|host = $HOST|" settings.ini
    sed -i "s|^username = .*|username = $USERNAME|" settings.ini
    sed -i "s|^password = .*|password = $PASSWORD|" settings.ini
}

# Check if profile file is passed as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <profile_file>"
    exit 1
fi

# Load the profile
load_profile "$1"

echo "Expiration Date: $EXPIRATION_DATE"

