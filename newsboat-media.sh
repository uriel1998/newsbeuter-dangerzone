#!/usr/bin/env bash

if [ "${CACHE_DIR}" == "" ];then
    # Follows newboat paths
    if [[ -d "${HOME}/.newsboat" ]]; then
        CACHE_DIR="$HOME/.newsboat"
    else
        CACHE_DIR="$HOME/.local/share/newsboat"
        mkdir -p "$CACHE_DIR"
    fi
fi



default_image="${CACHE_DIR}/nbdz_default_image.jpg"
media_url=${1:-"$default_image"}
notify-send "${CacheFile}"
echo "${media_url}" > /home/steven/.newsboat/newsboat_img_links

