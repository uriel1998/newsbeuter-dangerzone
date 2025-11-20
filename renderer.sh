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
# removing images (seriously, it's a MESS otherwise -- saving those links for the bottom.
# changing em and strong tags to a UTF character for highlighting regex matches in neomutt/newsbeuter. (It doesn't work multiline, but hey)
# (also, regular markdown characters don't work, so I don't forget AGAIN and try AGAIN)
# adding a br after each table row so it doesn't become collapsed and we have SOME whitespace
# considering -nonumbers to clean up the body text, but...
# using rich to draw a box around the text and format it a little more nicely


CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/newsbeuter_dangerzone"
if [ ! -d "${CACHE_DIR}" ];then
    mkdir -p "${CACHE_DIR}"
fi

CacheFile=${CACHE_DIR}/newsboat_img_links

if [ -S "/tmp/mykitty" ];then
    kitty @ --to unix:/tmp/mykitty send-text --match "title:^newsboat_image_display" $'\x1b[D'
fi

PROCESSED=""
# If you have issues with tput, export COLUMNS prior to launching your app

if [ -z "$COLUMNS" ];then
    COLUMNS=$(tput cols)
fi
if [ $COLUMNS -gt 150 ];then
    COLUMNS=150
    WRAP=$(( COLUMNS - 10 ))
else
    WRAP=$(( COLUMNS ))
fi


if [ $# -eq 0 ]; then
    # no arguments passed, use stdin
    input=$(cat)
else
    if [ $(echo "${1}" | grep -c http) -gt 0 ];then
        PROCESSED=$(elinks "${1}" -dump -dump-charset UTF-8 -dump-width 130 -no-numbering -no-references)
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
    ImageLinks=$(echo "${input}" | pup | grep -oP '<img(?![^>]*style="[^"]*(display\s*:\s*(none|hidden|overflow))[^"]*")[^>]+src="\K[^"]+' | grep -e "^http" | grep -Fvf "${CONFIG_DIR}/filter_images_strings" - )
    if [ "${ImageLinks}" != "" ];then
        echo "${ImageLinks}" > "${CacheFile}"
    fi
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
        if [ "$antimatch" != "" ];then
            echo " "
            PROCESSED=$(echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -nolist -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        else
            echo " "
            PROCESSED=$(echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -nolist  -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
        fi
fi


—
 
# This isn't perfect -- multiline doesn't work at all, and combos of italics and strongs confuse it, but... it's readable?
timg https://deijjag.r.bh.d.sendibt3.com/im/3489906/744f39d5a286e321e763a40a141c288c5968132acccc7fc450ac940af557c7c4.png?e=BOSFW0udpHQq_l-G5xNbOTkJ5hFhxq9HBHw1S2i_z_hW6w5n4hcjrw4MWQg_WqK_lFJATGEVTZQxzYgZtHZ7J9Q3WzxTDFsb23zYIJY1rjec9eu0Da2k_fv5lzF5cCWxB-Kjlon5Y4hn79rLT6RJxDA91jDMIBdHlKoTszg8Hy9BRqmQMUi_yIPX4n8u1A3NQwjFL5dOAn0faSr9tuMsLVb9Mv5LjbGG9At0Yd3QBvVF9oOoEb60c1qgM5Rs20uNijgEUs0diNxQph2f-k29eSD7yTbyyEZbkC4TuXWo_oKbYH7l6_1Hfvc
printf "%s" "${PROCESSED}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' -e 's/&#39;/’/g' -e 's/—/ -- /g' -e 's/—/ -- /g' | sed 's/⬞§ *§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' -e 's/§//g' | rich -m -a rounded -d 2,2,2,2 -y --soft --print -W $COLUMNS -c -C -W $COLUMNS -w 138 -
rich -u
if [ "${ImagesExist}" != "" ];then
    echo "Image Links Present : "
    echo " "
    echo "${ImageLinks}"
    echo " "
    rich -u
fi
