#!/bin/bash

##############################################################################
#
#  shortening script
#  (c) Steven Saus 2020
#  Licensed under the MIT license
#
##############################################################################

 

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@" >&2
    fi
}


function yourls_shortener {

longlink="${1}"
# for if URL is > what the shortening is (otherwise you'll lose real data later)

if [ $(grep -c yourls_api "${XDG_CONFIG_HOME}/agaetr/agaetr.ini") -gt 0 ];then 
    
    yourls_api=$(grep yourls_api "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g'| awk -F '=' '{print $2}')
    yourls_site=$(grep yourls_site "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    curl_bin=$(which curl)
    yourls_string=$(printf "%s \"%s/yourls-api.php?signature=%s&action=shorturl&format=simple&url=%s\"" "${curl_bin}" "${yourls_site}" "${yourls_api}" "${longlink}")
    #loud "[info] Invoking ${yourls_string}"
    shorturl=$(eval "${yourls_string}")  
    if [ ${#shorturl} -lt 10 ];then # it didn't work 
        #loud "[error] Shortner failure, using original URL"
        #loud "[error] of $longlink"
        echo "${longlink}"
    else
        #verification that it starts with http here
        if [[ $shorturl == http* ]];then
            #loud "[info] Using shortened link ${shorturl}"
            echo "${shorturl}"            
        else
            #loud "[error] Unknown error from shortener, incorrect url returned, using original URL"
            #loud "[error] of $longlink"
            echo "${longlink}"
        fi
    fi
else
    # no configuration found, so just passing it back.
    #loud "[error] Shortener configuration not found, using original URL of" 
    #loud "[error] ${longlink}"
    echo "${longlink}"
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
            LOUD=0
        fi
    
        longlink="${1}"
        if [ ! -z "$2" ];then
            title="$2"
        else 
            title="${1}"
        fi
        yourls_shortener "${longlink}"
    fi
fi
