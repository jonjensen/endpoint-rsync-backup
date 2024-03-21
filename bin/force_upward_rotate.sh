#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "BE CAREFUL - and specify a maximum snapshot number"
	exit 1
else
	echo "BE CAREFUL"
#	for (( i=$1 ; i >= 0 ; --i ))
#	do
#		[ -d rsync.$i ] && mv -v rsync.$i rsync.$(( $i + 1 ))
#	done
#	mv -v rsync.work rsync.0
fi
