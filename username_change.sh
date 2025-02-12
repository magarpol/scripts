#!/bin/bash

# ==================================================================================
# Script Name:    username_change.sh
# Author:         Mauro García
# Version:        2.1
# Description:    This script changes usernames, moves public keys from 
#                 /root/.ssh/authorized_keys to /home/username/.ssh/authorized_keys, 
#                 and removes old user data from /etc/passwd.
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ==================================================================================

#########################################################
# Function to change username and update home directory #
#########################################################
change_username() {
    local old_username=$1
    local new_username=$2

    # Rename user
    usermod -l "$new_username" "$old_username"

    # Rename home directory
    usermod -d "/home/$new_username" -m "$new_username"

    mkdir -p "/home/$new_username/.ssh"
    chmod 700 "/home/$new_username/.ssh"
    touch "/home/$new_username/.ssh/authorized_keys"
    chmod 600 "/home/$new_username/.ssh/authorized_keys"
    chown "$new_username:$new_username" "/home/$new_username/.ssh" "/home/$new_username/.ssh/authorized_keys"

    echo "User $old_username has been renamed to $new_username and home directory updated."
}

##################################################
# Function to delete old users with data zipping #
##################################################
delete_user() {
    local username=$1
    local admin_home="/tmp"
    local backup_dir="${admin_home}/user_backups"

    mkdir -p "$backup_dir"  # Ensure backup directory exists

    if id "$username" &>/dev/null; then
        echo "Creating backup for $username..."
        tar -czf "${backup_dir}/${username}.tar.gz" "/home/$username" &>/dev/null
        echo "Backup created at ${backup_dir}/${username}.tar.gz"

        echo "Deleting user $username..."
        userdel -r "$username"
        echo "User $username has been deleted."
    else
        echo "User $username does not exist."
    fi
}

########################################################################
# Function to copy selected public key to the new user authorized_keys #
########################################################################
copy_public_key() {
    local new_name=$1
    local root_ssh_file="/root/.ssh/authorized_keys"
    local user_ssh_file="/home/$new_name/.ssh/authorized_keys"

    echo "Available public keys in /root/.ssh/authorized_keys:"
    awk '/^ssh-(rsa|dss|ecdsa|ed25519)/ {print NR " ) " substr($0, length($0)-25, 24)}' "$root_ssh_file"

    read -p "Enter the number of the public key to move: " key_choice
    if [ -z "$key_choice" ]; then
        echo "No key selected. Skipping key move."
        return
    fi

    local selected_key
    selected_key=$(awk "NR == $key_choice {print}" "$root_ssh_file")

    if [ -n "$selected_key" ]; then
        echo "$selected_key" > "$user_ssh_file"
        chmod 600 "$user_ssh_file"
        chown "$new_name:$new_name" "$user_ssh_file"

        sed -i "${key_choice}d" "$root_ssh_file"
        echo "Public key moved to $user_ssh_file and removed from $root_ssh_file."
    else
        echo "Invalid key selection."
    fi
}

#################################################
# Function to clean up :0:0: entries in passwd  #
#################################################
cleanup_passwd_entry() {
    local passwd_file="/etc/passwd"
    echo "Listing all ':0:0:' entries in $passwd_file:"
    awk -F: '$3 == 0 && $4 == 0 {print NR " ) " $1 " (UID: " $3 ", GID: " $4 ")"}' "$passwd_file"

    read -p "Enter the number of the account to modify (or press Enter to skip): " entry_choice

    if [ -z "$entry_choice" ]; then
        echo "No account selected. Exiting."
        return
    fi

    selected_user=$(awk -F: -v choice="$entry_choice" '$3 == 0 && $4 == 0 {if (NR == choice) print $1}' "$passwd_file")

    if [ -z "$selected_user" ]; then
        echo "Invalid selection. Exiting."
        return
    fi

    read -p "Enter new username for $selected_user: " new_name
    if [ -z "$new_name" ]; then
        echo "New username cannot be empty. Exiting."
        return
    fi

    change_username "$selected_user" "$new_name"
}

# Ensure cleanup is explicitly called after setting up the user
copy_public_key "$new_name"
echo "Public key has been moved for $new_name."
cleanup_passwd_entry  # Prompt for cleanup before proceeding

# Confirmation before moving to the next user
read -p "Press Enter to proceed to the next user, or Ctrl+C to stop: " proceed


# Call cleanup after moving the public key
copy_public_key "$new_name"
cleanup_passwd_entry

############################
# Prevent locking user out #
############################
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

current_user=$(whoami)

###########
# Dry run #
###########
dry_run_mode=false
if [ "$1" = "--dry-run" ]; then
    dry_run_mode=true
    echo "Dry run mode enabled."
fi

#########################################################
# Get the list of all users (excluding system accounts) #
#########################################################
uid_min=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
all_users=$(awk -F: -v uid_min="$uid_min" '$3 >= uid_min && $3 != 65534 {print $1}' /etc/passwd)

##########################
# Loop through all users #
##########################
for user in $all_users; do
    if [ "$user" = "$current_user" ]; then
        continue
    fi

    read -p "User $user new name?: " new_name

    if [ -z "$new_name" ]; then
        echo "Skipping user $user."
        continue
    fi

    if $dry_run_mode; then
        echo "Dry run: Changing username from $user to $new_name."
    else
        change_username "$user" "$new_name"
    fi

    if ! id "$new_name" &>/dev/null; then
        echo "User $new_name does not exist. Creating user..."
        adduser --home "/home/$new_name" --gecos "" --disabled-password "$new_name"
        usermod -aG sudo "$new_name"
    fi

    copy_public_key "$new_name"
done

#####################################
# Clean up /etc/passwd invalid data #
#####################################
cleanup_passwd_entry
copy_public_key "$new_name"
backup_old_data "$selected_user"
delete_user_entry "$selected_user"

###########################
# Prompt to delete a user #
###########################
read -p "Do you want to delete a user? (y/n): " delete_choice

if [ "$delete_choice" = "y" ] || [ "$delete_choice" = "Y" ]; then
    while true; do
        read -p "Enter the username to delete: " user_to_delete

        if [ -z "$user_to_delete" ]; then
            break
        fi

        if [ "$user_to_delete" = "$current_user" ]; then
            echo "You cannot delete your own account ($current_user)."
            continue
        fi

        if $dry_run_mode; then
            echo "Dry run: Deleting user $user_to_delete."
        else
            delete_user "$user_to_delete"
        fi
    done
fi


