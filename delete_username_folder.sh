#!/bin/bash

#Prompt the username
read -p "Enter the folder to delete: " username

#Check if the username folder exists in /mid/server/scratch/
if [ -d "/mid/server/scratch/$username" ]; then
	#Confirm before deleting
	read -p "The folder /mid/server/scratch/$username exists. Do you want to delete it? (y/n):" confirm
	if [ "$confirm" = "y" ]; then
		#Delete the folder and its contents
		rm -rf "/mid/server/scratch/$username"
		echo "The folder /mid/server/scratch/$username and its contents have been deleted."
	else
		echo "Folder deletion canceled"
	fi
else
	echo "The folder /mid/server/scratch/$username does not exist."
fi
