#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2020
#  Licensed under the MIT license
#
#   REQUIRES URLENCODE which is in package gridsite-clients on Debian
#   REQUIRES sensible-browser to be set up
##############################################################################

function facebook_send {
    tmp=$(urlencode "${link}")
    link="https://www.facebook.com/sharer/sharer.php?u=${tmp}"
    outstring=$(echo "sensible-browser ${link} ")
    eval ${outstring} > /dev/null
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
        facebook_send
    fi
fi
