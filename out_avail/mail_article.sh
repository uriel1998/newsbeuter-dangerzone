#!/bin/bash

function mail_article_send {

    tmpfile=$(mktemp)
    tmpfile_image=$(mktemp)
    echo "${link}" > ${tmpfile}
    echo "  " >> ${tmpfile}
    wget --connect-timeout=2 --read-timeout=10 --tries=1  -e robots=off -O - "http://stevesaus.me" | pandoc --from=html --to=markdown >> ${tmpfile}
    
    if [ -f (which detox) ];then
        dttitle=$(detox "${title}")}
        outpath="$HOME/${dttitle}.jpeg"
    else
        outpath="$HOME/${title}.jpeg"
    fi
    
    #attempting jpg screenshot attachment
    binary=$(grep 'cutycapt =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which cutycapt)
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s" "$link" )
        outstring=$(echo "$binary --smooth --insecure --url=\"$outstring\" --out=${tmpfile_image}")
    eval ${outstring}
    
    # This is from https://github.com/uriel1998/ppl_virdirsyncer_addysearch
    addressbook=$(which pplsearch)
    if [ ! -f "$addressbook" ];then
        email=$($addressbook -m)
    else
        email=$(echo "STATIC.EMAIL.ADDRESS@HERE.COM")
    fi

    binary=$(grep 'mutt =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which mutt)
    fi
    if [ -f "$binary" ];then
        if [ -f "$tmpfile_image" ];then 
            mutt -s "${title}" -i ${tmpfile} -a ${tempfile_image} "${email}"
            rm ${tmpfile_image}
        else
            mutt -s "${title}" -i ${tmpfile} "${email}"
        fi
    fi

    rm ${tmpfile}
}
