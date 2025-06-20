#!/bin/bash

# ============================================================================
# Script Name:    pre-reboot_check.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script does a post reboot check on system state before reboot.
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-06-20
# ============================================================================

REPORT_DIR="/root/reboot-check/pre"
mkdir -p "$REPORT_DIR"

echo "Saving pre-reboot system state to $REPORT_DIR ..."

systemctl list-units --type=service --state=running > "$REPORT_DIR/running-services.txt"
systemctl list-unit-files --state=enabled > "$REPORT_DIR/enabled-services.txt"
ss -tulpen > "$REPORT_DIR/listening-ports.txt"
df -h > "$REPORT_DIR/disk-usage.txt"
mount | grep "^/" > "$REPORT_DIR/mounts.txt"
crontab -l > "$REPORT_DIR/crontab.txt" 2>/dev/null
ls /etc/cron.* /var/spool/cron/crontabs/ > "$REPORT_DIR/cron-system.txt" 2>/dev/null
systemctl --failed > "$REPORT_DIR/failed-services.txt"
journalctl -p 3 -xb > "$REPORT_DIR/critical-logs.txt"

# Optional: capture Docker containers if Docker is installed
if command -v docker &>/dev/null; then
    docker ps > "$REPORT_DIR/docker-containers.txt"
fi

echo "Pre-reboot data collection complete."
