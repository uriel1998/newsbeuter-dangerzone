#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
##############################################################################

function save_html_send {

    #THIS IS THE BASE PATH WHERE THIS MODULE WILL SAVE COPIES
    HtmlSavePath="${XDG_DATA_HOME}/agaetr/save"

    if [ -f $(which detox) ];then
        dttitle=$(echo "${title}" | detox --inline)
        outpath="${HtmlSavePath}/${dttitle}"
    else
        outpath="${HtmlSavePath}/${title}"
    fi
    
    nowdir=$(echo "$PWD")
    mkdir "${outpath}"
    cd "${outpath}"

    
    binary=$(grep 'wget =' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which wget)
    fi
    if [ -f "$binary" ];then
        outstring=$(echo "$binary -H --connect-timeout=2 --read-timeout=10 --tries=1 -p -k --convert-links --restrict-file-names=windows -e robots=off \"${link}\"")
        eval "${outstring}"
    fi
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
        save_html_send
    fi
fi
