#!/bin/bash

CREDENTIALS=`cat /root/workshop-ansible/DBaaS-TS/credentials.write`
LOAD=`awk '{ print $1 }' /proc/loadavg`

curl -XPOST https://opentsdb-gra1.tsaas.ovh.com/api/put \
     -u "$CREDENTIALS" \
     -H "Content-Type: application/json" \
     -d '{ 
            "metric":"loadavg", 
            "timestamp":'$(date +%s)', 
            "value":'$LOAD', 
            "tags":{
                        "server":"'$(hostname)'"
                   }
         }'
