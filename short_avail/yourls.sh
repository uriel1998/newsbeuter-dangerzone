#!/bin/bash

##############################################################################
#
#  shortening script
#  (c) Steven Saus 2020
#  Licensed under the MIT license
#
##############################################################################

#get install directory
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LOUD=0

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


function yourls_shortener {

# for if URL is > what the shortening is (otherwise you'll lose real data later)

if [ $(grep -c yourls_api "${XDG_CONFIG_HOME}/cw-bot/${prefix}cw-bot.ini") -gt 0 ];then 
    
    yourls_api=$(grep yourls_api "${XDG_CONFIG_HOME}/cw-bot/${prefix}cw-bot.ini" | sed 's/ //g'| awk -F '=' '{print $2}')
    yourls_site=$(grep yourls_site "${XDG_CONFIG_HOME}/cw-bot/${prefix}cw-bot.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    wget_bin=$(which wget)
    yourls_string=$(printf "%s \"%s/yourls-api.php?signature=%s&action=shorturl&format=simple&url=%s\" -O- --quiet" "${wget_bin}" "${yourls_site}" "${yourls_api}" "${link}")
    shorturl=$(eval "${yourls_string}")  
    if [ ${#link} -lt 10 ];then # it didn't work 
        loud "Shortner failure, using original URL of"
        loud "$link"
    else
        # may need to add verification that it starts with http here?
        loud "Using shortened link $shorturl"
        link=$(echo "$shorturl")
    fi
else
    # no configuration found, so just passing it back.
    loud "Shortener configuration not found, using original URL of" 
    loud "$link"
fi

}
