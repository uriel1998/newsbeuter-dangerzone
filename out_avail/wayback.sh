#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
##############################################################################


function wayback_send {

# If you don't want to make another ini file, then export these into your environment
if [ "$WAYBACK_SECRET" == "" ] || [ "$WAYBACK_ACCESS" == "" ];then 
    WAYBACK_ACCESS=$(grep WAYBACK_ACCESS "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    WAYBACK_SECRET=$(grep WAYBACK_SECRET "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
fi

curl -X POST -H "Accept: application/json" -H "Authorization: LOW ${WAYBACK_ACCESS}:${WAYBACK_SECRET}" -d"url=${link}&capture_outlinks=1&capture_screenshot=1&skip_first_archive=1'" https://web.archive.org/save

#https://docs.google.com/document/d/1Nsv52MvSjbLb2PCpHlat0gkzw0EvtSgpKHu4mk0MnrA/edit#
}

##############################################################################
# Are we sourced?
# From http://stackoverflow.com/questions/2683279/ddg#34642589
##############################################################################

# Try to execute a `return` statement,
# but do it in a sub-shell and catch the results.
# If this script isn't sourced, that will raise an error.
$(return >/dev/null 2>&1)

# What exit code did that give?
if [ "$?" -eq "0" ];then
    echo "[info] Function ready to go."
    OUTPUT=0
else
    OUTPUT=1
    if [ "$#" = 0 ];then
        echo -e "Please call this as a function or with \nthe url as the first argument and optional \ndescription as the second."
    else
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2"
        fi
        wayback_send
    fi
fi

