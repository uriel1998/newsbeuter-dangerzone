#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
##############################################################################

function shaarli_send {
    
    inifile="${XDG_CONFIG_HOME}/agaetr/agaetr.ini"
    
    binary=$(grep 'shaarli =' "${inifile}" | sed 's/ //g' | awk -F '=' '{print $2}')
    # No length requirements here!
    tags=$(echo "$hashtags"  | sed 's|#||g' )

    #outstring=$(printf "From %s: %s - %s %s %s" "$pubtime" "$title" "$description" "$link" "$hashtags")

    # Check to loop over multiple configs in ini
    configs=$(grep --after-context=1 "[shaarli_config" "${inifile}" | grep -v -e "[shaarli_config" -e "--")
    # this isn't in quotation marks so we get the newline, fyi.
    for cfile in ${configs}
    do
        if [ ! -f ${cfile} ];then
            # The above is both for backwards compatibility and for continuing even after errors
            if [ -z "${description}" ];
                outstring=$(echo "$binary post-link --title \"$title\" --url $link ")
            else
                outstring=$(echo "$binary post-link --description \"$description\" --tags \"$tags\" --title \"$title\" --url $link ")
            fi
        else
            if [ -z "${description}" ];
                outstring=$(echo "$binary --config ${cfile} post-link --title \"$title\" --url $link ")
            else
                outstring=$(echo "$binary --config ${cfile} post-link --description \"$description\" --tags \"$tags\" --title \"$title\" --url $link ")
            fi
        fi

        eval ${outstring} > /dev/null
    done
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
        shaarli_send
    fi
fi
