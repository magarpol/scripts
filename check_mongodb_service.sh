#!/bin/bash

# ============================================================================
# Script Name:    apt_updates.sh
# Author:         Mauro García
# Version:        2.1
# Description:    This local script for checkmk checks the mongodb process in Unifi
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-09-10
# ============================================================================

# Check for the MongoDB process started by UniFi
# The 'grep -v grep' excludes the 'grep' command itself from the results
if pgrep -f "mongodb.*dbpath" > /dev/null || pgrep -f "bin/mongod" > /dev/null; then
    echo "0 MongoDB_Process - UniFi's MongoDB Process is running"
    exit 0
else
    echo "2 MongoDB_Process - UniFi's MongoDB Process is NOT running!"
    exit 2
fi
