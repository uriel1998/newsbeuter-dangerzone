#!/bin/bash

function wallabag_send {
    
    binary=$(grep 'wallabag =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which wallabag)
    fi
    outstring=$(echo "$binary add --quiet --title \"$title\" $link ")
    echo "$outstring"
    eval ${outstring} > /dev/null
}

