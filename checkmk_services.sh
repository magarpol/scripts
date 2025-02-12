#!/bin/bash

# ==============================================================================================
# Script Name:    checkmk_services.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script configures the files for the CheckMk agent and different services.
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-02-12
# ==============================================================================================

##################
# Docker service #
##################
apt install python3-docker
cp /scripts/data/mk_docker.py /usr/lib/check_mk_agent/plugins/
cp /scripts/data/docker.cfg /usr/lib/check_mk_agent/plugins/
chmod 0755 /usr/lib/check_mk_agent/plugins/mk_docker.py
cd /usr/lib/check_mk_agent/plugins/
/usr/bin/python3 mk_docker.py

echo "Docker service configured"

###############
# APT Updates #
###############
cp /scripts/data/mk_apt /usr/lib/check_mk_agent/plugins/
chmod 755 /usr/lib/check_mk_agent/plugins/mk_apt
systemctl restart check-mk-agent.socket

echo "APT Updates service configured"

##################
# Osinfo service # 
##################
cp /scripts/data/osinfo /usr/lib/check_mk_agent/plugins/
chmod +x /usr/lib/check_mk_agent/plugins/osinfo

echo "Osinfo service configured"

##################
# Reboot service #
##################
cp /scripts/data/reboot /usr/lib/check_mk_agent/plugins/
chmod +x /usr/lib/check_mk_agent/plugins/reboot

echo "Reboot service configured"
