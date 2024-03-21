#!/bin/bash

# send a status email

server=$1
status=$2 # "success" or "failure"
date_stamp=$(date +"%Y-%m-%d %T")
email_addr=$3
reply_to=$4
hostname=$(hostname -s)

if [ "$hostname" = "<INSERT_SERVER_HOSTNAME_HERE>" ] ; then
	msg="\"$server - backup reported status $status on $date_stamp\""
	body=$msg

	cmd="mail $email_addr -s $msg -r $reply_to <<< '$server - backup reported $status on $date_stamp'"
	eval $cmd
fi

# server
# status
# destination
# message
