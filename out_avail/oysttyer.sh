#!/bin/bash

function oysttyer_send {
    
    binary=$(grep 'oysttyer =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which oysttyer.pl)
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s: %s" "$title" "$link" )

    if [ ${#outstring} -gt 280 ]; then
        chop1=$( 280 - ${#link} )
        chop=$( ${#title} - ${chop1} )
        title=${title::${#title}-${chop}}
        outstring=$(printf "%s: %s" "$title" "$link" )
    fi
    
    outstring=$(echo "$binary -silent -status=\"$outstring\"")
    eval ${outstring}
}



