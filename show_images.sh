#!/bin/sh

##############################################################################
#
#  Gettting, displaying images
#  (c) Steven Saus 2024
#  Licensed under the MIT license
#
##############################################################################

CacheDir=${XDG_CACHE_HOME:-$HOME/.local/state}
CacheFile=${CacheDir}/newsboat_img_links
TempDir=$(mktemp -d)    

if [ "$#" -gt 1 ];then 
    numlines=3
else
    numlines=$(wc -l < "${CacheFile}")
fi

notify-send "$@"

if [ ${numlines} -eq 1 ];then
    result=$(head -n 1 "${CacheFile}")
    DINFO=$(wget --spider "${result}" 2>&1)
    mimetype=$(echo "${DINFO}"|egrep -e '^Length:'|awk -F "[" '{print $2}'|awk -F "]" '{print $1}')
    mainmimetype=$(echo "${mimetype}"|awk -F "/" '{print $1}') 
    minormimetype=$(echo "${mimetype}"|awk -F "/" '{print $2}')
    curl "${result}" --output "${TempDir}/out.${minormimetype}" 
    
    if [ "${minormimetype}" != "gif" ];then 
        feh --auto-zoom --scale-down --geometry 800x600 "${TempDir}/out.${minormimetype}" 2>/dev/null &
    else
        notify-send "A${minormimetype}A"
        /usr/bin/gifview -a "${TempDir}/out.${minormimetype}" 2>/dev/null &

    fi
    ( sleep 3 && rm "${TempDir}/out.${minormimetype}" 2>/dev/null ) &
else



    bob=$(echo "💾 Save the file in $HOME/Downloads\n🛑 Quit back to Newsboat" ; cat "${CacheFile}")
    # TODO - send elsewhere? 
    # TODO - multi-view?
    # TODO - inline using jp2a or something like nnn's preview using this cachefile?
    result="shim"
    while [ "${result}" != "" ]; do
        result=$(echo "$bob" | fzf --header="choose which image you wish to see GUI-style" --preview="timg --frames=1 -g120x120 -pq {}")
        case "${result}" in
            🛑*)    result="" ;;
            💾*)    cat "${CacheFile}" | grep -e "^http" | fzf --multi --header="Choose images you want to save." --preview="timg -g120x120 --frames=1 -pq {}" | while IFS= read -r line; do    
                        datestring=$(date +%Y-%m-%d_%H.%M.%S)
                        DINFO=$(wget --spider "${line}" 2>&1)
                        mimetype=$(echo "${DINFO}"|egrep -e '^Length:'|awk -F "[" '{print $2}'|awk -F "]" '{print $1}')
                        mainmimetype=$(echo "${mimetype}"|awk -F "/" '{print $1}')
                        minormimetype=$(echo "${mimetype}"|awk -F "/" '{print $2}')
                        fileurl=$(echo "${DINFO}"|egrep -e '^--'|awk -F " " '{print $3}')
                        notify-send --icon media-floppy "Saving file!  ${HOME}/Downloads/${datestring}.${minormimetype}" 
                        curl "${line}" --output "${HOME}/Downloads/${datestring}.${minormimetype}" 
                    done 
                    ;;
              http*)    # feh does not care what the file extension is
                    encoded=$(/usr/bin/urlencode "${result}")
                    #echo "${encoded}"
                    notify-send "${result}"
                    curl "${result}" --output "${TempDir}/out.jpg" 
                    feh --auto-zoom --scale-down --geometry 800x600 "${TempDir}/out.jpg" 2>/dev/null &
                    ( sleep 3 && rm "${TempDir}/out.jpg" 2>/dev/null ) &
                    ;;
        esac
    done


fi
rmdir "${TempDir}"
