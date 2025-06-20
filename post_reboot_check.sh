#!/bin/bash

# ============================================================================
# Script Name:    certbot_automate.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script does a post reboot check on system state after reboot
#                 and compares it with pre_reboot_check.sh
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-06-20
# ============================================================================

PRE_DIR="/root/reboot-check/pre"
POST_DIR="/root/reboot-check/post"
mkdir -p "$POST_DIR"

echo "[*] Collecting post-reboot state to $POST_DIR ..."

systemctl list-units --type=service --state=running > "$POST_DIR/running-services.txt"
systemctl list-unit-files --state=enabled > "$POST_DIR/enabled-services.txt"
ss -tulpen > "$POST_DIR/listening-ports.txt"
df -h > "$POST_DIR/disk-usage.txt"
mount | grep "^/" > "$POST_DIR/mounts.txt"
crontab -l > "$POST_DIR/crontab.txt" 2>/dev/null
ls /etc/cron.* /var/spool/cron/crontabs/ > "$POST_DIR/cron-system.txt" 2>/dev/null
systemctl --failed > "$POST_DIR/failed-services.txt"
journalctl -p 3 -xb > "$POST_DIR/critical-logs.txt"

if command -v docker &>/dev/null; then
    docker ps > "$POST_DIR/docker-containers.txt"
fi

echo "[*] Comparing pre- and post-reboot states..."

for FILE in $(ls "$PRE_DIR"); do
    echo -e "\n--- Comparing: $FILE ---"
    diff -u "$PRE_DIR/$FILE" "$POST_DIR/$FILE" || echo "[!] Difference or new entries found in $FILE"
done

echo -e "\n[✓] Comparison complete."
