#!/bin/sh

##############################################################################
#
#  My renderer for newsboat/newsbeuter
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################


## may consider having it output as gfm and then having rich do it with -m --hyperlinks
                                                                        

if [ $# -eq 0 ]; then                                                 
    # no arguments passed, use stdin
    input=$(cat)
        echo "${input}" | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | sed -e 's/<!-- -->//g'| sed -e 's/<em[^>]*>/⬞/g' | sed -e 's/<\/em>/⬞/g' | sed -e 's/<strong[^>]*>/⬞/g' | sed -e 's/<\/strong>/⬞/g' | hxclean | hxnormalize -e -L -s 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | elinks -dump -dump-charset UTF-8 -dump-width 140 | grep -v "READ MORE:" 
#    echo "<html><body>" > /home/steven/reference_article.txt
#    echo $input | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | sed -e 's/<!-- -->//g' |  hxunent | iconv -t utf-8//TRANSLIT - >> /home/steven/reference_article.txt
    #echo "</body></html>" >> /home/steven/reference_article.txt
else
    # it's a URL, pass to elinks directly
    if [ $(echo "${1}" | grep -c http) -gt 0 ];then
        elinks "${1}" -dump -dump-charset UTF-8 -dump-width 140
        exit
    fi
    # it's a file, parse it this way
    if [ -f "${1}" ];then
        input=$(cat "${1}")
        echo $input | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | hxclean | hxnormalize -e -L -s 2>/dev/null | tidy -quiet -omit -clean 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | elinks -dump -dump-charset UTF-8 -dump-width 140 
    fi

fi                                                                        


#TODO:  Pull out the img tags to a status file or something?
#TODO: research how to get enclosures?
