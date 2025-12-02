#!/bin/bash

##############################################################################
#
#  shortening script
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}

function yourls_out_send {


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

    yourls_api=$(grep yourls_api "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g'| awk -F '=' '{print $2}')
    yourls_site=$(grep yourls_site "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    yourls_string=$(printf "%s/yourls-api.php?signature=%s&action=shorturl&format=simple&url=%s" "$yourls_site" "$yourls_api" "$url")
    shorturl=$(wget "$yourls_string" -O- --quiet)
# TODO - BELOW IS NOT DONE
    # TODO - ACTUALLY HAVE WGET OR CURL MAKE THIS CALL DUH
    notify-send notify-send -i web-browser "${shorturl}"
    echo "${shorturl}" | xclip -i -selection primary -r
    echo "${shorturl}" | xclip -i -selection secondary -r
    echo "${shorturl}" | xclip -i -selection clipboard -r
    echo "${shorturl}" | tr -d '/n' | /usr/bin/copyq write 0  -
    /usr/bin/copyq select 0

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
    loud "[info] Function yourls_out_send ready to go."
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
        yourls_out_send
    fi
fi
