
function jpeg_capture_send {



    if [ -f (which detox) ];then
        dttitle=$(detox "${title}")}
        outpath="$HOME/${dttitle}.jpeg"
    else
        outpath="$HOME/${title}.jpeg"
    fi
    
    binary=$(grep 'cutycapt =' "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    if [ ! -f "$binary" ];then
        binary=$(which cutycapt)
    fi
    if [ -f "$binary" ];then
        outstring=$(printf "%s" "$link" )
        outstring=$(echo "$binary --smooth --insecure --url=\"$outstring\" --out=\"${outpath}\"")
    eval ${outstring}
}
