#!/bin/bash

LOAD=`awk '{ print $1 }' /proc/loadavg`
curl -XPOST https://opentsdb-gra1.tsaas.ovh.com/api/put \
     -u "<metrics-user-write>:<metrics-pass-write>" \
     -H "Content-Type: application/json" \
     -d '{ 
            "metric":"loadavg", 
            "timestamp":'$(date +%s)', 
            "value":'$LOAD', 
            "tags":{
                        "server":"'$(hostname)'"
                   }
         }'
