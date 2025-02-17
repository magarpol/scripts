#!/bin/bash

# ============================================================================
# Script Name:    update_docker_gpg_key.sh
# Author:         Mauro García
# Version:        2.0
# Description:    This script updates the docker GPG key
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-02-10
# ============================================================================

# Create directory for keyrings
mkdir -p /usr/share/keyrings
chmod 0755 /usr/share/keyrings

# Move Docker GPG key if the file exists
if [ -f "/etc/apt/trusted.gpg.d/docker.gpg" ]; then
    mv /etc/apt/trusted.gpg.d/docker.gpg /usr/share/keyrings/docker-archive-keyring.gpg
    chmod 0644 /usr/share/keyrings/docker-archive-keyring.gpg
    echo "Moved Docker GPG key to /usr/share/keyrings/docker-archive-keyring.gpg"
else
    echo "Docker GPG key not found, skipping move."
fi

# Find sources files that contains "download.docker.com"
APT_FILES=$(grep -Rl "^deb.*download.docker.com" /etc/apt)

if [ -n "$APT_FILES" ]; then
    for FILE in $APT_FILES; do
        # Backup the original file
        cp "$FILE" "$FILE.bak"

        # Modify the repository file
        sed -i 's|deb \[arch=amd64\] |deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] |' "$FILE"

        echo "Updated Docker repository in $FILE"
    done
else
    echo "No Docker APT source found"
fi 

apt update

