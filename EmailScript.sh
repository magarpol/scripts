#!/bin/bash

#Declaring existing users and their email addresses
declare -A user_emails=(
    [username]="emailaddress"
)

#Define hostname
hostname=$(hostname)

#Loop through every user
for username in "${!user_emails[@]}"; do
    email=${user_emails[$username]}
    
    # Generate a random OTP (12 characters alphanumeric)
    password=$(openssl rand -base64 12)
    
    # Set the password for the user
    echo "$username:$password" | chpasswd
    if [ $? -ne 0 ]; then
        echo "Failed to set password for $username."
        continue
    fi

    echo "$username password has been updated."

    # Prepare email
    subject="$hostname Access Credentials"
    body="Hallo,\n\nDein Konto-Passwort wurde aktualisiert. Nachstehend findest du deine neuen Anmeldedaten:\n\nUsername: $username\nPassword: $password\n\nPlease change your password after your first login.\n\nBest regards,\nSystem Admin"

    # Send email
    {
        echo "Subject: $subject"
        echo "To: $email"
        echo "Content-Type: text/plain; charset=UTF-8"
        echo ""
        echo -e "$body"
    } | sendmail -t
done
