# ============================================================================
# Script Name:    dockers_snapshots_cleaning.sh.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script cleans docker snapshots daily
# Repository:     https://github.com/magarpol/scripts
# Last Updated:   2025-01-16
# ============================================================================

# cronjob
# 0 5 * * * /root/cleanup_docker.sh 2&> /dev/null
 
# path /root/cleanup_docker.sh
#! /bin/bash
df -m /
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker system prune -f
docker image prune -a -f
docker volume prune -f
df -m /
