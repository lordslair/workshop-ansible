#!/bin/bash

source ~/workshop-ansible/OpenStack/openrc.sh

IPS=`nova list 2>&1 | \
     grep -Ev "server0|server-00" | \
     cut -d= -f2 | \
     grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`

echo "[web]" > /etc/ansible/hosts
echo "$IPS" >> /etc/ansible/hosts
