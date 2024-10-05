#!/bin/sh

##############################################################################
#
#  My renderer for newsboat/newsbeuter
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################


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

if [ $# -eq 0 ]; then                                                 
    # no arguments passed, use stdin
    input=$(cat)
    antimatch=""
    antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"], div[style*="visibility: hidden;"], div[style*="overflow: hidden;"]')
        if [ "$antimatch" != "" ];then
            echo " "
            echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -nolist -width=140 -collapse_br_tags | grep -v "READ MORE:"             
        else
            echo " "
            echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -nolist -width=140 -collapse_br_tags | grep -v "READ MORE:" 
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
        echo "${input}" > /home/steven/tmp/shit.txt
        antimatch=""
        antimatch=$(echo "${input}" | pup 'div[style*="display: none;"],div[style*="display:none;"],div[style*="visibility: hidden;"],div[style*="overflow: hidden;"]')
        if [ "$antimatch" != "" ];then
            echo " "
            echo "${input}"  | pup | grep -vF "${antimatch}" | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g' | hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -underscore -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -nolist -width=140 | grep -v "READ MORE:"             
        else
            echo " "
            echo "${input}"  | pup | sed -e 's/<div[^>]*>//g' | sed 's/<img[^>]\+>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | sed -e 's/<\/tr>/<\/tr><br \/>/g'| hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | lynx -dump -stdin -assume_charset=UTF-8 -force_empty_hrefless_a -hiddenlinks=ignore -html5_charsets -dont_wrap_pre -nolist -width=140 -collapse_br_tags | grep -v "READ MORE:" 
        fi
    fi
fi                                                                        

 

