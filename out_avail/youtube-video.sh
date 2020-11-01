#!/bin/bash

function youtube-video_send {

    ionice -c 3 youtube-dl "$link" --netrc --ignore-errors --cookies /home/steven/vault/cookies.txt --write-thumbnail --mark-watched --continue  --write-description --no-playlist --no-overwrites --rate-limit 1M --restrict-filenames --no-check-certificate -o '/home/steven/downloads/videos/%(title)s-%(autonumber)s.%(ext)s'   

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
        save_to_elinks_send
    fi
fi
