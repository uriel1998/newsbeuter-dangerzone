#!/usr/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2025
#  Licensed under the MIT license
#
##############################################################################

#export BSKYSHCLI_SELFHOSTED_DOMAIN= ##
#PATH=$PATH:/home/steven/.local/bsky_sh_cli/bin
#export PATH
#source /home/steven/.bsky_sh_cli.rc
#/home/steven/.local/bsky_sh_cli/bin/bsky login --handle ### --password #


function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


function bluesky_send {
    
    tempfile=$(mktemp)
    
    if [ "$title" == "$link" ];then
        title=""
    fi
     
    binary=$(grep 'bluesky =' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
 
    if [ "$description2" != "" ];then
        description2="Archive: ${description2}"
    fi
    bigstring=$(printf "(%s) %s \n\n%s \n\n%s \n%s \n\n%s" "$pubtime" "$title" "$description" "$link" "${description2}" "$hashtags")
    
    if [ ${#bigstring} -lt 300 ];then 
        printf "(%s) %s \n\n%s \n\n%s \n%s \n\n%s" "$pubtime" "$title" "$description" "$link" "${description2}" "$hashtags" > "${tempfile}"
    else
        outstring=$(printf "(%s) %s \n\n%s \n\n%s \n\n%s" "$pubtime" "$title" "$link" "$description2" "$hashtags")
        if [ ${#outstring} -lt 300 ]; then
            printf "(%s) %s \n\n%s \n\n%s \n\n%s" "$pubtime" "$title" "$link" "$description2" "$hashtags" > "${tempfile}"
        else
            outstring=$(printf "(%s) %s \n\n%s \n\n%s" "$pubtime" "$title" "$description2" "$link")
            if [ ${#outstring} -lt 300 ]; then
                printf "(%s) %s \n\n%s \n\n%s" "$pubtime" "$title" "$description2" "$link" > "${tempfile}"
            else
                outstring=$(printf "%s \n\n%s \n\n%s" "$title" "$description2" "$link")
                if [ ${#outstring} -lt 300 ]; then
                    printf "%s \n\n%s \n\n%s" "$title" "$description2" "$link" > "${tempfile}"
                else
                    outstring=$(printf "(%s) %s \n\n%s " "$pubtime" "$title" "$link")
                    if [ ${#outstring} -lt 300 ]; then
                        printf "(%s) %s \n\n%s " "$pubtime" "$title" "$link" > "${tempfile}"
                    else
                        outstring=$(printf "%s \n\n%s" "$title" "$link")
                        if [ ${#outstring} -lt 300 ]; then
                            printf "%s \n\n%s" "$title" "$link" > "${tempfile}"
                        else
                            short_title=`echo "$title" | awk '{print substr($0,1,110)}'`
                            printf "%s \n\n%s" "$short_title" "$link" > "${tempfile}"
                        fi
                    fi
                fi
            fi
        fi
    fi
    echo " " >> "${tempfile}"


   
    # Get the image, if exists, then send the post
    if [ ! -z "${imgurl}" ];then
        
        if [ -f "${imgurl}" ];then
            filename=$(basename -- "${imgurl}")
            extension="${filename##*.}"
            Outfile=$(mktemp --suffix=.${extension})
            cp "${imgurl}" "${Outfile}"
        else
            Outfile=$(mktemp)
            curl "${imgurl}" -o "${Outfile}" --max-time 60 --create-dirs -s
        fi
        if [ -f "${Outfile}" ];then
            loud "[info] Image obtained, resizing."       
            if [ -f /usr/bin/convert ];then
                /usr/bin/convert -resize 800x512\! "${Outfile}" "${Outfile}" 
            fi
            if [ ! -z "${ALT_TEXT}" ];then
                Limgurl=$(printf " --image \'%s\' --image-alt '%s'" "${Outfile}" "${ALT_TEXT}")
            else
                Limgurl=$(printf " --image \'%s\' --image-alt 'An automated image pulled from the post - %s'" "${Outfile}" "${title}")
            fi
        else
            Limgurl=""
        fi
    else
        Limgurl=""
    fi
  
    postme=$(printf "cat %s | %s post --stdin %s" "${tempfile}" "${binary}"  "${Limgurl}")
    loud "${postme}"
    eval "${postme}"

    
    if [ -f "${Outfile}" ];then
        rm "${Outfile}"
    fi
    if [ -f "${tempfile}" ];then
        rm "${tempfile}"
    fi
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
    echo "[info] Function bluesky ready to go."
else
    if [ "$#" = 0 ];then
        echo -e "Please call this as a function or with \nthe url as the first argument and optional \ndescription as the second."
    else
        if [ "${1}" == "--loud" ];then
            LOUD=1
            shift
        else
            LOUD=0
        fi    
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2"
        fi
        bluesky_send
    fi
fi
        
