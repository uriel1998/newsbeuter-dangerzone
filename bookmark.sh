#!/bin/bash

##############################################################################
#
#  This will interactively let you determine where your bookmarks will go for 
#  newsboat or newsbeuter
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

GUI=""
if [ "$1" == "-g" ];then
    GUI="YUP"
    shift
fi

if [ -z "$1" ];then
    url=$(xclip -o)
    shift 
else
    url="$1"
    shift
fi

title="${@:2}"

if [ -z "$url" ];then 
    if [ "$GUI" == "YUP" ];then
        tempurl=$(yad --width=500 --center --window-icon="icon-gtk-network" --title="Choose URL" --text="Please input an URL" --entry --editable )
    else
        echo "Please input an URL.  "
        read tempurl
    fi
    if [ -z "$tempurl" ];then
        exit 1
    else
        url="$tempurl"
    fi
fi

#Could this be causing the problem since it's in a subshell?
#export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export SCRIPT_DIR="$HOME/.newsboat"
cd "${SCRIPT_DIR}"
#Deshortening, deobfuscating, and unredirecting the URL

source "$SCRIPT_DIR/muna.sh"
unredirector
link="$url"


# If no title, get one
# from https://unix.stackexchange.com/questions/103252/how-do-i-get-a-websites-title-using-command-line
if [ -z "$title" ]; then
    title=$(wget -qO- "$link" | awk -v IGNORECASE=1 -v RS='</title' 'RT{gsub(/.*<title[^>]*>/,"");print;exit}' | recode html.. )
fi

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

if [ ! -z "$GUI" ];then 
    posters=$(yad --width=400 --height=400 --center --window-icon=gtk-network --borders 3 --skip-taskbar --title="Choose outputs for $link" --text="${title}" --checklist --list --column=Use:RD --column=metadata:text $( /usr/bin/ls -A "$SCRIPT_DIR/out_enabled" | sed 's/.sh//g' | grep -v ".keep" | sed 's/^/false /' ) | awk -F '|' '{ print $2 }' | sed 's/$/.sh&/p' | awk '!_[$0]++' )
else
    posters=$(/usr/bin/ls -A "$SCRIPT_DIR/out_enabled" | sed 's/.sh//g' | grep -v ".keep" | fzf --multi | sed 's/$/.sh&/p' | awk '!_[$0]++' )
fi

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

# TODO: add preview function to each of the modules for fzf --preview giving a quick explanation of what it does
# TODO: modules for each possible browser?
# TODO: Allow calling an editor with multiselect capabilities of fzf?
# TODO: Preview current values (and allow editing of) with fzf selection screen
