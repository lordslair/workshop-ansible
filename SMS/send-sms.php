<?php
/**
 * # Instantiate. Visit https://api.ovh.com/createToken/index.cgi?GET=/sms&GET=/sms/*&PUT=/sms/*&DELETE=/sms/*&POST=/sms/*
 * to get your credentials
 */
require __DIR__ . '/vendor/autoload.php';
use \Ovh\Sms\SmsApi;

$applicationKey = '';
$applicationSecret = '';
$endpoint = 'ovh-eu';
$consumer_key = '';

$Sms = new SmsApi( $applicationKey, $applicationSecret, $endpoint, $consumer_key);

$accounts = $Sms->getAccounts();
$Sms->setAccount($accounts[0]);
$senders = $Sms->getSenders();

$Message = $Sms->createMessage();
$Message->setSender($senders[0]);
$Message->addReceiver("");
$Message->setIsMarketing(false);

$Message->send("Heavy workload detected, spawning instances");

?>
