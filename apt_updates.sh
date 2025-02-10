#!/bin/bash

# ============================================================================
# Script Name:    apt_updates.sh
# Author:         Mauro García
# Version:        2.1
# Description:    This script configures APT updates service in CheckMK
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ============================================================================

#APT Update plugin in Linux servers
cp /scripts/data/mk_apt /usr/lib/check_mk_agent/plugins/
chmod 755 /usr/lib/check_mk_agent/plugins/mk_apt
systemctl restart check-mk-agent.socket
