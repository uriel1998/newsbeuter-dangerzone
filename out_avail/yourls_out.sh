#!/bin/bash

##############################################################################
#
#  shortening script
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

function yourls_out_send {
 
    yourls_api=$(grep yourls_api "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g'| awk -F '=' '{print $2}')
    yourls_site=$(grep yourls_site "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    yourls_string=$(printf "%s/yourls-api.php?signature=%s&action=shorturl&format=simple&url=%s" "$yourls_site" "$yourls_api" "$url")
    shorturl=$(wget "$yourls_string" -O- --quiet)  

    notify-send notify-send -i web-browser "${shorturl}"
    echo "${shorturl}" | xclip -i -selection primary -r 
    echo "${shorturl}" | xclip -i -selection secondary -r 
    echo "${shorturl}" | xclip -i -selection clipboard -r 
    echo "${shorturl}" | tr -d '/n' | /usr/bin/copyq write 0  - 
    /usr/bin/copyq select 0

}
