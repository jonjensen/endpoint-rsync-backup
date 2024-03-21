#!/usr/bin/perl

# clear out spamassassin bayes databases older than 7 days

use strict;
use warnings;
use File::Glob ':glob';

=pod

=head1 clear_out_old_bayes_databases.pl

Clear out spamassassin bayes databases older than 7 days. 

=head2 Author

Dan Collis-Puro, dan@endpoint.com

=cut

my @servers = qw/ln4 sb5 an2/;

for my $server (@servers) {
	for my $rsync_dir (glob("/backup/rsync/$server/rsync.*/")) {
		$rsync_dir =~ m:\.(\d+)/$: or next;
		my $rsync_count = $1;
		next if $rsync_count < 8;
		my $file = $rsync_dir . 'var/spool/exim4/bayes_text_dump.txt.gz';
		next unless -e $file;
		print "Deleting $file\n";
		unlink $file;
	}
}
