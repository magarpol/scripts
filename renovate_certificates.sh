#!/bin/bash

# ===========================================================================
# Script Name:    renovate_certificates.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script creates a .p12 file from .pem LetsEncrypt
# certificates and imports the file to the keystore
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-01-30
# ===========================================================================


set -e

#convert cert + key to .p12 format
sudo openssl pkcs12 -export \
  -in /tmp/fullchain.pem \
  -inkey /tmp/privkey.pem \
  -out /var/lib/unifi/unifi.p12 \
  -name unifi \
  -password pass:aircontrolenterprise

#backup existing UniFi keystore
cp /var/lib/unifi/keystore /var/lib/unifi/keystore.bak.$(date +%F)

#change ownership
chown unifi:unifi /var/lib/unifi/unifi.p12

#import .p12 into UniFi keystore
sudo -u unifi keytool -importkeystore \
  -deststorepass aircontrolenterprise \
  -destkeypass aircontrolenterprise \
  -destkeystore /var/lib/unifi/keystore \
  -srckeystore /var/lib/unifi/unifi.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass aircontrolenterprise \
  -alias unifi -noprompt

systemctl restart unifi
