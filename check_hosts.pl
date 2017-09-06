#!/usr/bin/perl

use strict;
use warnings;

use Term::ANSIColor;
use Data::Dumper;

my $servers = `source ~/workshop-ansible/OpenStack/openrc.sh && nova list 2>&1 | grep -Ev "server00|server-00" | awk '{ print \$4 }' | grep server | tr '\n' ' '`;
my @servers = split / /, $servers;

foreach my $server (@servers)
{   
    my $rawload = `/root/DBaaS-TS/get-load-dbaas-ts.sh $server | awk '{ print \$2 }'`;

    if ( $rawload !~ /^\s*$/ )
    {
        my $load = sprintf("%.2f",$rawload);
        chomp ($load);
        
        my $running;
        if (grep /$server-fresh/, @servers) { $running = 1 } else { $running = 0 }

        if ( $load >= 0.75 )
        {   
            if ( $running == 0 )
            {   
                if ( $server =~ /fresh/ ) 
                {
                    printf("Host %-25s on fire (%s)  [but already 2nd gen, not spawn-looping]\n", colored($server, 'bold cyan'), colored($load, 'bold red'));
                }
                else
                {
                    printf("Host %-25s on fire (%s)  [spawning a fresh new instance]\n", colored($server, 'bold cyan'), colored($load, 'bold red'));
                    `source ~/workshop-ansible/OpenStack/openrc.sh && nova boot --flavor vps-ssd-1 --image 'Debian 8' --user-data ~/workshop-ansible/OpenStack/post-install.yaml $server-fresh 2>&1`;
                }
            }
            else
            {   
                printf("Host %-25s on fire (%s)  [but a clone was already spawned]\n", colored($server, 'bold cyan'), colored($load, 'bold red'));
            }
        }
        else 
        {   
            if ( $running == 0 )
            {   
                printf("Host %-25s is fine (%s)\n", colored($server, 'bold cyan'), colored($load, 'bold green'));
            }
            else
            {   
                printf("Host %-25s is fine (%s)  [so %s will be destroyed]\n", colored($server, 'bold cyan'), colored($load, 'bold green'), "$server-fresh");
                `source ~/workshop-ansible/OpenStack/openrc.sh && nova delete '$server-fresh' 2>&1`;
            }
        }
    } else { printf("Host %-25s not in DBaaS-TS [be patient, or do something!]\n", colored($server, 'bold cyan')) }
}
