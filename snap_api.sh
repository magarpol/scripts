#!/bin/bash

# ============================================================================
# Script Name:    snap_api.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script solves the snapAPI error from Acronis, the kernel
#                 version must be entered manually
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ============================================================================


##########################################################
#         Optimized Script for snapAPI error             #
##########################################################

#!/bin/bash

# Navigate to the Acronis kernel modules directory
echo "Navigating to /usr/lib/Acronis/kernel_modules/"
cd /usr/lib/Acronis/kernel_modules/ || { echo "Directory not found! Exiting."; exit 1; }

# Extract version numbers from the tar.gz file
SNAP_TAR=$(ls snapapi26-*.tar.gz | head -n 1)
if [[ -z "$SNAP_TAR" ]]; then
    echo "No snapapi26 tarball found! Exiting."
    exit 1
fi

VERSION=$(echo "$SNAP_TAR" | grep -oP '\d+\.\d+\.\d+' | head -n 1)
echo "Detected version: $VERSION"

# Extract the tarball
echo "Extracting $SNAP_TAR"
tar xvfz "$SNAP_TAR"

# Create the required directory
echo "Creating directory /usr/src/snapapi26-$VERSION"
mkdir -p "/usr/src/snapapi26-$VERSION"

# Move files to the new directory
echo "Moving files to /usr/src/snapapi26-$VERSION"
mv /usr/lib/Acronis/kernel_modules/dkms_source_tree/* "/usr/src/snapapi26-$VERSION/"

# Modify the dkms.conf file
echo "Modifying dkms.conf to comment out REMAKE_INITRD"
sed 's/REMAKE_INITRD/#REMAKE_INITRD/' -i "/usr/src/snapapi26-$VERSION/dkms.conf"

# Update package lists
echo "Updating package lists"
apt update

# Ask for kernel headers input
echo "Please enter the kernel version (e.g., 6.1.0-29-cloud-amd64):"
read -r KERNEL_VERSION
if [[ -z "$KERNEL_VERSION" ]]; then
    echo "No kernel version provided. Exiting."
    exit 1
fi

# Install the specified kernel headers
echo "Installing linux-headers-$KERNEL_VERSION"
apt install -y "linux-headers-$KERNEL_VERSION"

# Build the DKMS module
echo "Building DKMS module snapapi26 version $VERSION"
dkms build -m snapapi26 -v "$VERSION" --config /boot/config-$(uname -r) --arch $(uname -p)

# Install the DKMS module
echo "Installing DKMS module snapapi26 version $VERSION"
dkms install -m snapapi26 -v "$VERSION"

# Load the module
echo "Loading module snapapi26"
modprobe snapapi26

# Restart the Acronis service
echo "Restarting Acronis service"
systemctl restart acronis_mms

echo "Script completed successfully."
