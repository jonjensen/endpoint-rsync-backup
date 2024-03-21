#!/bin/bash

# track the fingerprints of ssh public keys
# - Kiel Christofferson
# - 10 MAR 2008

BASEDIR="/backup/rsync"
LOGFILE="/var/log/root-access.log"

KEYPATH=/root/.ssh/authorized_keys
NEWAUTH="rsync.0$KEYPATH"
OLDAUTH="rsync.1$KEYPATH"

SERVERLIST=(`find -L $BASEDIR/ -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | egrep -v '(exclude_hostname1|exclude_hostname2|skel)'`)

for SERVER in ${SERVERLIST[@]}; do
	if [ -r ${BASEDIR}/${SERVER}/${OLDAUTH} ] && [ -r ${BASEDIR}/${SERVER}/${NEWAUTH} ]; then
		OLDPRINTS=`mktemp -t ${SERVER}.XXXXXXXXX` || exit 1
		NEWPRINTS=`mktemp -t ${SERVER}.XXXXXXXXX` || exit 1

		# ssh-keygen will only fingerprint one key per input file
		# this loop breaks the keys out and passes them individually
		(
			IFS=$'\n'
			for key in `egrep ^ssh- ${BASEDIR}/${SERVER}/${OLDAUTH} | sort -u`; do
				TMPFILE=`mktemp` || exit 1
				echo -n "$key" >$TMPFILE
				ssh-keygen -l -f $TMPFILE 2>/dev/null
				rm $TMPFILE
			done
		) >>$OLDPRINTS
		(
			IFS=$'\n'
			for key in `egrep ^ssh- ${BASEDIR}/${SERVER}/${NEWAUTH} | sort -u`; do
				TMPFILE=`mktemp` || exit 1
				echo -n "$key" >$TMPFILE
				ssh-keygen -l -f $TMPFILE 2>/dev/null
				rm $TMPFILE
			done
		) >>$NEWPRINTS

		if ! cmp -s $OLDPRINTS $NEWPRINTS; then
			echo "SSH key changes in $SERVER:$KEYPATH at `date --rfc-3339=sec`:"
			diff --unchanged-group-format='' --old-line-format='< %L' --new-line-format='> %L' $OLDPRINTS $NEWPRINTS
			echo
		fi
		rm $OLDPRINTS $NEWPRINTS || exit 1
	elif [ -r ${BASEDIR}/${SERVER}/${NEWAUTH} ] && [ ! -r ${BASEDIR}/${SERVER}/${OLDAUTH} ]; then
		echo "New SSH key file $SERVER:$KEYPATH at `date --rfc-3339=sec`"
	elif [ -r ${BASEIDR}/${SERVER}/${OLDAUTH} ] && [ ! -r ${BASEDIR}/${SERVER}/${NEWAUTH} ]; then
		echo "Deleted or unreadable SSH key file $SERVER:$KEYPATH at `date --rfc-3339=sec`"
	else
		# only tell the log file if there are no keys - NOT email via cron
		echo "No authorized_keys file or unreadable for $SERVER on `date --rfc-3339=sec`" >>$LOGFILE
	fi
done | tee -a $LOGFILE
