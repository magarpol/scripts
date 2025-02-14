#!/bin/bash

# ============================================================================
# Script Name:    kernel_headers_check.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script install the missing kernel headers
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-01-30
# ============================================================================


# Get the running kernel version
KERNEL_VERSION=$(uname -r)
PACKAGE="linux-headers-${KERNEL_VERSION}"

# Check if the kernel headers are installed
if ! dpkg-query -W -f='${Status}' "$PACKAGE" 2>/dev/null | grep -q "installed"; then

    echo "Intalling missing headers for $KERNEL_VERSION"

    apt update && apt install -y "$PACKAGE"

    echo "Headers for $KERNEL_VERSION installed successfully"
else
    echo "Headers for $KERNEL_VERSION are already installed"
fi
