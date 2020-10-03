#!/bin/bash

function toot_send {

    binary=$(grep 'toot =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which toot)
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s: %s" "$title" "$link" )
        if [ ${#outstring} -gt 500 ]; then
            chop1=$( 500 - ${#link} )
            chop=$( ${#title} - ${chop1} )
            title=${title::${#title}-${chop}}
            outstring=$(printf "%s: %s" "$title" "$link" )
        fi
    
    postme=$(printf "%s post \"%s\" --quiet" "$binary" "$outstring")
    eval ${postme}
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
        toot_send
    fi
fi
