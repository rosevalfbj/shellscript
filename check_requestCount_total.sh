#!/bin/bash
APPLICATION=${1}
CONTEXT_APP="/${APPLICATION}/"
PATH_LASTLINE_LOG="/usr/local/nagios/libexec"
FILE_CTRL_LOG="${APPLICATION}_ctrl"

if [ `tail -n 1 ${PATH_LASTLINE_LOG}/${FILE_CTRL_LOG}| wc -l` == '0' ]; then
	echo "Value not found";exit 2
	else REQCOUNT=`tail -n 1 ${PATH_LASTLINE_LOG}/${FILE_CTRL_LOG} | awk -F ';' '{print $5}'| awk -F ':' '{print $2}'`
fi

echo "RequestCountTotal:${REQCOUNT}|RequestCountTotal=${REQCOUNT}"
