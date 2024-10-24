#!/bin/bash

##############################################################################
#
#  Gettting, displaying images in a tmux panel
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

CacheDir=${XDG_CACHE_HOME:-$HOME/.local/state}
if [ -z "${XDG_CACHE_HOME}" ];then
    export XDG_CACHE_HOME="${HOME}/.config"
fi
CacheFile=${CacheDir}/newsboat_img_links
if [ ! -f "${CacheFile}" ];then
    touch "${CacheFile}"
fi
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DEFAULT_COVER="${SCRIPT_DIR}/defaultimage.jpg"

MODTIME=0


function show_album_art {
    
    clear
    cols=$(tput cols)
    lines=$(tput lines)
    if [ "$cols" -gt "$lines" ]; then
        gvalue="$cols"
        lvalue="$lines"
    else
        gvalue="$lines"
        lvalue="$cols"
    fi
    bvalue=$(echo "scale=4; $gvalue-3" | bc)
    if [ "$bvalue" -gt 78 ];then
        bvalue=78
    fi
    if [ -f $(which timg) ];then
        timg -U -pq "${1}"
    else
        if [ -f $(which jp2a) ];then
            # if it looks bad, try removing invert
            jp2a --colors --width=${cols} --invert "${1}"
        fi
    fi

}


main () {
    if [ "$MODTIME" != $(date -r "${CacheFile}" +%s) ];then 
        MODTIME=$(date -r "${CacheFile}" +%s)
        cat "${CacheFile}" | grep -e "^http" | while IFS= read -r line; do    
            echo "${line}"
            show_album_art "${line}"
        done
    fi
}


while true; do
    main
    sleep 2
done
