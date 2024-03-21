#!/bin/bash

# search across backup sets for ssh keys

BASEDIR="/backup/rsync"
AUTHLIST="rsync.0/home/*/.ssh/authorized_keys"
SERVERLIST=(`ls -1 $BASEDIR`)

for SERVER in ${SERVERLIST[@]}; do
	for AUTH in ${BASEDIR}/$SERVER/${AUTHLIST}; do
#		echo ${AUTH}
		# AUTH is now a full-path item
		if [ -r ${AUTH} ]; then

			(IFS=$'\n'
			for key in `egrep -hv ^# ${AUTH} | egrep -i $1`; do
				# show the file where we found the match
				echo -n $AUTH": "
				TMPFILE=`mktemp` || exit 1
				echo -n "$key" >$TMPFILE
				
				# this output is redirected at end-of-loop
				echo -n "`ssh-keygen -l -f $TMPFILE 2>/dev/null | cut -d\  -f-2`"
				awk '{printf " - " $NF "\n"}' $TMPFILE

				rm $TMPFILE
			done
			)

		fi
	done
done
