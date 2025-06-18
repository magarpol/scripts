# Scripts

## Description
This repository contains scripts for daily/weekly work.

## Data directory
This directory contains files that are necessary for scripts execution i.e. some CheckMK services configuration

## Scripts Descriptions

### Ad migration
This script takes info from a .cv file and updates AD.

### Add NIS account
This script add a NIS account.

### Ansible user Cloud config
This script creates ansible user in IONOX DCD and configures the network.

### APT Updates
This script configures APT updates service in CheckMK

### Check FTP certificates
This script checks out the ftp certificates for CheckMK

### Check Login
This script check logins on a number of websites.

### Check Wildcard Certificates
This script looks for expiration date on wildcard certificates and creates a service in CheckMK to monitor them.

### Check xz utils version
This script check if xz-utils is installed, if it´s vulnerable and if an update is available.

### CheckMK Services
This script configures services after installing CheckMK agent on Servers. 

### Delete NIS account
This script deletes a NIS account.

### Delete username folder
This script deletes the username folder and /etc/group and /etc/passwd info.

### Distro upgrade
This script adds service in CheckMK to monitor if a distribution upgrade is available.

### Docker Service
This script configures Docker files for the CheckMK Agent Service.

### Kernel headers check
This script install the missing kernel headers

### Mount Crypt
This script encrypt LVM and mount Docker.

### NFS Shares
This script mounts NFS shares after asking prompt on where to mount them.

### Reboot
This script configures the Reboot service in CheckMK.

### Self Signed Certificates
This script generates self signed certificates.

### snapAPI error
This script solves the snapAPI Acronis error.

### SSH Key Generator
This script creates a 4096 Key Pair in Windows Systems.

### Update Docker GPG key
This script creates directories for keyrings, moves the Docker GPG key to secure location and updates the repository file.

### Username Change
This script takes info from /root folder, creates the new users and move the Public Keys to the right location. After that it deletes the old info from users.

### Users and SSH
This script creates users, stores the Public Key in the right location and changes sudoers and sshd configuration.

### Users and SSH email
This script creates users and Public Keys, configures the	sshd configuration and send an email to users with OTP password

### Welcome Script
This script configures a welcome message with Server info.
This is a list of steps to implement the configuration

### Users and SSH RHEL
This script creates users, stores the Public Key in the right location and changes sudoers and sshd configuration in RHEL Servers.



