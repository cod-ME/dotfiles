#!/bin/sh

raw=`df -H / | grep /dev/`

case $1 in
    "--used" )
        value=`echo $raw | awk '{printf $3}'`
        ;;
    "--all" )
        value=`echo $raw | awk '{printf $2}'`
        ;;
    "--free" )
        value=`echo $raw | awk '{printf $4}'`
        ;;
    * )
        true
        ;;
esac
value=${value::-1}
echo $value
