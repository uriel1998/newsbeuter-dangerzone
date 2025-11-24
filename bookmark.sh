#!/bin/bash

##############################################################################
#
#  This will interactively let you determine where your bookmarks will go for
#  newsboat or newsbeuter
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

# binaries should be linked to newsbeuter_dangerzone's config directory

# no gui, dammit. Kitty or spawned or in terminal.
# gets passed URL, title, description IIRC
# basically I want to either use tdab devour


   #the URL to bookmark (already preset with the URL of the current selection);
#   the bookmark title (in most cases preset with the title of the current selection);

 #  the bookmark description (default empty); and

  # (since Newsboat 2.10) the title of the feed you’re currently in (preset as you’d expect).
#(If you find that the above preset values always work for you, enable bookmark-autopilot to avoid being asked anything.)
#export enabled_out_dir
#export save_directory
#export profile
#export show_links
# Set directories, get environment, etc.
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.local/state}/newsbeuter_dangerzone"
if [ ! -d "${CACHE_DIR}" ];then
    mkdir -p "${CACHE_DIR}"
fi
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
# we are going to assume used as bookmarker from newsboat


    url="${1}"
    title="${2}"
    description="${3}"
    feed="${4}"
# test and see if this works, may have to check if #4 is filled etc.
# test if urls
# if no description, get it (like agaetr) as optional, also allow adding of
# description in fzf
echo "description: ${description}"
echo "feed: ${feed}"
source "$CONFIG_DIR/muna.sh"
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

# TODO - use preview to show what the text to send will be, duh!!!!

# Parsing enabled out systems. Find files in out_enabled, then import
# functions from each and running them with variables already established.

    READY=0
    # begin loop
    while [ "$READY" == "0" ];do
        header_text=$(echo -e " Title: ${title} \n Link: ${link}")
        prompt_text=" Choose your outputs!"
        bob=$(/usr/bin/ls -A "$SCRIPT_DIR/out_enabled")

        #posters=$(echo -e "edit_link\nedit_description\n${bob}" | sed 's/.sh//g' | grep -v ".keep" | fzf --multi --header="$header_text" --header-lines=0 --prompt="$prompt_text" --tmux 50% | sed 's/$/.sh&/p' | awk '!_[$0]++' )
        posters=$(echo -e "${bob}" | sed 's/.sh//g' | grep -v ".keep" | fzf --multi --header="$header_text" --header-lines=0 --prompt="$prompt_text" --tmux 50% | sed 's/$/.sh&/p' | awk '!_[$0]++' )
        # we will exit the loop UNLESS
        READY=1

        if [[ $posters == *"edit_link"* ]]; then
            READY=0
            echo "Old: ${link}"
            read -p "Enter your new URL: " link
        fi
        if [[ $posters == *"edit_description"* ]]; then
            READY=0
            echo "Old: ${title}"
            read -p "Enter your new description: " title
            echo "It's there!"
        fi
    done

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
