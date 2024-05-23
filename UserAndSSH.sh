#!/bin/bash

#Prompt the username
read -p "Enter the username: " username

#Check OS and use 'useradd' or 'adduser'
if [ -f /etc/os-release ]; then
	. /etc/os-release
	if [[ "$ID" == "opensuse" || "$ID_LIKE" == "suse" ]]; then
		useradd -m $username
	else
		adduser $username
	fi
fi 

#Add user to sudo group
usermod -aG sudo $username

#Create directories and set permissions
mkdir /home/$username
mkdir /home/$username/.ssh 
touch /home/$username/.ssh/authorized_keys
chmod 700 /home/$username/.ssh
chmod 600 /home/$username/.ssh/authorized_keys
chown $username:sudo /home/$username/.ssh
chown $username:sudo /home/$username/.ssh/authorized_keys

#Read Public Key and paste it in authorized_keys
read -p "Please paste the user´s Public Key: " publicKey
echo $plublicKey | sudo tee -a /home/$username/.ssh/authorized_keys

echo "$username has been created."