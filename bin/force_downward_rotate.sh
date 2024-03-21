#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "BE CAREFUL - and specify a maximum snapshot number"
	exit 1
else
	echo "BE CAREFUL"
#	for (( i=1 ; i <= $1 ; ++i ))
#	do
#		[ -d rsync.$i ] && mv -v rsync.$i rsync.$(( $i - 1 ))
#	done
fi
