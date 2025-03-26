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


#!/bin/bash

# ============================================================================
# Script Name:    check_wildcard_certs.sh
# Author:         Mauro García
# Version:        2.0
# Description:    This script looks for expiration date on wildcard certificates
#                 and creates a service in CheckMK to monitor them
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-03-26
# ============================================================================

echo "<<<local>>>"

# Function to check the expiration date of a certificate
check_cert() {
    local domain=$1
    local cert_path="/etc/letsencrypt/live/$domain/fullchain.pem"

    expire_date=$(openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f 2)
    expire_epoch=$(date -d "$expire_date" +%s)
    current_epoch=$(date +%s)
    days_left=$(( ($expire_epoch - $current_epoch) / 86400 ))
    formatted_expire=$(date -d "$expire_date" "+%Y-%m-%d")  # Format: 2025-12-31 

    # Status for CRIT, WARN, OK
    if [ "$days_left" -le 7 ]; then
        status=2 # CRIT
    elif [ "$days_left" -le 14 ]; then
        status=1 # WARN
    else
        status=0 # OK
    fi

    echo "[${domain}_certificate]"
    echo "$status ${domain}_certificate - Days left: $days_left (Expires: $formatted_expire)"
}

# Check every certificate
check_cert example.com
check_cert another.domain 
