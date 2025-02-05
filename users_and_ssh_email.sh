

# ============================================================================
# Script Name:    users_and_ssh_email.sh
# Author:         Mauro García
# Version:        2.0
# Description:    This script creates users and Public Keys, configures the	
#                 sshd configuration and send an email to users with OTP password
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-30
# ============================================================================

usernames=("")
publickeys=(
    ""
)
emails=("email@com.com")

#Loop through every user for creation and configuration

for i in "${!usernames[@]}"; do

        username="${usernames[$i]}"
        publicKey="${publickeys[$i]}"
        email="${emails[$i]}"

        #Generate ramdom password
        password=$(openssl rand -base64 12)

        #Add user
        useradd -m "$username" || { echo "Failed to create user $username"; continue; }

        #Set password for user
        echo "$username:$password" | chpasswd

        #Force user to change password at first login
        chage -d 0 "$username"

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

        # Prepare email
        subject="$hostname Access Credentials"
        body="Hallo,\n\nDein Konto-Passwort wurde aktualisiert. Nachstehend findest du deine neuen Anmeldedaten:\n\nUsername: $username\nPassword: $password\n\nPlease change your password after your first login.\n\nBest regards,\nSystem Admins"

        # Send email
        {
                echo "Subject: $subject"
                echo "To: $emails"
                echo "Content-Type: text/plain; charset=UTF-8"
                echo ""
                echo -e "$body"
        } | exim -v

done

systemctl restart sshd
systemctl restart ssh 
