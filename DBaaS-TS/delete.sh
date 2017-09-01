curl -XPOST https://opentsdb-gra1.tsaas.ovh.com/api/query \
     -u "<metrics-user-write>:<metrics-pass-write>" \
     -H "Content-Type: application/json" \
     -d '{ 
            "start":0,
            "aggregator":"none",
            "queries": [
                {
                    "metric":"loadavg", 
                }
            
            ] }'
