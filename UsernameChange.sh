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

# Get the list of all users (exluding system account)
all_users=$(awk -F: '{ if ($3 >= 1000 && $3 != 65534) print $1 }' /etc/passwd)

# Loop through all users
for user in $all_users; do
    echo -n "User $user new name?: "
    read new_name

    # If new name is empty, skip
    if [[ -z $new_name ]]; then
        echo "Skipping user $user."
        continue
    fi

    # Perform the username change
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

        if id "$user_to_delete" &>/dev/null: then
            userdel -r "$user_to_delete"
            echo "User $user_to_delete has been deleted."
        else 
            echo "User $user_to_delete does not exist."
        fi
    done
fi

