#!/bin/bash

# ============================================================================
# Script Name:    renew_unifi_certificate.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script creates a PKCS12 file from LetsEncrypt Certs, imports it
#                 into Java keystore and restarts the unifi service
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-09-19
# ============================================================================

echo "Creating PKCS12 file from certs..."
openssl pkcs12 -export \
  -inkey /tmp/privkey.pem \
  -in /tmp/fullchain.pem \
  -out /usr/lib/unifi/data/unifi.p12 \
  -name unifi \
  -password pass:aircontrolenterprise

echo "Backing up" existing UniFi keystore
cp /usr/lib/unifi/data/keystore /usr/lib/unifi/data/keystore.bak.$(date +%F)

echo "Importing new cert into UniFi keystore..."
keytool -importkeystore \
  -deststorepass aircontrolenterprise \
  -destkeypass aircontrolenterprise \
  -destkeystore /usr/lib/unifi/data/keystore \
  -srckeystore /usr/lib/unifi/data/unifi.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass aircontrolenterprise \
  -alias unifi -noprompt

echo "Restarting UniFi service..."
systemctl restart unifi

echo "Done. New certificate imported and UniFi restarted."
