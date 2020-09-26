#!/bin/bash

function shaarli_send {
    
    binary=$(grep 'shaarli =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which shaarli)
    fi
    outstring=$(echo "$binary post-link --description \"$title\" --title \"$title\" --url ${link} ")
    eval ${outstring} > /dev/null
}

