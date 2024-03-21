#!/usr/bin/perl

# clears out influxdb backups older than 3 days

use strict;
use warnings;
use File::Glob ':glob';
use File::Path 'rmtree';

=pod

=head1 clear_out_old_influxdb_databases.pl

Clear out influxdb backups older than 3 days. 

=head2 Author

Josh Williams, jwilliams@endpointdev.com

=cut

my @servers = qw/hz13/;

for my $server (@servers) {
	for my $rsync_dir (glob("/backup/rsync/$server/rsync.*/")) {
		$rsync_dir =~ m:\.(\d+)/$: or next;
		my $rsync_count = $1;
		next if $rsync_count < 1;
		my $dir = $rsync_dir . 'var/lib/influxdb/backups';
		next unless -e $dir;
		print "Deleting $dir\n";
		rmtree($dir) or die $!;
	}
}
