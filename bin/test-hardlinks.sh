#!/bin/bash

for server in `grep -v ^# /backup/conf/all-servers | cut -d\. -f1 | egrep -v \(exclude_hostname1\|exclude_hostname2\|exclude_hostname3\|exclude_hostname4\)`
do 
	LNKNUM=`stat -c %h /backup/rsync/${server}/rsync.0/etc/host.conf`
	DIRNUM=`ls -1 /backup/rsync/${server}/ | grep -v 'rsync\.work' | wc -l`
	[ "$1" == "-v" ] && echo "$server:$LNKNUM-of-$DIRNUM"
	[ ! -z $LNKNUM ] && [ ! -z $DIRNUM ] && [ $LNKNUM -ge $DIRNUM ] || broken_link=( $server:$LNKNUM-of-$DIRNUM $broken_link )
done
echo ${broken_link[*]}
