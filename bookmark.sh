#!/bin/bash

##############################################################################
#
#  This will interactively let you determine where your bookmarks will go.
#  (c) Steven Saus 2020
#  Tmux and my Tmux-devour script encouraged with this 
#
##############################################################################
url="$1"
title="${@:2}"

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

#Deshortening, deobfuscating, and unredirecting the URL

source "$SCRIPT_DIR/unredirector.sh"
unredirector
link="$url"

# SHORTENING OF URL
# call first (should be only) element in shortener dir to shorten url

if [ "$(ls -A "$SCRIPT_DIR/short_enabled")" ]; then
    shortener=$(ls -lR "$SCRIPT_DIR/short_enabled" | grep ^l | awk '{print $9}')
    if [ -z "$shortener" ];then
        echo "No URL shortening performed."
    else
        if [ "$shortener" != ".keep" ];then 
            short_funct=$(echo "${shortener%.*}_shortener")
            source "$SCRIPT_DIR/short_enabled/$shortener"
            url="$link"
            echo "$SCRIPT_DIR/short_enabled/$shortener"
            eval ${short_funct}
            link="$shorturl"
            echo "$shorturl"
            echo "$link"
        fi
    fi
fi

    
# Parsing enabled out systems. Find files in out_enabled, then import 
# functions from each and running them with variables already established.

posters=$(/usr/bin/ls -A "$PWD/out_enabled" | sed 's/.sh//g' | grep -v ".keep" | fzf --multi | sed 's/$/.sh&/p' | uniq)
            

for p in $posters;do
    if [ "$p" != ".keep" ];then 
        echo "Processing ${p%.*}..."
        send_funct=$(echo "${p%.*}_send")
        source "$SCRIPT_DIR/out_enabled/$p"
        echo "$SCRIPT_DIR/out_enabled/$p"
        eval ${send_funct}
        sleep 5
    fi
done

