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

# Saving image links to $XDG_CONFIG_HOME/newsboat_img_links as a read/write communication pipe.

CacheDir=${XDG_CACHE_HOME:-$HOME/.local/state}
CacheFile=${CacheDir}/newsboat_img_links
ImagesExist=0

# If you have issues with tput, export COLUMNS prior to launching your app


PROCESSED=""
if [ -z "$COLUMNS" ];then
    COLUMNS=$(tput cols)
fi
if [ $COLUMNS -gt 140 ];then
    COLUMNS=140
    WRAP=$(( COLUMNS - 10 ))
else
    WRAP=$(( COLUMNS ))
fi

if [ $# -eq 0 ]; then
    # no arguments passed, use stdin
    input=$(cat)
else
    if [ $(echo "${1}" | grep -c http) -gt 0 ];then
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
    ImagesExist=$(echo "${input}" | pup | grep -oP '<img(?![^>]*style="[^"]*(display\s*:\s*(none|hidden|overflow))[^"]*")[^>]+src="\K[^"]+' | grep -c -e "^http")
    if [ $ImagesExist -gt 0 ];then
        echo "${input}" | pup | grep -oP '<img(?![^>]*style="[^"]*(display\s*:\s*(none|hidden|overflow))[^"]*")[^>]+src="\K[^"]+' | grep -e "^http" > "${CacheFile}"
    fi
    
    # Looking for parts that wouldn't display anyway; this completely cleans up a LOT.
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')

        if [ "$antimatch" != "" ];then
            echo " "
            PROCESSED=$(echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        else
            echo " "
            PROCESSED=$(echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin  -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        fi
fi

# We need to separate out the references portion so it doesn't cut off URLs.

    # get the References line number
    ref_line=$(echo "${PROCESSED}" | grep -n '^References$' | cut -f1 -d:)
    # break it into before and after references
    first_variable=$(echo "$content" | head -n $((ref_line-1)))
    second_variable=$(echo "$content" | tail -n +$((ref_line+1)))

    var1=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==1')
    var2=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==2')
 
# This isn't perfect -- multiline doesn't work at all, and combos of italics and strongs confuse it, but... it's readable?
printf "%s" "${var1}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' | sed 's/⬞§ *§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' -e 's/§//g' | rich -m -a rounded -d 2,0,2,0 -y --print -W $COLUMNS -c -w $WRAP -
# The references by themselves
rich -u
echo "Visible URLs / References : "
echo " "
echo "$var2"
echo " "
rich -u
if [ $ImagesExist -gt 0 ];then
    echo "Image Links Present : "
    echo " "
    echo "${input}" | pup | grep -oP '<img(?![^>]*style="[^"]*(display\s*:\s*(none|hidden|overflow))[^"]*")[^>]+src="\K[^"]+' | grep -e "^http" 
    echo " "
    rich -u
fi

