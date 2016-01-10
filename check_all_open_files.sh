#!/bin/bash
# 
# Inspired by: http://pissedoffadmins.com/nagios/nagios-tomcat-open-files-check.html
#
# Author: Gregor Binder
# Mail: office@wefixit.at

SUDO=/bin/sudo
LSOF=/sbin/lsof

ERROR_CODE=-1
if [ -z "$1" ] || [ -z "$2" ] || [ $2 -lt $1 ] ; then
    echo "Usage: $0 warning critical"
    echo "  warning: int"
    echo "  critical: int and >= warning"
    echo "IMPORTANT: sudo must set without password asking to allow lsof"
    exit $ERROR_CODE
else
    WARNING=$1
    CRITICAL=$2
fi

function checkExitStatus {
    if [ $1 -ne 0 ]; then
        echo "!!! command failure !!! $2"
        exit -1
    fi
}

LSOF=`$SUDO $LSOF | wc -l`

if [ $LSOF -lt $WARNING ]; then
    printf "OK $LSOF files open\n"
    ERROR_CODE=0
else
    if [ $LSOF -ge $WARNING ] && [ $LSOF -le $CRITICAL ]; then
        printf "WARN $LSOF files open\n"
        ERROR_CODE=1
    elif [ $LSOF -ge $CRITICAL ]; then
        printf "CRIT $LSOF files open\n"
        ERROR_CODE=2
  fi
fi

exit $ERROR_CODE
