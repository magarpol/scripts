#!/bin/bash
# ============================================================================
# Script Name:    docker_service.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script configures the files for the CheckMk agent and Docker Service
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ============================================================================

# Usage:
#   ./username_migration.sh
#
# Notes:
# - Ensure you have a backup before running.
# - Run this script with root privileges.

apt install python3-docker
cd /tmp/
cp mk_docker.py /usr/lib/check_mk_agent/plugins/
cp docker.cfg /usr/lib/check_mk_agent/plugins/
chmod 0755 /usr/lib/check_mk_agent/plugins/mk_docker.py
cd /usr/lib/check_mk_agent/plugins/
/usr/bin/python3 mk_docker.py
