#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}

function jpeg_capture_send {

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

    # environment
    if [ "${save_directory}" != "" ] && [ -d "${save_directory}" ];then
        SAVEDIR="${save_directory}"
    else
        #ini
        save_directory=$(grep 'save_directory' "${ConfigFile}" | sed 's/ //g' | awk -F '=' '{print $2}')
        if [ "${save_directory}" != "" ] && [ -d "${save_directory}" ];then
            SAVEDIR="${save_directory}"
        else
            SAVEDIR=$(xdg-user-dir DOWNLOAD)
            if [ ! -d "${SAVEDIR}" ];then
                SAVEDIR="${HOME}"
            fi
        fi
    fi
    if [ -f $(which detox) ];then
        dttitle=$(echo "${title}" | detox --inline)
        outpath="${SAVEDIR}/${dttitle}.jpg"
    else
        outpath="${SAVEDIR}/${title}.jpg"
    fi
    binary=$(which cutycapt)
    if [ ! -f "$binary" ];then
        binary=$(grep 'cutycapt =' "${ConfigFile}" | sed 's/ //g' | awk -F '=' '{print $2}')
    fi
    if [ -f "$binary" ];then
        loud "[info] Writing to ${outpath}"
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
        jpeg_capture_send
    fi
fi
