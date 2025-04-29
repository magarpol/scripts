#!/bin/bash

#/etc/update-motd.d/99-reboot-required

if [ -f /var/run/reboot-required ]; then
    echo -e "\e[31m"
    echo "****************************************************"
    echo "*                                                  *"
    echo "*  ⚠️  SERVER REBOOT REQUIRED AFTER SECURITY UPDATES  *"
    echo "*                                                  *"
    echo "****************************************************"
    echo -e "\e[0m"
fi
