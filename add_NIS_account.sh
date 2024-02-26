#!/bin/bash

#Get the last line number in /etc/passwd
last_line=$(tail -n 1 /etc/passwd | cut -d ':' -f 1) 
if [[ -z $last_line ]]; then
	last_line=0
fi

#Increment the last line number by one for the new line
next_line=$((last_line + 1))

#Prompt the user for the username, name, surname and position
read -p "Enter username to add: " username
read -p "Enter name and surname to add: "	namesurname
read -p "Enter position to add: "	position

echo "$username:x:885:10:$namesurname, $position:/users/$username:/bin/bash" >> /etc/passwd
echo "$username:*:14861:0:10000::::" >> /etc/shadow

ypcat -k passwd | grep $username

mkdir -p /mid/server/scratch/$username
chmod 1777 /mid/server/scratch/$username
chown $username /mid/server/scratch/$username