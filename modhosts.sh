#!/bin/bash
# @(#) A small script to modify the /etc/hosts file in order to enable / disable specific names..

# application metadata
name="modhosts.sh"
version="0.1"
home="https://github.com/seebi/modhosts.sh"

# basic application environment
this=`basename $0`
thisexec=$0
comment="# added by $name"
hostsfile="/etc/hosts"
sudo="sudo"

###
# private functions
###

# adds a given hostname to the table (optional with an ip different from 127.0.0.1)
_addHost ()
{
    hostname=$1
    if [ "$hostname" == "" ]
    then
        echo "_addHost error: need a hostname as first parameter"
        exit 1
    fi

    check=`_checkHost $hostname`
    if [ "$check" != "" ]
    then
        echo "_addHost error: host $hostname is already listed"
        exit 1
    fi

    ip=$2
    if [ "$ip" == "" ]
    then
        ip="127.0.0.1"
    fi

    line="$ip $hostname $comment"
    echo "$line" | $sudo tee -a $hostsfile >/dev/null
}

# removes a given hostname from the hosts table
_removeHost ()
{
    hostname=$1
    if [ "$hostname" == "" ]
    then
        echo "_removeHost error: need a hostname as first parameter"
        exit 1
    fi

    line=" $hostname $comment"
    $sudo sed -i "/$line$/d" $hostsfile
}

_toggleHost ()
{
    hostname=$1
    if [ "$hostname" == "" ]
    then
        echo "_toggleHost error: need a hostname as first parameter"
        exit 1
    fi

    check=`_checkHost $hostname`
    if [ "$check" == "" ]
    then
        echo "_toggleHost error: host $hostname is not listed"
        exit 1
    fi
}

_enableHost ()
{
    hostname=$1
    if [ "$hostname" == "" ]
    then
        echo "_enableHost error: need a hostname as first parameter"
        exit 1
    fi

    ip=`_checkHost $hostname`
    if [ "$ip" != "" ]
    then
        echo "_enableHost error: host $hostname is already enabled"
        exit 1
    fi

    cat=`cat $hostsfile | grep "^###" | grep "$hostname $comment"`
    if [ "$cat" == "" ]
    then
        echo "_enableHost error: host $hostname not disabled"
        exit 1
    else
        _removeHost $hostname
        _addHost $hostname
    fi
}

_disableHost ()
{
    hostname=$1
    if [ "$hostname" == "" ]
    then
        echo "_disableHost error: need a hostname as first parameter"
        exit 1
    fi

    ip=`_checkHost $hostname`
    if [ "$ip" == "" ]
    then
        echo "_disableHost error: host $hostname is not listed as active"
        exit 1
    else
        _removeHost $hostname
        line="###$ip $hostname $comment"
        echo $line | $sudo tee -a $hostsfile >/dev/null
    fi
}

# checks if a given hostname is registered
_checkHost ()
{
    hostname=$1
    if [ "$hostname" == "" ]
    then
        echo "_checkHost error: need a hostname as first parameter"
        exit 1
    fi

    cat=`cat $hostsfile | grep -v "^#" | grep "$hostname $comment"`
    if [ "$cat" != "" ]
    then
        count=`echo $cat | wc -l`
        ip=`echo $cat | cut -d " " -f 1`
        if [ "$count" == "1" ]
        then
            echo $ip
        fi
    fi
}

# now start the sub - command
# taken from http://stackoverflow.com/questions/1007538/
command="$1"
function="_${command}Host"
if type $function >/dev/null 2>&1
then
    $function $2 $3 $4
else
    if [ "$1" != "" ]
    then
        echo "$this: '$command' is not a $name command."
    else
        echo "$this: dont know what to do ..."
    fi
    echo "  try: add, remove or check"
    exit 1
fi

