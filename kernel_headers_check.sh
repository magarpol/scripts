#!/bin/bash

# ============================================================================
# Script Name:    kernel_headers_check.sh
# Author:         Mauro García
# Version:        2.0
# Description:    This script install the missing kernel headers
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-01-30
# ============================================================================

# Get the running kernel version
KERNEL_VERSION=$(uname -r)

# Determine the package name for kernel headers
if [[ -f /etc/debian_version ]]; then
    PACKAGE="linux-headers-${KERNEL_VERSION}"
elif [[ -f /etc/redhat-release ]]; then
    PACKAGE="kernel-devel-${KERNEL_VERSION}"
elif [[ -f /etc/os-release ]] && grep -qi "opensuse" /etc/os-release; then
    PACKAGE="kernel-devel-${KERNEL_VERSION}"
    if ! zypper search --match-exact "$PACKAGE" &>/dev/null; then
        PACKAGE="kernel-default-devel"
    fi 
else
    echo "Unsupported distribution."
    exit 1
fi

# Check if the kernel headers are installed
if [[ -f /etc/debian_version ]]; then 
    if ! dpkg-query -W -f='${Status}' "$PACKAGE" 2>/dev/null | grep -q "installed"; then

        echo "Intalling missing headers for $KERNEL_VERSION"

        apt update && apt install -y "$PACKAGE"

        echo "Headers for $KERNEL_VERSION installed successfully"
    else
        echo "Headers for $KERNEL_VERSION are already installed"
    fi

elif [[ -f /etc/redhat-release ]]; then
    if ! rpm -q "$PACKAGE" &>/dev/null; then

        echo "Intalling missing headers for $KERNEL_VERSION"

        yum install -y "$PACKAGE" || dnf install -y "$PACKAGE"

        echo "Headers for $KERNEL_VERSION installed successfully"
    else
        echo "Headers for $KERNEL_VERSION are already installed"
    fi

elif [[ -f /etc/os-release ]] && grep -qi "opensuse" /etc/os-release; then
    if ! rpm -q "$PACKAGE" &>/dev/null; then

        echo "Intalling missing headers for $KERNEL_VERSION"

        zypper install -y "$PACKAGE"

        echo "Headers for $KERNEL_VERSION installed successfully"
    else
        echo "Headers for $KERNEL_VERSION are already installed"
    fi
else
    echo "Distro not supported."
    exit 1
fi

