# workshop-ansible

This project is mainly a PoC about using the Openstack API, OVh SMS API, and Ansible.  

# What for ?

Imagine this scenario. 3 initial servers are needed :  

ansible-server-00 : The mothership (admin, monitoring, Ansible, scripts, etc)  
ansible-server-01 : Slave worker  
ansible-server-02 : Slave worker  

When a slave worker has a load > 0.75, the Mothership spawns a new instance, and Ansible configures it.  
Actually, as 1.0, it works this way.  

So on full load on -01 and -02 you end up with 5 instances.  
The mothership and ansible-server-0{1,2,3,4}

### Which script does what ?

```
├── Ansible
│   ├── gethosts.sh                   |    Used in crontab to fill /etc/ansible/hosts
│   ├── iptables-status               |    Pushed by Ansible on targets
│   ├── playbook.yaml                 |    Playbook to apply on /etc/ansible/hosts
│   └── rules.v4                      |    Pushed by Ansible on targets
├── check_hosts.py                    |  Main script
├── DBaaS-TS
│   ├── credentials.read              |    DBaaS-TS credentials
│   ├── credentials.write             |    DBaaS-TS credentials
│   ├── delete.sh                     |    Delete all data in DBaaS-TS
│   ├── get-all-load-dbaas-ts.sh      |  
│   ├── get-load-dbaas-ts.sh          |  
│   └── put-load-dbaas-ts.sh          |  Used in crontab to fill DBaaS-TS
├── init-workshop.py                  |  Deploys the workshop (creates -0{1,2} & test SMS)
├── OpenStack
│   ├── credentials.py                |    Get ENVVAR and pythonize them
│   ├── openrc.sh                     |    OVH Openstack API Credentials
│   └── post-install.yaml             |  
└── SMS
    ├── api.py                        |    OVH SMS API Credentials
    └── sms.py                        |    function to send SMS
```

### Tech

I used mainy :

* Perl - as a lazy animal in v0.1
* Python - as a less lazy animal in v1.0
* OpenStack - ss Public Cloud for the instances
* Ansible - Easy to use CMP
* [The OVH API][APIOVH] - Easy to work with OVH API to send SMS
* [TimeSeries Storage][DBaaS-TS] - To store (timestamp,load) for every server

And of course GitHub to store all these shenanigans. 

### Installation

The script is aimed to run as root. Could work without it, probably.  

```
root@ansible-server-00:~# git clone https://github.com/lordslair/workshop-ansible
root@ansible-server-00:~# cd workshop-ansible
root@ansible-server-00:~/workshop-ansible# source OpenStack/openrc.sh
```

```
root@ansible-server-00:~/workshop-ansible# ./init-workshop.py
ansible-server-01 is being spawned
ansible-server-02 is being spawned
```

```
root@ansible-server-00:~/workshop-ansible# ./check_hosts.py
Host ansible-server-02       is fine (0.02)
Host ansible-server-01       is fine (0.04)
```

#### Disclaimer/Reminder

>There's proably **NULL** interest for anyone to clone it and run the script.   
>I put the code here mostly for reminder, and to help anyone if they find parts of it useful for their own dev.

### Result

```
root@ansible-server-00:~/workshop-ansible# ./check_hosts.py
Host ansible-server-02       is fine (0.03)
Host ansible-server-01       on fire (2.15)  [spawning a fresh new instance]
```

```
root@ansible-server-00:~/workshop-ansible# ./check_hosts.py
Host ansible-server-02       on fire (0.92)  [but a clone was already spawned]
Host ansible-server-01       on fire (2.15)  [but a clone was already spawned]
Host ansible-server-01-fresh is fine (0.02)
Host ansible-server-02-fresh is fine (0.11)
```

SMS received after init, when instances triggered the spawn, and after deletion.  

![iPhone][Screenshot]

### Todos

 - Clean the code
 - Dockerize all of this for portability
 - Different data backend than OVH DBaaS-TS
   
---
   [APIOVH]: <https://api.ovh.com>
   [DBaaS-TS]: <https://www.ovh.com/fr/data-platforms/metrics/>
   
   [Screenshot]: <https://raw.githubusercontent.com/lordslair/workshop-ansible/master/Screenshot.png>
