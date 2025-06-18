#!/bin/bash

# ============================================================================
# Script Name:    distro_upgrade.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script adds service in CheckMK to monitor if a distribution
#                 upgrade is available.
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-06-18
# ============================================================================

# Get current version and codename
current_version=$(lsb_release -r | awk '{print $2}')
current_codename=$(lsb_release -c | awk '{print $2}')

# Get candidate version and codename from base-files (part of the OS versioning)
candidate_version=$(apt-cache policy base-files | awk '/Candidate:/ {print $2}' | cut -d'-' -f1)
candidate_codename=$(apt-cache show base-files | awk '/^Codename:/ {print $2}' | head -n1)

# Fallback for codename if not found (some versions may not have Codename in base-files)
if [[ -z "$candidate_codename" ]]; then
    candidate_codename=$(grep "VERSION=" /etc/os-release | sed -E 's/.*\((.*)\).*/\1/')
fi

# Extract major.minor
current_major=$(echo "$current_version" | cut -d'.' -f1)
candidate_major=$(echo "$candidate_version" | cut -d'.' -f1)

current_short=$(echo "$current_version" | cut -d'.' -f1-2)
candidate_short=$(echo "$candidate_version" | cut -d'.' -f1-2)

# Compare versions
if [[ "$current_short" == "$candidate_short" ]]; then
    echo "0 Debian_Upgrade - OK - Debian $current_short ($current_codename) is up to date"
elif [[ "$current_major" -lt "$candidate_major" ]]; then
    echo "2 Debian_Upgrade - CRIT - Major upgrade available: Debian $current_short ($current_codename>
else
    echo "1 Debian_Upgrade - WARN - Minor upgrade available: Debian $current_short ($current_codename>
fi
