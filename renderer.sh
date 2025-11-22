#!/bin/sh

##############################################################################
#
#  My renderer for newsboat/newsbeuter/mutt
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

# For reference:

# using pup to clean it up, then to select divs that are supposed to be hidden and storing them in a variable.
# then taking the input, and removing those divs (yay grep)
# removing empty divs
# removing images (seriously, it's a MESS otherwise -- perhaps show those links at the bottom later?
# changing em and strong tags to a UTF character for highlighting regex matches in neomutt/newsbeuter. (It doesn't work multiline, but hey)
# (also, regular markdown characters don't work, so I don't forget AGAIN and try AGAIN)
# adding a br after each table row so it doesn't become collapsed and we have SOME whitespace
# considering -nonumbers to clean up the body text, but...
# using rich to draw a box around the text and format it a little more nicely

# Saving image links to $XDG_CACHE_HOME/newsboat_img_links as a read/write communication 
# Saving URLS found to $XDG_CACHE_HOME/newsboat_links as read/write communication
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"


CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.local/state}
if [ -z "${XDG_CACHE_HOME}" ];then
    export XDG_CACHE_HOME="${HOME}/.config"
fi
CacheFile=${CACHE_DIR}/newsboat_img_links
LinksCacheFile=${CACHE_DIR}/newsboat_links
echo "" > "${CacheFile}"
echo "" > "${LinksCacheFile}"


#resetting kitty display if existant
if [ -S "/tmp/mykitty" ];then
        kitty @ --to unix:/tmp/mykitty send-text --match "title:^newsboat_image_display" $'\x1b[D'
fi

# If you have issues with tput, export COLUMNS prior to launching your app

PROCESSED=""
if [ "$static_columns" != "" ];then
    COLUMNS=$static_columns
else
    if [ -z "$COLUMNS" ];then
        COLUMNS=$(tput cols)
    fi
fi
# padding
if [ $COLUMNS -gt 150 ];then
    COLUMNS=150
    WRAP=$(( COLUMNS - 10 ))
else
    WRAP=$(( COLUMNS - 4 ))
fi

if [ $# -eq 0 ]; then
    # no arguments passed, use stdin
    input=$(cat)
else
    if [ $(echo "${1}" | grep -c http) -gt 0 ];then
        # render a webpage
        PROCESSED=$(elinks "${1}" -dump -dump-charset UTF-8 -dump-width 130)
    else
        # it's a file, parse it this way
        if [ -f "${1}" ];then
            input=$(cat "${1}")
        else
            echo "I don't know what to do with this."
        fi
    fi
fi
if [ -z "$PROCESSED" ];then
    # putting image links in cache file here.
    ImageLinks=""
    ImageLinks=$(echo "${input}" | pup | grep -oP '<img(?![^>]*style="[^"]*(display\s*:\s*(none|hidden|overflow))[^"]*")[^>]+src="\K[^"]+' | grep  -e "^http" | grep -Fvf "${CONFIG_DIR}/filter_images_strings" - )
    if [ "${ImageLinks}" != "" ];then
        echo "${ImageLinks}" > "${CacheFile}"
    fi
    # Looking for parts that wouldn't display anyway; this completely cleans up a LOT.
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
    echo " " # <- leading whitespace, do not delete
    lynx_vars=""
    if [ "${show_links}" != "true" ];then
        if [ "$antimatch" != "" ];then
            PROCESSED=$(echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -nolist -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        else
            PROCESSED=$(echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -nolist -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        fi
    else
        if [ "$antimatch" != "" ];then
            PROCESSED=$(echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        else
            PROCESSED=$(echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        fi
    fi
fi
if [ -z "$PROCESSED" ];then
    # We need to separate out the references portion so it doesn't cut off URLs.
    # get the References line number
    ref_line=$(echo "${PROCESSED}" | grep -n '^References$' | cut -f1 -d:)
    # break it into before and after references
    first_variable=$(echo "$content" | head -n $((ref_line-1)))
    second_variable=$(echo "$content" | tail -n +$((ref_line+1)))

    var1=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==1')
    var2=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==2')
    echo "${var2}" > "${LinksCacheFile}"

    # This isn't perfect -- multiline doesn't work at all, and combos of italics and strongs confuse it, but... it's readable?
    printf "%s" "${var1}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' -e 's/&#39;/’/g' -e 's/—/ -- /g' -e 's/—/ -- /g' | sed 's/⬞§ *§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' -e 's/§//g' | rich -m -a rounded -d 2,0,2,0 -y --print -W $COLUMNS -c -w $WRAP -
    if [ "$show_links" = "true" ];then
        # The references by themselves
        rich -u
        echo "Visible URLs / References : "
        echo " "
        echo "$var2"
        echo " "
        rich -u
        if [ "${ImageLinks}" != "" ];then
            echo "Image Links Present : "
            echo " "
            echo "${ImageLinks}"
            echo " "
            rich -u
        fi
    fi
else
    echo "Textual data did not process properly."
fi
