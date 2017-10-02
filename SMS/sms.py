#!/usr/bin/python
# -*- encoding: utf-8 -*-

import ovh
import api

def send_sms(text):

    client = ovh.Client('ovh-eu',
                        application_key=api.appkey,
                        application_secret=api.appsec,
                        consumer_key=api.conkey
    )

    res = client.get('/sms')
    url = '/sms/' + res[0] + '/jobs/'

    result_send = client.post(url,
        charset='UTF-8',
        coding='7bit',
        message=text,
        noStopClause=True,
        priority='high',
        receivers= ["+33650905241"],
        senderForResponse=False,
        validityPeriod=2880,
        sender='RemyAtOVH'
    )
    return result_send
