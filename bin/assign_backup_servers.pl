#!/usr/bin/perl

# assigns admins keys to servers

use strict;
use warnings;

my @admins = ('Me','NotMe','TheOtherGuy');
my $out = '';
my @server_list = ();
open('IN','/backup/conf/all-servers') or die;
while (<IN>) {
	next if $_ =~ m/^#/;
	push @server_list, "$_";
}
close IN;
fisher_yates_shuffle(\@server_list);
my $i = 0;
my $x = 0;
my $num_admins = scalar(@admins);
my $server_name = '';
my %h = ();

for ($x=0; $x<scalar(@server_list); $x++) {
        $i = ($x+1) % $num_admins;
        $server_name = $server_list[$x];
        chomp $server_name;
        $h{$admins[$i]} .= "$server_name,";
}

for my $admin ( keys %h ) {

        my $servers = $h{$admin};
        my @server_list = split /\,/,$servers;
        print "$admin:\n";
        for ( @server_list ) {
                print "\t$_\n";
        }
}
sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}


exit 0;

