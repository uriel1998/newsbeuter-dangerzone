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

PROCESSED=""

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
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
        if [ "$antimatch" != "" ];then
            echo " "
            PROCESSED=$(echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -nolist -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=130 -collapse_br_tags | grep -v "READ MORE:" )
        else
            echo " "
            PROCESSED=$(echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/§⬞/g' | sed -e 's/<\/em>/⬞§/g' | sed -e 's/<strong[^>]*>/§⬞/g' | sed -e 's/<\/strong>/⬞§/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -nolist  -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -width=130 -collapse_br_tags | grep -v "READ MORE:" )
        fi
fi        

# This isn't perfect -- multiline doesn't work at all, and combos of italics and strongs confuse it, but... it's readable?
printf "%s" "${PROCESSED}" | sed -e 's/ ⬞/⬞/g' -e 's/ ⬞/⬞/g' | sed 's/⬞§ *§⬞//g'  |  sed -e 's/⬞ /⬞/g' -e 's/⬞ /⬞/g' -e 's/§//g' | rich -m -a rounded -d 2,2,2,2 -y --soft --print -W 140 -w 138 -

