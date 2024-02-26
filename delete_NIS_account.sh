#!/bin/bash

#Prompt the user for the username to delete
read -p "Enter the username to delete: " username 

#Check if the username exists in /etc/passwd and /etc/shadow
if grep -q "$username:" /etc/passwd && grep -q "$username:" /etc/shadow; then

	#Create a backup of the original /etc/passwd and /etc/shadow files with the current date
	cp /etc/passwd "/etc/passwd.$(date +"%Y-%m-%d").bak"
	cp /etc/shadow "/etc/shadow.$(date +"%Y-%m-%d").bak"

	#Delete the name that contains the username
	sed -i "/$username:/d" /etc/passwd
	sed -i "/$username:/d" /etc/shadow

	echo "Username '$username' has been deleted from /etc/passwd."
	echo "Username '$username' has been deleted from /etc/shadow."

else
	echo "User '$username' not found in /etc/password and /etc/shadow."
fi
