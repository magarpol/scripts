#!/bin/bash
# ============================================================================
# Script Name:    nfs_shares.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script mount NFS Shares in locations typed by the user
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ============================================================================

# User input for mount directory
mount_directory() {
    read -p "Enter the directory where NFS shares should be mounted (default is /mnt): " mount_dir
    if [[ -z "$mount_dir" ]]; then
        mount_dir="/mnt"
    fi
    echo "Mount directory: $mount_dir"
}

# User input for NFS mount points
user_directory() {
    read -p "Enter the name for the directory under $mount_dir: " user_input
    related_mount_dir="$mount_dir/$user_input"
    mkdir -p "$related_mount_dir"
    echo "Directory created: $related_mount_dir"
}

# User input for NFS shares path
get_nfs_shares() {
    echo "Enter the NFS share to be mounted, for example: 'share://folder/folder/folder' one by one"
    echo "When done, press Enter"
    nfs_shares=()
    while true; do
        read -p "> " input
        if [[ -z "$input" ]]; then
            break
        fi
        nfs_shares+=("$input")
    done
}

# Update /etc/fstab
update_fstab() {
    for share in "${nfs_shares[@]}"; do
        echo "$share $related_mount_dir  nfs  rw  0  0" |  tee -a /etc/fstab
    done
}

# Mount NFS shares
mount_shares() {
    mount -a
    echo "NFS shares mounted"
    ls "$related_mount_dir"
}

