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

#!/bin/bash

# ============================================================================
# Script Name:    username_migration.sh
# Author:         Mauro García
# Version:        1.6
# Description:    This script changes usernames, moves public keys from 
#                 /root/.ssh/authorized_keys to /home/username/.ssh/authorized_keys, 
#                 and removes old user data from /etc/passwd.
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ============================================================================

#!/bin/bash

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
    local user_ssh_dir="/home/$new_name/.ssh"
    local user_ssh_file="$user_ssh_dir/authorized_keys"

    # Gather Keys from /root/.ssh/authorized_keys
    echo "Available public keys in /root/.ssh/authorized_keys:"
    awk '/^ssh-(rsa|dss|ecdsa|ed25519)/ {print NR " ) " substr($0, length($0)-9, 20)}' "$root_ssh_file"
    read -p "Enter the number of the public key to copy: " key_choice

    # If no key selected, skip
    if [[ -z "$key_choice" ]]; then
        echo "No key selected. Skipping key copy."
        return
    fi

    # Write the selected key to the new user's authorized_keys
    local selected_key=$(awk "NR == $key_choice {print}" "$root_ssh_file")
    echo "$selected_key" > "$user_ssh_file"
    chmod 600 "$user_ssh_file"
    chown "$new_name:$new_name" "$user_ssh_dir" "$user_ssh_file"

    # Remove the key from root's authorized_keys
    sed -i "${key_choice}d" "$root_ssh_file"
    echo "Selected public key has been moved to $user_ssh_file and removed from $root_ssh_file."
}

#################################################
# Function to clean up :0:0: entries in passwd  #
#################################################
# Ensure cleanup_passwd_entry is defined as part of the process
cleanup_passwd_entry() {
    local passwd_file="/etc/passwd"

    # Find all entries containing ":0:0:"
    local invalid_entries
    invalid_entries=$(awk -F: '$3 == 0 && $4 == 0 {print NR " ) " $0}' "$passwd_file")

    # If no invalid entries are found, exit
    if [[ -z "$invalid_entries" ]]; then
        echo "No invalid ':0:0:' entries found in $passwd_file for cleanup."
        return
    fi

    echo "Invalid ':0:0:' entries found:"
    echo "$invalid_entries"

    # Loop until the user selects an entry or decides to skip
    while true; do
        read -p "Enter the number of the entry to delete (or press Enter to skip): " entry_choice

        # If no entry is selected, break the loop
        if [[ -z "$entry_choice" ]]; then
            echo "No entry selected. Skipping cleanup."
            break
        fi

        # Validate the input and delete the selected entry
        local line_to_delete
        line_to_delete=$(awk -v choice="$entry_choice" -F: '$3 == 0 && $4 == 0 {if (NR == choice) print NR}' "$passwd_file")

        if [[ -n "$line_to_delete" ]]; then
            sed -i "${line_to_delete}d" "$passwd_file"
            echo "Entry number $entry_choice has been removed from $passwd_file."
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Ensure cleanup is explicitly called after setting up the user
copy_public_key "$new_name"
echo "Public key has been moved for $new_name."
cleanup_passwd_entry  # Prompt for cleanup before proceeding

# Confirmation before moving to the next user
read -p "Press Enter to proceed to the next user, or Ctrl+C to stop: " proceed


# Call cleanup after moving the public key
#copy_public_key "$new_name"
#cleanup_passwd_entry

############################
# Prevent locking user out #
############################
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

current_user=$(whoami)

###########
# Dry run #
###########
dry_run_mode=false
if [[ "$1" == "--dry-run" ]]; then
    dry_run_mode=true
    echo "Dry run mode enabled."
fi

########################################################
# Get the list of all users (excluding system accounts) #
########################################################
uid_min=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
all_users=$(awk -F: -v uid_min="$uid_min" '{ if ($2 >= uid_min && $2 != 65534) print $1 }' /etc/passwd)

##########################
# Loop through all users #
##########################
for user in $all_users; do
    if [[ "$user" == "$current_user" ]]; then
        continue
    fi

    echo -n "User $user new name?: "
    read new_name

    # If new name is empty, skip
    if [[ -z $new_name ]]; then
        echo "Skipping user $user."
        continue
    fi

    # Perform the username change (dry run)
    if $dry_run_mode; then
        echo "Dry run: Changing username from $user to $new_name."
    else
        change_username "$user" "$new_name"
    fi

    # Check if the new user exists in /etc/passwd
    if ! id "$new_name" &>/dev/null; then
        echo "User $new_name does not exist. Creating user..."
        adduser --home "/home/$new_name" --gecos "" --disabled-password "$new_name"
        usermod -aG sudo "$new_name"
    fi

    # Ensure SSH configuration
    mkdir -p "/home/$new_name/.ssh"
    chmod 700 "/home/$new_name/.ssh"
    touch "/home/$new_name/.ssh/authorized_keys"
    chmod 600 "/home/$new_name/.ssh/authorized_keys"
    chown "$new_name:$new_name" "/home/$new_name/.ssh" "/home/$new_name/.ssh/authorized_keys"

    copy_public_key "$new_name"
done

#####################################
# Clean up /etc/passwd invalid data #
#####################################
cleanup_passwd_entry

###########################
# Prompt to delete a user #
###########################
read -p "Do you want to delete a user? (y/n): " delete_choice

if [[ "$delete_choice" == "y" || "$delete_choice" == "Y" ]]; then
    while true; do
        read -p "Enter the username to delete: " user_to_delete

        # If no username, break the loop
        if [[ -z "$user_to_delete" ]]; then
            break
        fi

        if [[ $user_to_delete == "$current_user" ]]; then
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

