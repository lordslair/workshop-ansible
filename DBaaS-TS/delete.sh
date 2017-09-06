CREDENTIALS=`cat /root/workshop-ansible/credentials.write`

curl -XPOST https://opentsdb-gra1.tsaas.ovh.com/api/query \
     -u "$CREDENTIALS" \
     -H "Content-Type: application/json" \
     -d '{ 
            "start":0,
            "aggregator":"none",
            "queries": [
                {
                    "metric":"loadavg", 
                }
            
            ] }'
