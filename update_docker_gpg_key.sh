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

# Update Docker repository file
sed -i 's|deb \[arch=amd64\] |deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] |' /etc/apt/sources.list.d/docker.list

# Remove the old GPG key file
rm -f /etc/apt/trusted.gpg

apt update
