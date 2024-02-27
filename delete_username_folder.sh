#!/bin/bash

#Prompt the username
read -p "Enter the folder to delete: " username

#Check if the username folder exists in /path/
if [ -d "/path/$username" ]; then
	#Confirm before deleting
	read -p "The folder /path/$username exists. Do you want to delete it? (y/n):" confirm
	if [ "$confirm" = "y" ]; then
		#Delete the folder and its contents
		rm -rf "/path/$username"
		echo "The folder /path/$username and its contents have been deleted."
	else
		echo "Folder deletion canceled"
	fi
else
	echo "The folder /path/$username does not exist."
fi
