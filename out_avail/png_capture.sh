
function png_capture_send {



    #customize outpath!
    #can also make copy for jpg and png
    if [ -f $(which detox) ];then
        dttitle=$(echo "${title}" | detox --inline)
        outpath="$HOME/${dttitle}.png"
    else
        outpath="$HOME/${title}.png"
    fi
    echo "Writing to ${outpath}"
    #echo "${dttitle}"
    binary=$(grep 'cutycapt =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which cutycapt)
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s" "$link" )
        outstring=$(echo "$binary --smooth --insecure --url=\"$outstring\" --out=\"${outpath}\"")
        eval ${outstring}
    fi
}
