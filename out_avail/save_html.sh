
function save_html_send {

    #THIS IS THE BASE PATH WHERE THIS MODULE WILL SAVE COPIES
    HtmlSavePath="/home/steven/documents/html_save"

    if [ -f $(which detox) ];then
        dttitle=$(detox "${title}")}
        outpath="${HtmlSavePath}/${dttitle}"
    else
        outpath="${HtmlSavePath}/${title}"
    fi
    
    nowdir=$(echo "$PWD")
    mkdir "${outpath}"
    cd "${outpath}"

    
    binary=$(grep 'wget =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which wget)
    fi
    if [ -f "$binary" ];then
        outstring=$(echo "$binary -H --connect-timeout=2 --read-timeout=10 --tries=1 -p -k --convert-links --restrict-file-names=windows -e robots=off \"${link}\"")
        eval "${outstring}"
    fi
}
