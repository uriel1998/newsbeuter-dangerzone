#!/usr/bin/env bash

##############################################################################
#
#  Gettting, displaying images in a tmux panel
#  (c) Steven Saus 2026
#  Licensed under the MIT license
#
##############################################################################

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
save_directory=""
# reset this file
default_image="${SCRIPT_DIR}/nbdz_default_image.jpg"
# passed in by renderer to note which pane it is.
ourpane=""

if [[ "${@}" == *"--pane="* ]];then
    ourpane=$(echo "${@}" | awk -F "=" '{print $2}')
fi

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
    echo "${default_image}" > "${CacheFile}"
fi


##############################################################################
# loud outputs on stderr
##############################################################################
 function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@" 1>&2
    fi
}
 

show_image (){
    local image="${1}"


    if [ -z "${image}" ];then
        image="${default_image}"
    fi

    if [ ! -f "${image}" ];then
        image=$(printf '%s\n' "$1" | grep -Eo 'https?://[^[:space:]]+')
    fi
    
    if [ "$(tmux display-message -p -t "$ourpane" '#{pane_active}')" -eq 1 ]; then
        timg -p k "${image}"
    else
        timg "${image}"
    fi

}

save_image (){
    
    local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0"
    local image_url=$(echo "${1}" | grep -Eo 'https?://[^[:space:]]+')
    
    #removing query strings, getting filename
    filename="${image_url%%\?*}"
    filename="${filename##*/}"
    loud "[info] Saving file as ${save_directory}/${filename}" #TODO - auto-increment
    wget --no-check-certificate -erobots=off --user-agent="${ua}" -O "${save_directory}/${filename}" "${image_url}" 
}


 

################################################################################
# ENTRY point
################################################################################
# CAN JUST USE -p k with KITTY AND TIMG
# do we have a kitty socket? (and are we allowed to use it)
# are we in tmux? (and are we allowed to use popups)


# Determine what is being passed in to us.
# * nothing - look to image cache file, move pointer to working name
current_line=1
# get last mod
last_modified=$(stat -c "%Y" "${CacheFile}")

while [ -f "${CacheFile}" ];do
    clear     
    # show image
    
    total_lines=$(wc -l "${CacheFile}" | awk '{print $1}')
    url=$(head -n ${current_line} "${CacheFile}" | tail -1)
    #clear
    show_image "${url}"
    # present choices
    # refresh rate, display mode different if not focused    
    if [ "$(tmux display-message -p -t "$ourpane" '#{pane_active}')" -eq 1 ]; then
        if [ $total_lines -gt 1 ];then
            read -p "──[ Save|Clear|Next|Prev|Quit ]──[ $current_line / $total_lines ]──[ " -t 10 -n 1 reply
        else 
            read -p "──[ Save|Clear|Quit ]──────────────────[ " -t 10 -n 1 reply
        fi
    else
        if [ $total_lines -gt 1 ];then
            read -p "──[ Save|Clear|Next|Prev|Quit ]──[ $current_line / $total_lines ]──[ " -t 3 -n 1 reply
        else 
            read -p "──[ Save|Clear|Quit ]──────────────────[ " -t 3 -n 1 reply
        fi
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


# perhaps enact a blacklist somewhere? 
# * file list of urls -- substitute pointer to working name
#   * get list of urls, check against ANTITRACKING
#   * loop and pass to show_the_image

# * single url
#   * check against ANTITRACKING
#   * pass to show_the_image
# * file path
#   * pass to show_the_image
# at the end of show_the_image have a text line that allows for save, quit, next, previous
