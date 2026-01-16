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
