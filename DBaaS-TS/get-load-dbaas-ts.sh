#!/bin/bash

CREDENTIALS=`cat /root/workshop-ansible/credentials.read`

curl -s -XPOST https://opentsdb-gra1.tsaas.ovh.com/api/query/last \
     -u "$CREDENTIALS" \
     -H "Content-Type: application/json" \
     -d '{ 
            "queries": [{"metric":"loadavg", "tags":{"server":"'$1'"}}] 
         }' | perl -lne '$ts = $1 if /(\d{10})/; $la = $1 if /(\d[.]\d*)/; print "$ts $la"'
