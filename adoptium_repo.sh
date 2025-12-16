#!/bin/bash

# ============================================================================
# Script Name:    adoptium_repo
# Author:         Mauro García
# Version:        1.0
# Description:    This script creates an Adoptium Repo Update Service in CheckMK
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-12-16
# ============================================================================


ARCH=$(uname -m)
check() { curl -s --head "https://packages.adoptium.net/artifactory/rpm/opensuse/$1/$ARCH/" | head -n1 | grep -q "200\|301\|302"; }

check "16.0" && echo "2 Adoptium_16.0_repo - AVAILABLE" && exit 2
check "15.6" && echo "1 Adoptium_15.6_repo - Available" && exit 1
echo "0 Adoptium_repos - No new repos"
