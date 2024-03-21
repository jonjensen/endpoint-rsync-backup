#!/usr/bin/perl

# Delete all but the newest camp backups

use strict;
use warnings;
use File::Path 'rmtree';
use File::Glob ':glob';

# List servers and directory paths for camps to clear

my @globs = qw(
	/backup/rsync/hostname1/rsync.*/home/*/camp*
	/backup/rsync/hostname2/rsync.*/home/*/camp*
);

for my $dir (map { glob($_) } @globs) {
	#print("Skipping non-camp directory: $dir\n"),
	next unless $dir =~ m:/rsync\.(\d+)/.*?/camp\d+$:;
	my $rsync_count = $1;
	#print("Skipping too new directory #$rsync_count: $dir\n"),
	next if $rsync_count < 8;
	#print("Skipping non-directory $dir\n"),
	next unless -d $dir;
	print "Deleting $dir\n";
	rmtree($dir) or die $!;
}
