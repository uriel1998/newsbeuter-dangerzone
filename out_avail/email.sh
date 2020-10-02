
function email_no_attachment_send {

    tmpfile=$(mktemp)
    echo "Obtaining text of HTML"
    echo "${link}" > ${tmpfile}
    echo "  " >> ${tmpfile}
    #wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" | pandoc --from=html --to=gfm >> ${tmpfile}
    
    wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | hxclean | hxnormalize -e -L -s 2>/dev/null | tidy -quiet -omit -clean 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | sed -e 's/\(<em>\|<i>\|<\/em>\|<\/i>\)/&🞵/g' | sed -e 's/\(<strong>\|<b>\|<\/strong>\|<\/b>\)/&🞶/g' |lynx -dump -stdin -display_charset UTF-8 -width 140 | sed -e 's/\*/•/g' | sed -e 's/Θ/🞵/g' | sed -e 's/Φ/🞯/g' >> ${tmpfile}
    
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
        echo ${tmpfile} | mutt -s "${title}" "${email}"
    fi

    rm ${tmpfile}
}
