#!/bin/bash

# ============================================================================
# Script Name:    update_docker_gpg_key.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script updates the docker GPG key
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-02-10
# ============================================================================

# Create directory for keyrings
mkdir -p /usr/share/keyrings
chmod 0755 /usr/share/keyrings

# Move Docker GPG key to secure location
mv /etc/apt/trusted.gpg.d/docker.gpg /usr/share/keyrings/docker-archive-keyring.gpg
chmod 0644 /usr/share/keyrings/docker-archive-keyring.gpg

# Find the correct Docker repository file
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"
ARCHIVE_LIST=$(ls /etc/apt/sources.list.d/ | grep -E 'archive_uri-https_download_docker_com_linux_debian-bookworm.list' | head -n 1)

# Update Docker repository file
if [ -n "$DOCKER_LIST" ]; then
    sed -i 's|deb \[arch=amd64\] |deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] |' "$DOCKER_LIST"
    echo "Docker repository updated in $DOCKER_LIST."
fi 

# Update Archive repository file
if [ -n "$ARCHIVE_LIST" ]; then
    sed -i 's|deb \[arch=amd64\] |deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] |' "/etc/apt/sources.list.d/$ARCHIVE_LIST"
    echo "Updated Docker repository in /etc/apt/sources.list.d/$ARCHIVE_LIST" 
fi

# Remove the old GPG key file
rm -f /etc/apt/trusted.gpg

apt update

