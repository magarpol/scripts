#!/bin/bash

##########################################################
# Optimized Script for Installing Acronis SnapAPI Module #
##########################################################

cd /usr/lib/Acronis/kernel_modules/

# Extract the snapapi archive
tar xvfz snapapi26-0.8.31-all.tar.gz

mkdir -p "/usr/lib/Acronis/kernel_modules/snapapi26-0.8.42" 

# Move DKMS source files to the version specific directory
mv /usr/lib/Acronis/kernel_modules/dkms_source_tree/* "usr/src/snapapi26-0.8.42/" 

# Update dkms.conf to comment out REMAKE_INITRD
sed 's/REMAKE_INITRD/#REMAKE_INITRD/' -i "/usr/src/snapapi26-0.8.42/dkms.conf" 

# Install the required headers package
apt update
apt install -y linux-headers-$(uname -r) 

# Build and install the DKMS module
dkms build -m snapapi26 -v 0.8.42 --config /boot/config-$(uname -r) --arch $(uname -p)

# Load the module and restart the Acronis service
modprobe snapapi26 
systemctl restart acronis_mms 

# Add a kernel post installation script to install headers
cat << 'EOF' > /etc/kernel/postinst.d/install-headers
#!/bin/bash
apt-get install -y linux-headers-$(uname -r)
EOF
chmod 755 /etc/kernel/postinst.d/install-headers 

echo "Script completed successfully."