#!/bin/bash

# Define usernames, public keys, and passwords
usernames=("")
publickeys=(""
)

for i in "${!usernames[@]}"; do

    username="${usernames[$i]}"
    publicKey="${publickeys[$i]}"

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
        continue
    fi

    # Create user and check for success
    useradd -m "$username" || { echo "Failed to create user $username"; continue; }

    # Expire password to force change on first login
    passwd --expire "$username"

    # Add user to the wheel group (for sudo access on RHEL 8)
    usermod -aG wheel "$username"

    # Create .ssh directory, authorized_keys, and set permissions
    mkdir -p /home/$username/.ssh
    touch /home/$username/.ssh/authorized_keys
    chmod 700 /home/$username/.ssh
    chmod 600 /home/$username/.ssh/authorized_keys
    chown $username:$username /home/$username/.ssh
    chown $username:$username /home/$username/.ssh/authorized_keys

    # Add public key to authorized_keys
    echo "$publicKey" >> /home/$username/.ssh/authorized_keys

    # Append SSH configuration for each user
    bash -c "cat >> /etc/ssh/sshd_config <<EOF

Match User $username
  PubkeyAuthentication yes
  AuthenticationMethods publickey

EOF"

    echo "$username has been created and configured."

done

# Disable root login via SSH by commenting 'PermitRootLogin yes'
sed -i 's/^PermitRootLogin yes/#PermitRootLogin yes/' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
systemctl restart sshd

# Edit the sudoers file to allow members of the wheel group to use sudo
sed -i 's/^sudo.*ALL=(ALL:ALL) ALL/#&/' /etc/sudoers
echo "%sudo ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
