#!/usr/bin/bash

# ============================================================================
# Script Name:    check_xz_utils.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script takes data from a .csv file and update the info in Active Directory
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-07-02
# ============================================================================

echo "Checking xz-utils status..."
echo "Press Enter to continue..."
read -r

# Check if xz-utils is installed
echo -e "Checking if xz-utils is installed..."
if ! dpkg-query -W -f='${Version}\n' xz-utils 2>/dev/null; then
    echo -e "xz-utils is NOT installed."
    exit 1
fi

echo "Press enter to chefk if the installed version is vulnerable..."
read -r

# Verify if the installed version is vulnerable
XZ_VERSION=$(dpkg-query -W -f='${Version}\n' xz-utils)
if dpkg --compare-versions "$XZ_VERSION" lt "5.2.12"; then
    echo -e "VULNERABLE! Installed version: $XZ_VERSION (needs 5.2.12 or newer)"
else
    echo -e "SAFE. Installed version: $XZ_VERSION"
fi

echo "Press enter to check if an update is available..."
read -r

# Check if an update is available
echo -e "Checking for available updates..."
if apt list --upgradable 2>/dev/null | grep -q "^xz-utils/"; then
    echo -e "An update is available! Run: sudo apt update && sudo apt upgrade xz-utils"
else
    echo -e " No updates available."
fi

echo -e "Check complete."
