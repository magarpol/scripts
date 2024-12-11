#!/bin/bash

# Function to change username and update home directory
change_username(){
    local old_username=$1
    local new_username=$2

    # Rename user
    usermod -l "$new_username" "$old_username"

    # Rename home directoy
    usermod -d "/home/$new_username" -m "$new_username"

    echo "User $old_username has been renamed to $new_username and home directory updated."
}

# Function to delete old users with data zipping
delete_user(){
    local username=$1
    local admin_home="/tmp"
    local backup_dir"${admin_home}/user_backups"

    mkdir -p "$backup_dir"  # Review backup directory exists

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

# Prevent locking user out
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

current_user=$(whoami)

# Dry run
dry_run_mode=false
if[[ "$1" == "--dry-run" ]]; then
    dry_run_mode=true
    echo "Dry run mode enabled."
fi

# Get the list of all users (exluding system accounts)
all_users=$(awk -F: '{ if ($3 >= 1000 && $3 != 65534) print $1 }' /etc/passwd)

# Loop through all users
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
done

# Output the list of all users
echo "Current list of all users:"
echo "$all_users"

# Prompt to delete a user
read -p "Do you want to delete a user? (y/n): " delete_choice

if [[ "$delete_choice" == "y" || "$delete_choice" == "Y" ]]; then
    while true; do
        echo "Enter the username to delete: " 
        read user_to_delete

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

