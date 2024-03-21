#!/usr/bin/perl


use strict;
use warnings;
use DBI;
use Data::Dumper;
use Shell qw/du/;
use File::Glob ':glob';
use Getopt::Long;

my %opts;
$opts{root} 		= 	'/backup/rsync/lt4/rsync.0/';
$opts{'max-depth'} 	= 	1;
$opts{dbfile}		=	'/backup/reports/sizedb.sqlite';
GetOptions(\%opts, 'root=s','depth=i','dbfile=s');

my $dbh = DBI->connect('dbi:SQLite:dbname='. $opts{dbfile} ,'','',{RaiseError=>1}) or die($DBI::errstr);

check_for_and_initialize_tables($dbh,\%opts);
insert_todays_data($dbh,\%opts);

sub insert_todays_data{
	my ($dbh,$opts) = @_;
	my $create_server = $dbh->prepare('insert or replace into servers(host) values(?)');
	my $insert = $dbh->prepare('insert into directory(host,directory,size,date_added) values(?,?,?,date("now"))');
	my @directories = du('--max-depth='.$opts->{'max-depth'}, $opts->{root});
	for my $dir(@directories){
		chomp $dir;
		my ($host);
		if($dir =~ m/\/backup\/rsync\/([^\/]+)\//){
			$host = $1;
		}
		$create_server->execute($host);
		my @data = split(/\s+/,$dir);
		$data[1] =~ s/$opts->{root}//gis;
		$insert->execute($host,$data[0],$data[1].'/');
	}
	$create_server->finish;
	$insert->finish;
}


sub check_for_and_initialize_tables{
	my $dbh=shift;
	my ($table_count) = $dbh->selectrow_array('select count(*) from sqlite_master where type="table"');
	if(! $table_count){
		for(
		'create table servers (
			host varchar(50) not null primary key
			)',
		q|create table directory (
			id integer not null primary key autoincrement, 
			parent_id integer, 
			host varchar(50) not null,
			directory varchar(100) not null not null default '',
			size integer not null,
			date_added varchar(10) not null 
			)|,
		'create index directory_host on directory(host)',
		'create index directory_directory on directory(directory)',
		'create index directory_date_added on directory(date_added)',
		'create index directory_size on directory(size)'
			){
			$dbh->do($_);
		}
	}
}
