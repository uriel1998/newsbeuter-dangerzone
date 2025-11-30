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
# get passed from newsboat -
# the URL to bookmark (already preset with the URL of the current selection);
# the bookmark title (in most cases preset with the title of the current selection);
# the bookmark description (default empty); and
# (since Newsboat 2.10) the title of the feed you’re currently in
# from env from onews
#enabled_out_dir, save_directory, profile, my_CONFIG_DIR

# Set directories, get environment, etc.
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
description2=""



export CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.local/state}/newsbeuter_dangerzone"
if [ ! -d "${CACHE_DIR}" ];then
    mkdir -p "${CACHE_DIR}"
fi
export CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
source "$CONFIG_DIR/muna.sh"

enabled_out_dir="${my_CONFIG_DIR}/${profile}/out_enabled"

# If the output dir is not configured in environment, sub the base NBDZ config dir
if [ ! -d "$(readlink -f "${enabled_out_dir}")" ];then
    enabled_out_dir="${CONFIG_DIR}/out_enabled"
fi
if [ ! -d "$(readlink -f "${my_CONFIG_DIR}")" ];then
    my_CONFIG_DIR="${CONFIG_DIR}"
fi

function loud() {
    if [ "${LOUD:-0}" -eq 1 ];then
        echo "$@"
    fi
}

function get_better_description() {
    # to strip out crappy descriptions and either omit them or, if available,
    # substitute og tags.
    # Also gets title if empty

    # If no title, get one
    # from https://unix.stackexchange.com/questions/103252/how-do-i-get-a-websites-title-using-command-line
    if [ -z "$title" ]; then
        title=$(wget -qO- "$link" | awk -v IGNORECASE=1 -v RS='</title' 'RT{gsub(/.*<title[^>]*>/,"");print;exit}' | recode html..  )
    fi

    patterns=("Photo illustration by" "The Independent is on the ground" "Sign up for our email newsletter" "originally published")
    patterns+="(Image Credit:"

    # Loop through the array and check if any pattern matches
    # If so, nuke the description.
    for pattern in "${patterns[@]}"; do
        if [[ "$description" == *"$pattern"* ]]; then
            loud "[info] Removing bogus description."
            description=""
        fi
    done

    loud "[info] Attempting to find OpenGraph tags for description"
    html=$(wget -O- "${link}" | sed 's|>|>\n|g')
    og_description=$(echo "${html}" | sed -n 's/.*<meta property="og:description".* content="\([^"]*\)".*/\1/p' | sed -e 's/ "/ “/g' -e 's/" /” /g' -e 's/"\./”\./g' -e 's/"\,/”\,/g' -e 's/\."/\.”/g' -e 's/\,"/\,”/g' -e 's/"/“/g' -e "s/'/’/g" -e 's/ -- /—/g' -e 's/(/❲/g' -e 's/)/❳/g' -e 's/ — /—/g' -e 's/ - /—/g'  -e 's/ – /—/g' -e 's/ – /—/g')
    if [ "$og_description" != "" ];then
        if  [[ "$description" == *"..."* ]];then
            loud "[info] Storing OpenGraph description for parsed description in slot 2."
            description2="${og_description}"
        else
            loud "[info] Subsituting OpenGraph description for empty or bad description."
            description="${og_description}"
        fi
    fi
    # Since there's no description anyway....
    og_image=$(echo "${html}" | sed -n 's/.*<meta property="og:image".* content="\([^"]*\)".*/\1/p')
    # Extract og:image:alt content
    og_image_alt=$(echo "${html}" | sed -n 's/.*<meta property="og:image:alt".* content="\([^"]*\)".*/\1/p')
    if [[ $og_image == http* ]];then
        imgurl="${og_image}"
        ALT_TEXT="${og_image_alt}"
        loud "[info] Found ${og_image}"
        loud "[info] Found ${og_image_alt}"
        #Checking the image url AGAIN before sending it to the client
        imagecheck=$(wget -q --spider "${imgurl}"; echo $?)
        if [ "${imagecheck}" -ne 0 ];then
            loud "[warn] Image no longer available; omitting."
            imgurl=""
            ALT_TEXT=""
        else
            export imgurl
            # if alt text is none and ai_alt_text is set
            # DOWNLOAD THE IMAGE
            # call the ai_alt_text - if some setting is set.
            #export ALT_TEXT
        fi
    fi


}





