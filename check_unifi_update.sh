#!/bin/bash

# ============================================================================
# Script Name:    check_unifi_update
# Author:         Mauro García
# Version:        1.0
# Description:    This script creates a local service in CheckMK that monitors
#                 if unifi needs an update
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-12-01
# ============================================================================


# Exit codes for CheckMK:
# 0 = OK
# 1 = WARNING
# 2 = CRITICAL
# 3 = UNKNOWN

# Update package lists
apt-get update >/dev/null 2>&1

# Check for unifi upgrade
if apt list --upgradable 2>/dev/null | grep -q "unifi/"; then
        # Critical - unifi update available
        echo "2 \"Unifi Update Check\" - Unifi controller update available!"
        exit 2
else
        # OK - no updates available
        echo "0 \"Unifi Update Check\" - No Unifi updates available"
        exit 0
fi
