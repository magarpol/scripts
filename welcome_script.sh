#!/bin/bash

# ============================================================================
# Script Name:    welcome_script.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script configures a welcome message with Server info.
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-03-19
# ============================================================================

# This is not a script, but a list of steps to implement this configuration

nano /usr/local/bin/server-info

# text to ASCII generator: https://patorjk.com/software/taag/#p=display&f=Graffiti&t=

#!/bin/bash

# ASCII Art
echo "Servername in ASCII (TESTLAB):"
echo ""
echo "______________________ ____________________.____       _____ __________ "
echo "\__    ___/\_   _____//   _____/\__    ___/|    |     /  _  \\\\______   \\"
echo "  |    |    |    __)_ \\_____  \\   |    |   |    |    /  /_\\  \\|    |  _/"
echo "  |    |    |        \\/        \\  |    |   |    |___/    |    \\    |   \\"
echo "  |____|   /_______  /_______  /  |____|   |_______ \\____|__  /______  /"
echo "                   \\/        \\/                    \\/       \\/       \\/"
echo ""

# System Information
echo "Server config listed:"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Partitions:"
df -h | grep -v tmpfs
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo ""

# Docker Containers
echo "Docker Containers:"
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

# Make the script executable
chmod +x /usr/local/bin/server-info

# Add sctript to login profile
nano /etc/profile

# Add the following line at the end of the file
/usr/local/bin/server-info
