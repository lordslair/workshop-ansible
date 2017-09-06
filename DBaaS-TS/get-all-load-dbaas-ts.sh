#!/bin/bash

CREDENTIALS=`cat /root/workshop-ansible/credentials.read`

curl -s -XPOST https://opentsdb-gra1.tsaas.ovh.com/api/query/last \
     -u "$CREDENTIALS" \
     -H "Content-Type: application/json" \
     -d '{ 
            "queries": [{"metric":"loadavg"}] 
         }'| \
python -mjson.tool | \
perl -lne 'print $1 if /(server[-]?\d\d)/; print $1 if /(\d[.]\d*)/' | \
tr '\n' ' '
