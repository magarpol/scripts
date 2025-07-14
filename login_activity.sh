#!/bin/bash

# ============================================================================
# Script Name:    distro_upgrade.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script adds service in CheckMK to monitor login activity
#                 in the past 90 days
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-07-14
# ============================================================================


# Number of unique users needed for OK
THRESHOLD=3

# Time range: last 90 days
SINCE="90 days ago"

# Exclude users (comma-separated, regex compatible)
EXCLUDED_USERS="^(ansible)$"

# Extract unique SSH login users from journal
USERS=$(journalctl --since="$SINCE" _COMM=sshd | grep 'Accepted' | awk '{print $9}' | grep -Ev "$EXCLUDED_USERS" | sort | uniq)
USER_COUNT=$(echo "$USERS" | wc -l)

# Flatten user list to a comma-separated string
USER_LIST=$(echo "$USERS" | paste -sd, -)

if [ "$USER_COUNT" -lt "$THRESHOLD" ]; then
    echo "1 login_activity - Only $USER_COUNT user(s) logged in in the last 90 days: $USER_LIST"
else
    echo "0 login_activity - $USER_COUNT user(s) logged in in the last 90 days: $USER_LIST"
fi
