#!/usr/bin/perl

use strict;
use warnings;

use Term::ANSIColor;
use Data::Dumper;

use lib '/root/workshop-ansible/OpenStack/lib/';
use OpenStack::Client::Auth ();

my $auth = OpenStack::Client::Auth->new($ENV{'OS_AUTH_URL'},
    'tenant'   => $ENV{'OS_TENANT_NAME'},
    'username' => $ENV{'OS_USERNAME'},
    'password' => $ENV{'OS_PASSWORD'}
);

my $nova = $auth->service('compute');

my @servers;
$nova->each("/servers", sub {
    my ($result) = @_;

    foreach my $server (@{$result->{'servers'}})
    {
        if ( $server->{'name'} !~ /00$/ )
        {
            push @servers, $server->{'name'};
        }
    }
});

foreach my $server (@servers)
{   
    my $rawload      = `/root/workshop-ansible/DBaaS-TS/get-load-dbaas-ts.sh $server | awk '{ print \$2 }'`;
    my $server_cyan  = colored($server, 'bold cyan');

    if ( $rawload !~ /^\s*$/ )
    {
        my $load = sprintf("%.2f",$rawload);
        chomp ($load);

        my $load_red   = colored($load, 'bold red');
        my $load_green = colored($load, 'bold green');

        my $running;
        if (grep /$server-fresh/, @servers) { $running = 1 } else { $running = 0 }
        
        if ( $load >= 0.75 )
        {   
            if ( $running == 0 )
            {   
                if ( $server =~ /fresh/ ) 
                {
                    printf("Host %-25s on fire (%s)  [but already 2nd gen, not spawn-looping]\n", $server_cyan, $load_red);
                }
                else
                {
                    printf("Host %-25s on fire (%s)  [spawning a fresh new instance]\n", $server_cyan, $load_red);
                    `source ~/workshop-ansible/OpenStack/openrc.sh && nova boot --flavor vps-ssd-1 --image 'Debian 8' --user-data ~/workshop-ansible/OpenStack/post-install.yaml $server-fresh 2>&1`;
                }
            }
            else
            {   
                printf("Host %-25s on fire (%s)  [but a clone was already spawned]\n", $server_cyan, $load_red);
            }
        }
        else 
        {   
            if ( $running == 0 )
            {   
                printf("Host %-25s is fine (%s)\n", $server_cyan, $load_green);
            }
            else
            {   
                printf("Host %-25s is fine (%s)  [so %s will be destroyed]\n", $server_cyan, $load_green, "$server-fresh");
                `source ~/workshop-ansible/OpenStack/openrc.sh && nova delete '$server-fresh' 2>&1`;
            }
        }
    } else { printf("Host %-25s not in DBaaS-TS [be patient, or do something!]\n", $server_cyan) }
}
