#!/bin/bash

# ============================================================================
# Script Name:    check_wildcard_certs.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script looks for expiration date on wildcard certificates
#                 and creates a service in CheckMK to monitor them
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-03-25
# ============================================================================


# Certificate to monitor
expire_date=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/bpanda.ai/fullchain.pem" | cut -d= -f 2)
expire_epoch=$(date -d "$expire_date" +%s)
current_epoch=$(date +%s)
days_left=$(( ($expire_epoch - $current_epoch) / 86400 ))

# Status for CRIT, WARN, OK
if [ "$days_left" -le 7 ]; then
    status=2 # CRIT
elif [ "$days_left" -le 14 ]; then
    status=1 # WARN
else
    status=0 # OK
fi

# Check_MK output
echo "<<<local>>>"
echo "[bpanda_certificate]"
echo "$status bpanda_certificate - Days left: $days_left | expire='$days_left' days;14;7"
