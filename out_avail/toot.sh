#!/bin/bash

function toot_send {

    binary=$(grep 'toot =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which toot)
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s: %s" "$title" "$link" )
        if [ ${#outstring} -gt 500 ]; then
            chop1=$( 500 - ${#link} )
            chop=$( ${#title} - ${chop1} )
            title=${title::${#title}-${chop}}
            outstring=$(printf "%s: %s" "$title" "$link" )
        fi
    
    postme=$(printf "%s post \"%s\" --quiet" "$binary" "$outstring")
    eval ${postme}
}
