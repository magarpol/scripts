#!/bin/bash

#Define the usernames
usernames=("user1" "user2" "user3")
publickeys=(
        ""
        ""
        ""
)


#Loop through every user for creation and configuration
for i in "${!usernames[@]}"; do

        username="${usernames[$i]}"
        publicKey="${publickeys[$i]}"

        #Check OS and set useradd/adduser command
        if [ -f /etc/os-release ]; then
                . /etc/os-release
                if [[ "$ID" == "opensuse" || "$ID_LIKE" == "suse" ]]; then
                        useradd -m "$username" || { echo "Failed to create user $username"; continue; }
                else
                         adduser --disabled-password --gecos "" "$username" || { echo "Failed to create user $username"; continue; }
                fi
        else
                echo "/etc/os-release not found, cannot determine OS type"
                continue
        fi

        #Add user to sudo group
        usermod -aG sudo "$username"

        #Create directories and set permissions
        mkdir -p /home/$username
        mkdir -p /home/$username/.ssh
        touch /home/$username/.ssh/authorized_keys
        chmod 700 /home/$username/.ssh
        chmod 600 /home/$username/.ssh/authorized_keys
        chown $username:sudo /home/$username/.ssh
        chown $username:sudo /home/$username/.ssh/authorized_keys

        #Add Public Key to authorized_keys
        echo "$publicKey" >> /home/$username/.ssh/authorized_keys
		
		#Append SSH configuration for the users
		bash -c "cat >> /etc/ssh/sshd_config <<EOF
		
Match User $username
  PubkeyAuthentication yes
  AuthenticationMethods publickey
  
EOF"

        echo "$username has been created and configured."

done

#Open authorized_keys for review/editing
for username in "${usernames[@]}"; do
        nano /home/$username/.ssh/authorized_keys
done
                                                            