#!/bin/sh

##############################################################################
#
#  My renderer for newsboat/newsbeuter/mutt
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

if [ $# -eq 0 ]; then                                                 
    # no arguments passed, use stdin
    input=$(cat)
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
    if [ "$antimatch" != "" ];then
        echo " "
        echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | elinks -dump -dump-width 140 | grep -v "READ MORE:"             
    else
        echo " "
        echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | elinks -dump -dump-width 140 | grep -v "READ MORE:" 
    fi
else
    # it's a URL, pass to elinks directly
    if [ $(echo "${1}" | grep -c http) -gt 0 ];then
        elinks "${1}" -dump -dump-charset UTF-8 -dump-width 140
        exit
    fi
    # it's a file, parse it this way
    if [ -f "${1}" ];then
        input=$(cat "${1}")
        # this is to deal with stupid hidden divs in HTML emails
        # should only invoke when it's there; otherwise it craps out the whole thing.
        antimatch=""
        antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
        if [ "$antimatch" != "" ];then
            echo " "
            echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | elinks -dump -dump-width 140 | grep -v "READ MORE:"             
        else
            echo " "
            echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | elinks -dump -dump-width 140 | grep -v "READ MORE:" 
        fi
    fi

fi                                                                        


#TODO:  Pull out the img tags to a status file or something?
#TODO: research how to get enclosures?
