#!/bin/bash

#Define URLs
url=$1
username="checkhttp"
password="checkhttp"

#Temporary file to store cookies
cookie_file=$(mktemp)

#Function to check login
check_login() {
    url=$1

    #Step 1: Get the login page
    curl -s -c $cookie_file $url > /dev/null

    #Step 2: Submit login credentials
    response=$(curl -s -b "$cookie_file" -c "$cookie_file" -X POST "$url" \ 
    -d "username=$unsername" -d "password=$password" -w "%{http_code}" -o /dev/null) 

    #Check if login was successful
    if [ "$response" -eq 200 ]; then
        echo "Login successful for $url"
        rm -f "$cookie_file"
        return 0
    else
        echo "Login failed for $url"
        rm -f "$cookie_file"
        return 1
    fi
}

#Run script and assign to CheckMK
if check_login "$url"; then
    exit 0
else
    exit 2
fi