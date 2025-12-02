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


    # check some config things that SHOULD be set, etc.
    if [ -n "${my_CONFIG_DIR}" ];then
        # if the variable is set and exported, they've probably set it up properly.
        ConfigFile="${my_CONFIG_DIR}/newsbeuter_dangerzone.ini"
    else
        loud "[WARN] Configuration variable not set, checking default location."
        # try to find a default quickly.
        CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
        # here, though, we're doublechecking.
        if [ -f "${CONFIG_DIR}/newsbeuter_dangerzone.ini" ];then
            ConfigFile="${CONFIG_DIR}/newsbeuter_dangerzone.ini"
        else
            loud "[ERROR] Configuration not found at"
            loud "[ERROR] ${CONFIG_DIR}/newsbeuter_dangerzone.ini"
            exit 97
        fi
    fi

# TODO - BELOW IS NOT DONE

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
    loud "[info] Function toot ready to go."
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
            if [ "$LOUD" == "" ];then
                # so it doesn't clobber exported env
                LOUD=0
            fi
        fi
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2" # These should already be cleaned.
        fi
        shaarli_send
    fi
fi
