#!/bin/bash

#Change keyboard layout to DE
touch /etc/default/keyboard
sed -i 's/XKBLAYOUT=".*"/XKBLAYOUT="de"/' /etc/default/keyboard || echo 'XKBLAUYOUT="de"' >> /etc/default/keyboard
setupcon

#Change timezone to Europe/Berlin
timedatectl set-timezone Europe/Berlin

#Define the usernames
usernames=("")
publickeys=(
        ""

)
passwords=("")

#Loop through every user for creation and configuration
for i in "${!usernames[@]}"; do

        username="${usernames[$i]}"
        publicKey="${publickeys[$i]}"
        password="${passwords[$i]}"

        #Check OS and set useradd/adduser command
        if [ -f /etc/os-release ]; then
                . /etc/os-release
                if [[ "$ID" == "opensuse" || "$ID_LIKE" == "suse" ]]; then
                        useradd -m "$username" || { echo "Failed to create user $username"; continue; }
                else
                        adduser --gecos "" --disabled-password "$username" || { echo "Failed to create user $username"; continue; }
                fi
        else
                echo "/etc/os-release not found, cannot determine OS type"
                continue
        fi

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

        echo "$username has been created and configured."

done

#Comment 'PermitRootLogin yes' in sshd_config
sed -i 's/^PermitRootLogin yes/#PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl restart ssh 

#Edit the sudoers file, members of sudo group can use sudo without password
sed -i 's/^sudo.*ALL=(ALL:ALL) ALL/#&/' /etc/sudoers
echo "%sudo ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
                                                            
#Check OS and set updates
if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "opensuse" // "$ID_LIKE" == "suse" ]]; then
                zypper refresh
                zypper update
        else
                apt-get update
                apt-get upgrade -y
        fi
else
        echo "/etc/os-release not found, cannot determine OS type"
        exit 1
fi

#Configure common-password with our password policy 
cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
cat <<EOL > /etc/pam.d/common-password
password    requisite           pam_pwquality.so retry=3 enforce_for_root
password    [success=1 default=ignore]      pam_unix.so obscure use_authok remember=3 maxlen=20
password    requisite           pam_deny.so
password    required            pam_permit.so
password    optional            pam_gnome_keyring.so
EOL

#Set up password complexity requirements in /etc/security/pwquality.conf
cat <<EOL > /etc/security/pwquality.conf
minlen = 8
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOL

#Configure password age
cat <<EOL > /etc/login.defs
PASS_MAX_DAYS 90
PASS_MIN_DAYS 30
PASS_WARN_AGE 7
EOL

#Account lockout settings
cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bak
cat <<EOL > /etc/pam.d/common-auth
auth    required    pam_tally2.so deny=5 unlock_time=900 onerr=fail audit
auth    [success=1 default=ignore]      pam_unix.so nullok_secure
auth    requisite           pam_deny.so
auth    required            pam_permit.so
auth    optional            pam_cap.so
EOL

#Reboot the system
reboot -h now
