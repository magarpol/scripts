#!/bin/bash

# Define usernames, public keys, and passwords
usernames=("t1-mogarcia" "t1-snbrunne" "t1-tsschmid")
publickeys=("ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQLSWgCXcV+Xh8mj8qBJghKLM7eyOFrZqxLzAGaub3VcOVq99kK/FOwsyn0mTzZM0rjDSvLxbclQEGH5GvRNsdWw4G05VGyes6Hc+k7JofejMFn2WO3+scVtxvRFgDUbCuTkzD27N/qB3fzn7bGugHik9nb2jHb6kLbUc4Dv+ONhAYDFwA0fUvgy1LHgYJT1HaDapCO5Js09q6cp59BgCSEXOrm84NQ7xHHve+ppUC26RZs+b6dvSTXOAtzBRWHV9AtnAFYSF1JTb6YAWahSOGFV1nAapFXtl6zjZGjQDf+8CdShhaRqq42M0c4ukzOJe3Dkq0A1EZvn4OnHsyHMLp63TPodRAEuNfuMv39Oz1qk2Sg39Il4iXUE8lTQ73Af0gNg8JBKu138S/qrE8vwG2f9s8cLetwRd2aAMpjnA/TjU6Sig2T0lfu7Q6oQiisfOiAt4ONhRx7bAKOoiT/WeQ6oD5DwC8qcHiEqiiMiLHs+sbyAwomvRlCC6FPR/tJnp2eWW/rmc+tM+kHgm/axKLyaB1++LLzYyS34BtEQyO7ocTPYIJiAzs7CNQCZP00OOkdqX6g0f+GPhW+nF6LKjtMYP7V2FERjWWWlLoRdRgduO95XeHmDPEm77N/1Vb1aEZ2p1XJmZ6x0IhKP9UQyh65xEuwsekQOvWpaylz7PVjw== m.garcia@mid.de"
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCJuWQPArgDXMFm8f1ZY2JkFnmEfkDCIZcqpdXXkQdb+p/cy0KBR4GZOws421VWtjpkxXLaGZzJK8sMBoAvnnywyaI+o3DuyTAdw89nE/a59naV2KLVOn8ldAZ1hrGmkSrozq2yrgmPrvaHxdcBGUrUV6w8iIvn8ClaRQOyGf6GWUx/9pJJbSaoMcbUvfu2iunAzYkpzbeUq8yKgKwyF1r+oPtvp3CrXSsQwhNJe29D9tTbBikYu0oVz8FBRj0oKg9qG/WmcvpFYV1bgbalb6cOjtbeRsIlfVysdKiDqZk4ZHSKli5hso0fYW7W7ETxuiZsT5RUWtyLJRq7jK+zXZQ5dsQ/LhRp9eGjCDfLW5esfcNcadMlreDWU9GqBjOhLBQfqkgSnUfeLwjFZ6zdTY4K+u9f0SgKS1rd9bX1cl3P48XGxbXY77T//ipAqMu3Hq447+VnvHYDbg6k1oJHufPxTmet5/brAI5206yAD5fNgOYjugT8KFToVKheVz4uIzwP8o1P9CnS61vP6HA8l8ZIOQ0+Fy4BovR3wpnjPYh8LpAv9ciBtoBJfQHT5LFCKP9rDRlAFN5Okbxc9MOkHZBp4nlIEq2zk3JnoaA5nT73horpcqDfCfw6dUnJyQPoWYC9vHhn3NpTkbmz9noB/g9g+AbTX54Zi3YpNsMXEOmOGQ==  s.brunner@mid.de"
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBNHZ0oAnyPxlERewCUGBmNbFIpe6/fWhWmaUl6Jw2qNiDv4eavNT2xCj/QuJ5kQIfneK0DPKVH/rV6N80GMknw3DOAtVWUSnPQvuPG6gSRFja7Wv7L70ORxmJ0I69+T6szyLvbrEA1+qOpPsDOZPHwjAUtyL4lFhLXPw5W16JhK0idieWO0edjX2NIbU8zfy8ODDZ3AudihoGBwEOI+voDFICldNkl2YkmtnHKGLJQSL1Nzr4SQ33r0PRIpWXo6sKfj2F0gv8tKycBKQ8ux9cAdnfBcETD3V2RkrFvMG0JLIO/bHGL1aeuemtYAqaFqq1xc55H30mz/xYgbyerhW9 roto - t.schmidt@mid.de"
)
passwords=("Bh7qfYCspkLTKxrjr3JB" "S4lkKnxiSfXKTXojzAFd" "tfUZSq23TBp53dwcsL37")

for i in "${!usernames[@]}"; do

    username="${usernames[$i]}"
    publicKey="${publickeys[$i]}"
    password="${passwords[$i]}"

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
        continue
    fi

    # Create user and check for success
    useradd -m "$username" || { echo "Failed to create user $username"; continue; }

    # Set password for the user
    echo "$username:$password" | chpasswd

    # Force the user to change the password at first login
    chage -d 0 "$username"

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
