#!/bin/bash

# ============================================================================
# Script Name:    check_cert_ftp.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script checks out the ftp certificates for CheckMK
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-05-22
# ============================================================================

echo "<<<local>>>"

CERT_PATH="<path_to_cert>"
NAME="<hostname>"

check_cert() {
    if [[ ! -f "$CERT_PATH" ]]; then
        echo "[${NAME}_certificate]"
        echo "3 ${NAME}_certificate - Certificate file not found at $CERT_PATH"
        return
    fi

    expire_date=$(openssl x509 -enddate -noout -in "$CERT_PATH" | cut -d= -f2)
    expire_epoch=$(date -d "$expire_date" +%s)
    current_epoch=$(date +%s)
    days_left=$(( (expire_epoch - current_epoch) / 86400 ))
    formatted_expire=$(date -d "$expire_date" "+%Y-%m-%d")

    if [ "$days_left" -le 7 ]; then
        status=2  # CRIT
    elif [ "$days_left" -le 14 ]; then
        status=1  # WARN
    else
        status=0  # OK
    fi

    echo "[${NAME}_certificate]"
    echo "$status ${NAME}_certificate - Days left: $days_left (Expires: $formatted_expire)"
}

check_cert
