#!/usr/bin/env bash

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
if [ "${CONFIG_DIR}" == "" ];then
    if [[ -d "$HOME/.newsboat" ]]; then
        CONFIG_DIR="$HOME/.newsboat"
    else
        CONFIG_DIR="$HOME/.config/newsboat"
        mkdir -p "$CONFIG_DIR"
    fi
fi

if [ "${CACHE_DIR}" == "" ];then
    # Follows newboat paths
    if [[ -d "$HOME/.newsboat" ]]; then
        CACHE_DIR="$HOME/.newsboat"
    else
        CACHE_DIR="$HOME/.local/share/newsboat"
        mkdir -p "$CACHE_DIR"
    fi
fi

source "${CONFIG_DIR}/muna.sh"

PriorArticle=${CACHE_DIR}/prior_article
touch "${PriorArticle}"
CacheFile=${CACHE_DIR}/newsboat_img_links
touch "${CacheFile}"
LinksCacheFile=${CACHE_DIR}/newsboat_links
touch "${LinksCacheFile}"
PLAINTEXT=0

# Plaintext may have URLs in it - say from mutt - so we need to pull them here.
extract_urls_from_plaintext() {
    local text="${1}"
    local counter=0
    local url=""

    # Find all http/https URLs, even if surrounded by other text
    while IFS= read -r url; do
        url=$(echo "$url" | awk '{print $1}')
        ((counter++))
        printf '   %d. %s\n' "${counter}" "${url}"
    done < <(
        grep -Eo 'https?://[^[:space:]]+' <<< "${text}"
    )
}

 

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
    # this is where newsboat comes in.
    input=$(cat)
else
    notify-send "hi"
    if [ $(echo "${1}" | grep -c http) -gt 0 ];then
        # render a webpage
            PROCESSED=$(elinks "${1}" -dump -no-numbering -no-references -dump-charset UTF-8 -dump-width 130)
    else
        # it's a file, parse it this way
        # this is where mutt comes in, so check for html/xml here.
        if [ -f "${1}" ];then
            input=$(< "${1}")
            testvar=$(echo "${input}" | grep -ci -e "<HTML" -e "<XML" )
            if [ $testvar -eq 0 ];then
                # it's plaintext -- extract links if exist
                plaintext_links=$(extract_urls_from_plaintext "${input}")
                PROCESSED=$(printf "%s\n\nReferences\n\n%s\n\n" "${input}" "${plaintext_links}")
            fi
        else
            loud "[error] I don't know what to do with this input."
            exit 90
        fi
    fi
fi    

if [ -z "$PROCESSED" ];then
    # putting image links in cache file here.
    ImageLinks=""
    ImageLinks=$(echo "${input}" | pup | grep -oP '<img(?![^>]*style="[^"]*(display\s*:\s*(none|hidden|overflow))[^"]*")[^>]+src="\K[^"]+' | grep  -e "^http" )
    if [ "${ImageLinks}" != "" ];then
        printf '%s\n' "${ImageLinks}" > "${CacheFile}"
    fi
    # Looking for parts that wouldn't display anyway; this completely cleans up a LOT.
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
    echo " " # <- leading whitespace, do not delete
    lynx_vars=""
    if [ "$antimatch" != "" ];then
        PROCESSED=$(echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean 2>/dev/null | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
    else
        PROCESSED=$(echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean 2>/dev/null | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=$WRAP -collapse_br_tags | grep -v "READ MORE:" )
    fi
fi
printf '%s\n' "${PROCESSED}" > ~/tmp/newsboat-processed.txt
if [ "$PROCESSED" != "" ];then
    var1=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==1')
    var2=$(printf "%s" "${PROCESSED}" | awk 'BEGIN{RS="References\n"; ORS=""} NR==2')


        
            orig_url="${url}"
            var2_clean=""
            while IFS= read -r line; do
                if [[ "${line}" == *http* ]]; then
                    # split references lines
                    url=""
                    number=$(printf ' %02d' "${line%%.*}")
                    url="${line#*. }"
                    url="${url%\"}"
                    #url=$(echo "${line}" | awk -F '' '{print $2}')
                    # clean the url
                    #unredirector
                    strip_tracking_url
                    #resassmeble
                    var2_clean+="${number}. ${url}"$'\n'
                else
                    continue
                fi
            done <<< "${var2}"
            url="${orig_url}"
            var2_clean=$(echo "${var2_clean}" | sort )
        
        

    echo "${var2_clean}" > "${LinksCacheFile}"
    # Get rid of garbage, translate back. Also remove emphasis and bold that are just over whitespace.
    var=$(printf "%s\n" "${var1}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' -e 's/&#27;/’/g' -e 's/&#39;/’/g' --e 's/â€œ/“/g' -e 's/â€™/’/g' -e 's/â€”/—/g' -e 's/â€�/”/g' -e 's/â€˜/‘/g' -e 's/â€¦/…/g' | sed 's/⬞§[[:space:]]*§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' | fold -s -w $WRAP)
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

        # The references by themselves
        rich -u
        echo "Visible URLs / References : "
        echo " "
        echo "${var2_clean}"
        echo " "
        rich -u
        if [ "${ImageLinks}" != "" ];then
            echo "Image Links Present : "
            echo "${ImageLinks}" | nl -w2 -n rz -s '. '
            echo " "
            rich -u
        fi

else
    echo "Textual data did not process properly."
fi
