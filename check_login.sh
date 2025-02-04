#!/bin/bash

# CheckMK local checks for sucessful login attempts
# Author: Mauro García
# Version: 1.0
# Description: Logs into multiple URLs and triggers an alert if login fails

# CheckMK output format: <status> <service_name> - <message>
# Status: 0 = OK, 1 = WARNING, 2 = CRITICAL

# Login credentials
USERNAME="username"
PASSWORD="password"

# URLs to check
URLS=(
    "https://goto.bpanda.com"
    "https://goto-trial.bpanda.com"
    "https://goto-camp.bpanda.com"
    "https://keycloak.mid.de/"
    "https://goto-trial-camp.bpanda.com"
    "https://repo.mid.de"
    "https://status.mid.de"
)

# Function to check login
check_login() {
    local url=$1
    response=$(curl -s -o /dev/null -w "%{http_code}" -u "$USERNAME:$PASSWORD" --max-time 10 "$url")

    if [[ $response -ge 200 && $response -lt 400 ]]; then
        echo "0 Login_Check_$url - Login successful"
    else
        echo "2 Login_Check_$url - CRITICAL: Login failed with status code $response"
    fi
}

# Run login checks
for url in "${URLS[@]}"; do
    check_login "$url"
done
