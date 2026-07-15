#!/usr/bin/env bash

##############################################################################
#
#  Gettting, displaying images in a tmux panel
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
save_directory=""
default_image="${SCRIPT_DIR}/nbdz_default_image.jpg"

# Follows newboat paths
if [[ -d "$HOME/.newsboat" ]]; then
    CACHE_DIR="$HOME/.newsboat"
else
    CACHE_DIR="$HOME/.local/share/newsboat"
    mkdir -p "$CACHE_DIR"
fi

if [[ -d "$HOME/.newsboat" ]]; then
    CONFIG_DIR="$HOME/.newsboat"
else
    CONFIG_DIR="$HOME/.config/newsboat"
    mkdir -p "$CONFIG_DIR"
fi

ConfigFile="${CONFIG_DIR}/newsbeuter_dangerzone.ini"

if [ -f ${ConfigFile} ];then
    save_directory=$(grep 'save_directory=' "${ConfigFile}" | sed 's/ //g' | awk -F '=' '{print $2}')
else
    if [ -d "${HOME}/Downloads" ];then
        save_directory="${HOME}/Downloads"
    elif [ -d "${HOME}/downloads" ];then
        save_directory="${HOME}/downloads"
    else
        mkdir -p "${HOME}/Downloads"
        save_directory="${HOME}/Downloads"
    fi
fi

CacheFile=${CACHE_DIR}/newsboat_img_links
if [ ! -f "${CacheFile}" ];then
    touch "${CacheFile}"
fi
# reset this file
CurrImageFile=${CACHE_DIR}/newsboat_curr_img
echo "" > ${CurrImageFile}
TMPDIR=$(mktemp)

##############################################################################
# loud outputs on stderr
##############################################################################
 function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@" 1>&2
    fi
}
 

show_image (){
    local image="${@}"
    if [ ! -f "${image}" ];then
        image=$(echo "${@}" | grep -Eo 'https?://[^[:space:]]+')
    fi
    if [ "${image}" == "" ];then
        image="${default_image}"
    fi
    timg -p k "${image}"
}

save_image (){

    local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0"
    local image_url=$(echo "${@}" | grep -Eo 'https?://[^[:space:]]+')
    
    #removing query strings, getting filename
    filename="${image_url%%\?*}"
    filename="${filename##*/}"
    loud "[info] Saving file as ${save_directory}/${filename}" #TODO - auto-increment
    notify-send "${save_directory}/${filename}"
    wget --no-check-certificate -erobots=off --user-agent="${ua}" -O "${save_directory}/${filename}" "${image_url}" 
}


 

################################################################################
# ENTRY point
################################################################################
# CAN JUST USE -p k with KITTY AND TIMG
# do we have a kitty socket? (and are we allowed to use it)
# are we in tmux? (and are we allowed to use popups)

show_image "${default_image}"

# Determine what is being passed in to us.
# * nothing - look to image cache file, move pointer to working name
current_line=1
command=""
# get last mod
last_modified=$(stat -c "%Y" "${CacheFile}")
while [ -f "${CacheFile}" ];do
    clear
    # show image
    
    url=$(head -n ${current_line} "${CacheFile}" | tail -1)
    show_image "${url}"
    total_lines=$(wc -l "${CacheFile}" | awk '{print $1}')
    # present choices
    if [ $total_lines -gt 1 ];then
        read -p "──[ Save|Clear|Next|Previous|Quit ]──[ " -t 10 -n 1 reply
    else 
        read -p "──[ Save|Clear|Quit ]──[ " -t 10 -n 1 reply
    fi
    case "${reply}" in
        S|s)
            save_image "${url}"
            ;;
        C|c) echo "${SCRIPT_DIR}/nbdz_default_image.jpg" > "${CacheFile}" ;;
        P|p) 
            if [ $total_lines -gt 1 ] && [ $current_line -gt 1 ];then
                (( current_line-- ))
                continue
            fi
        ;;
        N|n) 
            if [ $total_lines -gt 1 ] && [ $current_line -lt $total_lines ];then
                (( current_line++ ))
                continue
            fi
        ;;
        Q|q) break ;;
        *) 
            now_modified=$(stat -c "%Y" "${CacheFile}")
            if [ "$now_modified" -eq "$last_modified" ];then
                if [ $total_lines -gt 1 ] && [ $current_line -lt $total_lines ];then
                    (( current_line++ ))
                elif [ $total_lines -gt 1 ] && [ $current_line -eq $total_lines ];then
                    current_line=1
                fi
                continue 
            else
                # reset last mod
                last_modified=$(stat -c "%Y" "${CacheFile}")
                continue
            fi
            ;;
    esac
done
 
# * file list of urls -- substitute pointer to working name
#   * get list of urls, check against ANTITRACKING
#   * loop and pass to show_the_image

# * single url
#   * check against ANTITRACKING
#   * pass to show_the_image
# * file path
#   * pass to show_the_image
# at the end of show_the_image have a text line that allows for save, quit, next, previous
