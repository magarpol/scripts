#!/bin/bash

#Configure the Docker Service on host
apt install python3-docker
cd /tmp/
cp mk_docker.py /usr/lib/check_mk_agent/plugins/
cp docker.cfg /usr/lib/check_mk_agent/plugins/
chmod 0755 /usr/lib/check_mk_agent/plugins/mk_docker.py
cd /usr/lib/check_mk_agent/plugins/
/usr/bin/python3 mk_docker.py
