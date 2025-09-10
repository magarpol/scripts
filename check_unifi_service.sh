#!/bin/bash

# ============================================================================
# Script Name:    apt_updates.sh
# Author:         Mauro García
# Version:        2.1
# Description:    This local script for checkmk checks Unifi service
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-09-10
# ============================================================================


# Check if the UniFi service is active
if systemctl is-active --quiet unifi; then
    echo "0 UniFi_Service - UniFi Service is running"
    exit 0
else
    echo "2 UniFi_Service - UniFi Service is NOT running!"
    exit 2
fi
