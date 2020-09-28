#!/bin/bash

function wallabag_send {
    
    binary=$(grep 'wallabag =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which wallabag)
    fi
    # For some reason, wallabag-cli will not run without sudo. ::shrug::
    outstring=$(echo "sudo $binary add --quiet --title \"$title\" $link ")
    echo "$outstring"
    eval ${outstring} > /dev/null
}

