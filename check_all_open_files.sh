#!/bin/bash
# 
# Inspired by: http://pissedoffadmins.com/nagios/nagios-tomcat-open-files-check.html
#
# Author: Gregor Binder
# Mail: office@wefixit.at
# https://github.com/wefixit-AT/nagios_check_all_open_files
# Adapted for BGHW by Johannes Starosta <j.starosta@bghw.de>

# Bash strict mode, to make debugging easier see http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
SUDO=$(command -v sudo)
LSOF=$(command -v lsof)
PGREP=$(command -v pgrep)
WC=$(command -v wc)
PROGRAM=""
ERROR_CODE=-1
set +u

if [ -z "$1" ] || [ -z "$2" ] || [ "$2" -lt "$1" ] ; then
    echo "Usage: $0 warning critical program"
    echo "  warning: int"
    echo "  critical: int and >= warning"
    echo " program: Optional String with name of program"
    echo "IMPORTANT: sudo must set without password asking to allow lsof"
    exit $ERROR_CODE
else
    WARNING=$1
    CRITICAL=$2
fi

if [ -n "$3" ];then
    PROGRAM="$3"
fi

set -u

function checkExitStatus {
    if [ "$1" -ne 0 ]; then
        echo "!!! command failure !!! $2"
        exit 1
    fi
}

if [ -z "$PROGRAM" ];then
    LSOF=$("$SUDO" "$LSOF" | "$WC" -l)
else
    list=$("$PGREP" --full "$3")
    summe=0
    for i in $list
    do
        tmp=$("$SUDO" "$LSOF" -p "$i" | "$WC" -l)
        summe=$((summe + tmp))
    done
    LSOF=$summe
fi
if [ "$LSOF" -lt "$WARNING" ]; then
    echo "OK $LSOF files open|files=$LSOF;$WARNING;$CRITICAL;0"
    ERROR_CODE=0
elif [ "$LSOF" -ge "$WARNING" ] && [ "$LSOF" -le "$CRITICAL" ]; then
    echo "WARN $LSOF files open|files=$LSOF;$WARNING;$CRITICAL;0"
    ERROR_CODE=1
elif [ "$LSOF" -ge "$CRITICAL" ]; then
    echo "CRIT $LSOF files open|files=$LSOF;$WARNING;$CRITICAL;0"
    ERROR_CODE=2
fi

exit $ERROR_CODE
