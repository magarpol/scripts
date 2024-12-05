#!/bin/bash

##################################################
# Script for installing self-signed certificates #
##################################################

# Create .txt file
cd /tmp
touch certconfig.txt

# Add the following content to the file
cat << 'EOF' > /tmp/certconfig.txt
[ req ]

default_bits        = 2048

default_keyfile     = server.key

distinguished_name  = subject

req_extensions      = req_ext

x509_extensions     = x509_ext

string_mask         = utf8only

prompt              = no


[ subject ]

commonName          = server.com # Replace with your hostname


# Section x509_ext is used when generating a self-signed certificate.

[ x509_ext ]

subjectKeyIdentifier    = hash

authorityKeyIdentifier  = keyid,issuer

basicConstraints        = CA:FALSE

keyUsage                = digitalSignature, keyEncipherment

subjectAltName          = @alternate_names

nsComment               = "OpenSSL Generated Certificate"

extendedKeyUsage        = serverAuth, clientAuth



# Section req_ext is used when generating a certificate signing request.

[ req_ext ]

subjectKeyIdentifier = hash

basicConstraints     = CA:FALSE

keyUsage             = digitalSignature, keyEncipherment

subjectAltName       = @alternate_names

nsComment            = "OpenSSL Generated Certificate"

extendedKeyUsage     = serverAuth, clientAuth



[ alternate_names ]

DNS.1 = server  # Replace with your FQDN

DNS.2 = *.server.domain.de # Replace with your FQDN
EOF

# Create the certificates
openssl req -config certconfig.txt -nodes -x509 -newkey rsa:2048 -sha256 -keyout server.key -out server.cert -days 365

# Key and Cert to a PEM file
cat server.key server.cert > server.pem

# Conversion from pem to pfx
openssl pkcs12 -export -out server.pfx -inkey server.key -in server.cert