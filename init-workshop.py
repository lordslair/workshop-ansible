#!/usr/bin/env python

import sys
import re
import os
import commands
import base64

sys.path.insert(0, '/root/workshop-ansible/OpenStack/')
from credentials import get_nova_credentials_v2

from novaclient.client import Client

credentials = get_nova_credentials_v2()
nova_client = Client(**credentials)
servers     = nova_client.servers.list()
image       = nova_client.images.find(name="Debian 8")
flavor      = nova_client.flavors.find(name="vps-ssd-1")
data        = open("/root/workshop-ansible/OpenStack/post-install.yaml","r")

todos = [ 'ansible-server-01', 'ansible-server-02' ]

for todo in todos:
    grep = any(server.name == todo for server in servers)
    
    if grep == True:
        print (todo + " already exists")
    else:
        nova_client.servers.create(name     = todo, 
                                   image    = image.id, 
                                   flavor   = flavor.id,
                                   userdata = data)
        print (todo + " is being spawned")
