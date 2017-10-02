#!/usr/bin/env python

import sys
import re
import os
import commands
import base64

sys.path.insert(0, '/root/workshop-ansible/OpenStack/')
from credentials import get_nova_credentials_v2

sys.path.insert(0, '/root/workshop-ansible/SMS/')
from sms import send_sms

from termcolor import colored # python-termcolor
from novaclient.client import Client
from pprint import pprint

credentials = get_nova_credentials_v2()
nova_client = Client(**credentials)
servers     = nova_client.servers.list()
image       = nova_client.images.find(name="Debian 8")
flavor      = nova_client.flavors.find(name="vps-ssd-1")
data        = open("/root/workshop-ansible/OpenStack/post-install.yaml","r")

for server in servers:
    match = re.search(r"(\w*?-\d[1-9])", server.name)
    if match:
        rawload     = commands.getstatusoutput("/root/workshop-ansible/DBaaS-TS/get-load-dbaas-ts.sh " + server.name + " | awk '{ print $2 }'")
        server_cyan = colored(server.name, 'cyan' , attrs=['bold'])

        if rawload[1]:
            load        = float(rawload[1])
            load_red    = colored('{0:.2f}'.format(load), 'red'  , attrs=['bold'])
            load_green  = colored('{0:.2f}'.format(load), 'green', attrs=['bold'])
            fresh       = server.name + '-fresh'
            grep        = any(server.name == fresh for server in servers) 

            if load >= 0.75:
                if grep == False:
                    if re.search(r"fresh", server.name):
                        print("Host %-36s on fire (%s)  [but already 2nd gen, not spawn-looping]"% (server_cyan, load_red))
                    else:
                        print("Host %-36s on fire (%s)  [spawning a fresh new instance]"% (server_cyan, load_red))
                        server = nova_client.servers.create(name = server.name + '-fresh', 
                                                            image = image.id, 
                                                            flavor = flavor.id,
                                                            userdata = data)
                        sms = send_sms('Workload too high. Spawning new instance ' + fresh)
                else:
                    print("Host %-36s on fire (%s)  [but a clone was already spawned]"% (server_cyan, load_red))
            else:
                if grep == False:
                    print("Host %-36s is fine (%s)"% (server_cyan, load_green))
                else:
                    print("Host %-36s is fine (%s)  [so %s will be destroyed]"% (server_cyan, load_green, server.name + '-fresh'))
                    server = nova_client.servers.find(name=fresh)
                    nova_client.servers.delete(server.id)
                    sms = send_sms('Workload back to normal. Deleting ' + fresh)

        else:
            print("Host %-36s not in DBaaS-TS [be patient, or do something!]"% (server_cyan))
