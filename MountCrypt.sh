#!/bin/bash
 
echo
echo "#"
echo "# /home/deployment"
echo "#"
echo
cryptsetup luksOpen /dev/mapper/vg1-homedeployment homedeployment-crypt && \
mount /dev/mapper/homedeployment-crypt /home/deployment
 
echo
echo "#"
echo "# /home/deployment/backup"
echo "#"
echo
cryptsetup luksOpen /dev/mapper/vg1-homedeploymentbackup backup-crypt && \
mount /dev/mapper/backup-crypt /home/deployment/backup
 
echo
echo "#"
echo "# /var/lib/docker"
echo "#"
echo
cryptsetup luksOpen /dev/mapper/vg1-varlibdocker varlibdocker-crypt && \
mount /dev/mapper/varlibdocker-crypt /var/lib/docker
 
echo -n "Starting docker daemon ... "
systemctl start docker && echo "done"