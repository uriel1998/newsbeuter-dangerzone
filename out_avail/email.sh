#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2020
#  Licensed under the MIT license
#
##############################################################################

#DEFAULT EMAIL
DefaultEmail="root@localhost"

function email_send {

    tmpfile=$(mktemp)
    echo "Obtaining text of HTML..."
    echo "${link}" > ${tmpfile}
    echo "  " >> ${tmpfile}
    
    # HTML to plain text via lynx
    wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" |lynx -dump -stdin -display_charset UTF-8 -width 140 >> ${tmpfile}
    
    # HTML to plain text via Pandoc
    #wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" | pandoc --from=html --to=gfm >> ${tmpfile}
    
    # My convoluted bespoke HTML to plain text
    #wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | hxclean | hxnormalize -e -L -s 2>/dev/null | tidy -quiet -omit -clean 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | sed -e 's/\(<em>\|<i>\|<\/em>\|<\/i>\)/&🞵/g' | sed -e 's/\(<strong>\|<b>\|<\/strong>\|<\/b>\)/&🞶/g' |lynx -dump -stdin -display_charset UTF-8 -width 140 | sed -e 's/\*/•/g' | sed -e 's/Θ/🞵/g' | sed -e 's/Φ/🞯/g' >> ${tmpfile}
    
    # This is from https://github.com/uriel1998/ppl_virdirsyncer_addysearch
    addressbook=$(which pplsearch)
    if [ -f "$addressbook" ];then
        email=$(eval "$addressbook" -m)
    fi
    if [ -z ${email} ];then
        email=$(echo "root@localhost")
    fi

    binary=$(grep 'mutt =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which mutt)
    fi
    if [ -f "$binary" ];then
        echo "Sending email..."
        cat ${tmpfile} | mutt -s "${title}" "${email}"
    else
        echo "Mutt not found in order to send email!"
    fi

    rm ${tmpfile}
}


##############################################################################
# Are we sourced?
# From http://stackoverflow.com/questions/2683279/ddg#34642589
##############################################################################

# Try to execute a `return` statement,
# but do it in a sub-shell and catch the results.
# If this script isn't sourced, that will raise an error.
$(return >/dev/null 2>&1)

# What exit code did that give?
if [ "$?" -eq "0" ];then
    echo "[info] Function ready to go."
    OUTPUT=0
else
    OUTPUT=1
    if [ "$#" = 0 ];then
        echo -e "Please call this as a function or with \nthe url as the first argument and optional \ndescription as the second."
    else
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2"
        fi
        email_send
    fi
fi


