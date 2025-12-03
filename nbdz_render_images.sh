#!/usr/bin/env bash

##############################################################################
#
#  Gettting, displaying images in a tmux panel
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
ANTITRACKING=0
# is it one-shot or persistent
PERSISTENT=0

if [ "${CONFIG_DIR}" == "" ];then
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
fi
if [ "${CACHE_DIR}" == "" ];then
    CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.local/state}
    if [ -z "${XDG_CACHE_HOME}" ];then
        export XDG_CACHE_HOME="${HOME}/.config"
        CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.local/state}
    fi
CacheFile=${CacheDir}/newsboat_img_links
if [ ! -f "${CacheFile}" ];then
    touch "${CacheFile}"
fi
# reset this file
CurrImageFile=${CacheDir}/newsboat_curr_img
echo "" > ${CurrImageFile}
TMPDIR=$(mktemp)

# loud turns off in kitty mode
if [ -S "/tmp/mykitty" ];then
    LOUD=0
fi

# Anti-tracking, using a hosts list if present
# place the hosts list in the NBDZ config  directory (NOT where you symlinked it to!)
# https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
# Not needed if you use a pi-hole or the rest, though it saves some time.
hosts_file="${CONFIG_DIR}/hosts"
if [ -f "${hosts_file}" ];then
    ANTITRACKING=1
fi


##############################################################################
# loud outputs on stderr
##############################################################################
 function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@" 1>&2
    fi
}

# Function to check if a domain is in the hosts list
check_domain_in_hosts() {
    local url=$1
    # Extract the domain from the URL
    local domain=$(echo "$url" | awk -F[/:] '{print $4}')

    # Check if the domain is present in the hosts file
    if grep -qw "$domain" "$hosts_file"; then
        return 0
    else
        echo "${1}"
    fi
}


show_the_image (){

}


################################################################################
# ENTRY point
################################################################################

# do we have a kitty socket? (and are we allowed to use it)
# are we in tmux? (and are we allowed to use popups)

# Determine what is being passed in to us.
# * nothing - look to image cache file, move pointer to working name
# * file list of urls -- substitute pointer to working name
#   * get list of urls, check against ANTITRACKING
#   * loop and pass to show_the_image

# * single url
#   * check against ANTITRACKING
#   * pass to show_the_image
# * file path
#   * pass to show_the_image
