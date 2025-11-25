#!/bin/bash

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
# saving env varibles for mutt, other programs that you can't alter env on the fly.
# Saving image links to $XDG_CACHE_HOME/newsboat_img_links as a read/write communication
# Saving URLS found to $XDG_CACHE_HOME/newsboat_links as read/write communication
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
source "${CONFIG_DIR}/muna.sh"

CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.local/state}
if [ -z "${XDG_CACHE_HOME}" ];then
    export XDG_CACHE_HOME="${HOME}/.config"
fi
CacheFile=${CACHE_DIR}/newsboat_img_links
echo "" > "${CacheFile}"
LinksCacheFile=${CACHE_DIR}/newsboat_links
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

if [ "$PROCESSED" != "" ];then
    # We need to separate out the references portion so it doesn't cut off URLs.
    # get the References line number
    ref_line=$(echo "${PROCESSED}" | grep -n '^References$' | cut -f1 -d:)
    # break it into before and after references
    first_variable=$(echo "$content" | head -n $((ref_line-1)))
    second_variable=$(echo "$content" | tail -n +$((ref_line+1)))

    var1=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==1')
    var2=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==2')

# TODO - switch for cleaning or non-cleaning from env variable
# TODO - cannot use env for mutt, fuckity fuck fuck fuck.

    if [ "$show_links" = "true" ];then

        orig_url="${url}"
        var2_clean=""
        while IFS= read -r line; do
            if [[ "${line}" == *http* ]]; then
                # split references lines
                url=""
                number="${line%%.*}"
                url="${line#*. }"
                #url=$(echo "${line}" | awk -F '' '{print $2}')
                # clean the url
                unredirector
                strip_tracking_url
                #resassmeble
                var2_clean+=$'\t'"${number}. ${url}"$'\n'
            else
                var2_clean+=$(echo -e " ")
            fi
        done <<< "${var2}"
        wait
        url="${orig_url}"
        var2_clean=$(echo "${var2_clean}" | sort )

        echo "${var2_clean}" > "${LinksCacheFile}"
    else
        # if we are not displaying links, we're not going to bother cleaning them.
        echo "${var2}" > "${LinksCacheFile}"
    fi

    # Get rid of garbage, translate back. Also remove emphasis and bold that are just over whitespace.
    var=$(printf "%s\n" "${var1}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' -e 's/&#39;/’/g' --e 's/â€œ/“/g' -e 's/â€™/’/g' -e 's/â€”/—/g' -e 's/â€�/”/g' -e 's/â€˜/‘/g' -e 's/â€¦/…/g' | sed 's/⬞§[[:space:]]*§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' | fold -s -w $WRAP)
    # fixing multiline em/strong by wrapping first.
    open_mark="§⬞"
    close_mark="⬞§"
    new_var=""
    while IFS= read -r line; do
        tmp="${line//${open_mark}/}"
        open_count=$(( ( ${#line} - ${#tmp} ) / ${#open_mark} ))

        tmp="${line//${close_mark}/}"
        close_count=$(( ( ${#line} - ${#tmp} ) / ${#close_mark} ))

        if (( open_count == close_count + 1 )); then
            line="${line}${close_mark}"
        fi

        new_var+="${line}"$'\n'
    done <<< "${var}"
    var="${new_var}"
    open_mark="§⬞"
    close_mark="⬞§"
    new_var=""
    while IFS= read -r line; do
        tmp="${line//${open_mark}/}"
        open_count=$(( ( ${#line} - ${#tmp} ) / ${#open_mark} ))

        tmp="${line//${close_mark}/}"
        close_count=$(( ( ${#line} - ${#tmp} ) / ${#close_mark} ))

        if (( close_count == open_count + 1 )); then
            line="${open_mark}${line}"
        fi

        new_var+="${line}"$'\n'
    done <<< "${var}"

    # finally removing the paragraph mark, as we're done with it, and moving it all back to var1.
    var1=$(printf "%s\n" "${new_var}" | sed 's/§⬞[[:space:]]*⬞§//g'  | sed 's/⬞§[[:space:]]*§⬞//g'  | sed -e 's/§//g' )


    printf "%s\n" "${var1}" | rich -m -a rounded -d 2,0,2,0 -y --print -W $COLUMNS -c -w $WRAP -
    if [ "$show_links" = "true" ];then
        # The references by themselves
        rich -u
        echo "Visible URLs / References : "
        echo " "
        echo "${var2_clean}"
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