##############################################################################
# Enter here
##############################################################################

# we are going to assume used as bookmarker from newsboat
# or the same input format for the cli arguments

if [ $(echo "${1}" | grep -c http) -eq 0 ];then
    loud "[ERROR] No URL passed as first argument."
    exit 99
fi

# These are GLOBAL from this point.
export url="${1}"
export title=$(echo "${2}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' -e 's/&#27;/’/g' -e 's/&#39;/’/g' -e 's/%27/’/g' -e 's/â€œ/“/g' -e 's/â€™/’/g' -e 's/â€”/—/g' -e 's/â€�/”/g' -e 's/â€˜/‘/g' -e 's/â€¦/…/g' | sed 's/⬞§[[:space:]]*§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' )
export description=$(echo "${3}"  | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' -e 's/&#27;/’/g' -e 's/&#39;/’/g' -e 's/%27/’/g' -e 's/â€œ/“/g' -e 's/â€™/’/g' -e 's/â€”/—/g' -e 's/â€�/”/g' -e 's/â€˜/‘/g' -e 's/â€¦/…/g' | sed 's/⬞§[[:space:]]*§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' )
export feed="${4}"
export enabled_out_dir
export description2
export ALT_TEXT
export imgurl

# these functions are in muna, just avoiding yet another sub-sub-sub shell
# they work on the variable $url and set it back.
unredirector
strip_tracking_url
export link="${url}"
# so now both $url and $link should point to the same, unredirected, cleaned URL.

# if no description, get it (like agaetr) and get title if empty
get_better_description

# present gathered information in fzf preview panes
# description in fzf
# present menu options - including "edit description" (it's in an variable)
# and select however many of out-enabled as you like.
# TODO - can also have environment var of "default on" or "default off"

# OH!  If there's an image detected, we can add options to add or generate the alt text, along with a preset.  And if no image detected, we leave that out of our menu.  Duh.



# Parsing enabled out systems. Find files in out_enabled, then import
# functions from each and running them with variables already established.
# use my_CONFIG_DIR here, and we will need to rewrite the out files to
# parse the appropriate ini file, like by what program called it, what to default
# back to, etc.
    READY=0
    # begin loop
    while [ "$READY" == "0" ];do

        header_text=$(echo -e " Title: ${title} \n Link: ${link}")
        prompt_text=" Choose your outputs!"
        bob=$(/usr/bin/ls -A "${enabled_out_dir}")
# so let's just pre-process bob here, and add our additional menu entries prn
        bob=$(echo -e "${bob}" | sed 's/.sh//g' | grep -v ".keep")
        bob=$(printf %s\


        # * Edit Title
        # * Edit Description
        # * Edit Description2
        # * Edit Hashtags
        # * Edit Alt Text
        # * Generate Alt Text

        # It's important that the passthrough - just hitting return - gets us through with quick defaults.
        
        #posters=$(echo -e "edit_link\nedit_description\n${bob}" | sed 's/.sh//g' | grep -v ".keep" | fzf --multi --header="$header_text" --header-lines=0 --prompt="$prompt_text" --tmux 50% | sed 's/$/.sh&/p' | awk '!_[$0]++' )
        # we will exit the loop UNLESS
        posters=$(echo -e "${bob}" | sed 's/.sh//g' | grep -v ".keep" | fzf --multi --header="$header_text" --header-lines=0 --prompt="$prompt_text" --tmux 70% --preview='printf "Title: %s\n\nDescription: %s\n\nURL: %s\n\nFeed Name: %s\n\n" "$(echo ${title} | fold -s -w 50)" "$(echo ${description} | fold -s -w 50)" "$(echo ${url} | fold -s -w 50)" "$(echo ${feed} | fold -s -w 50)"' | sed 's/$/.sh&/p' | awk '!_[$0]++' )
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
