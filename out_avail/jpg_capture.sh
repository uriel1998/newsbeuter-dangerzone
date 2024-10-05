#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

function jpeg_capture_send {



    SAVEDIR=$(xdg-user-dir DOWNLOAD)
    if [ ! -d "${SAVEDIR}" ];then
        SAVEDIR="${HOME}"
    fi    
    if [ -f $(which detox) ];then
        dttitle=$(echo "${title}" | detox --inline)
        outpath="${SAVEDIR}/${dttitle}.jpg"
    else
        outpath="${SAVEDIR}/${title}.jpg"
    fi
    echo "Writing to ${outpath}"
    binary=$(which cutycapt)
    if [ ! -f "$binary" ];then
        binary=$(grep 'cutycapt =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')    
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s" "$link" )
        outstring=$(echo "$binary --smooth --insecure --url=\"$outstring\" --out=\"${outpath}\"")
        eval ${outstring}
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
        jpeg_capture_send
    fi
fi
