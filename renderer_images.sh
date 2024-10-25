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
ANTITRACKING=0
MODTIME=0
TMPDIR=$(mktemp)

# Anti-tracking, using a hosts list if present
# place the hosts list in the script directory (NOT where you symlinked it to!)
# https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
# Not needed if you use a pi-hole or the rest, though it saves some time.
hosts_file="${SCRIPT_DIR}/hosts"
if [ -f "${hosts_file}" ];then 
    ANTITRACKING=1
fi


# we might want to use 
 -i ${CacheFile} to download them all first?

# Function to check if a domain is in the hosts list
check_domain_in_hosts() {
    local url=$1
    # Extract the domain from the URL
    local domain=$(echo "$url" | awk -F[/:] '{print $4}')
    
    # Check if the domain is present in the hosts file
    if grep -qw "$domain" "$hosts_file"; then
        return 0
    else
        wget -q -e robots=off -P /${TMPDIR} "$1" 2>/dev/null
        # show_image "$1"
    fi
}


function show_image {
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
        timg -pq --frames=1 "${1}"
        if [ $? -eq 0 ];then
            rich -u
        fi
    else
        if [ -f $(which jp2a) ];then
            # if it looks bad, try removing invert
            jp2a --colors --width=${cols} --invert "${1}"
            if [ $? -eq 0 ];then
                rich -u
            fi            
        fi
    fi

}


main () {
    if [ "$MODTIME" != $(date -r "${CacheFile}" +%s) ];then 
        MODTIME=$(date -r "${CacheFile}" +%s)
        clear
        echo "Checking and grabbing images"
        cat "${CacheFile}" | grep -e "^http" | grep -v -e "\/track" -e "sendgrid\." -e "icon" -e "ICON" |  while IFS= read -r line; do    
            if [ $ANTITRACKING == 1 ];then
                check_domain_in_hosts "${line}"
            else
                echo "${line}"
                show_image "${line}"
            fi
        done
        if [ $ANTITRACKING == 1 ];then
            timg -pq ${TMPDIR}/* 2>/dev/null
            rm ${TMPDIR}/* 2>/dev/null
        fi
        rich -u
    fi
}


while true; do
    main
    sleep 2
done
rm ${TMPDIR}
