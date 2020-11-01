#!/bin/bash

function youtube-audio_send {

    youtube-dl "$link" -x --netrc --ignore-errors --write-description --cookies /home/steven/vault/cookies.txt --no-check-certificate --embed-thumbnail --prefer-ffmpeg --no-playlist --mark-watched --continue --audio-format mp3 -o '/home/steven/downloads/mp3/%(title)s:%(uploader)s:%(upload_date)s.%(ext)s' --rate-limit 1M --restrict-filenames  
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
        youtube-audio_send
    fi
fi
