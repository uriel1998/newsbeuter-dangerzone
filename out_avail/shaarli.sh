#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2025
#  Licensed under the MIT license
#
##############################################################################

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


function shaarli_send {
    inifile="${XDG_CONFIG_HOME}/agaetr/agaetr.ini"
    binary=$(grep 'shaarli =' "${inifile}" | sed 's/ //g' | awk -F '=' '{print $2}')
    # No length requirements here!
    tags=$(echo "$hashtags"  | sed 's|#||g' )

    if [ -z "${description}" ];then
        outstring=$(echo "$binary post-link --title \"$title\" --url $link ")
    else
        outstring=$(echo "$binary post-link --description \"$description\" --tags \"$tags\" --title \"$title\" --url $link ")
    fi

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
    echo "[info] Function shaarli ready to go."
    OUTPUT=0
else
    OUTPUT=1
    if [ "$#" = 0 ];then
        echo -e "Please call this as a function or with \nthe url as the first argument and optional \ndescription as the second."
    else
        if [ "${1}" == "--loud" ];then
            LOUD=1
            shift
        else
            LOUD=0
        fi    
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2"
        fi
        shaarli_send
    fi
fi
