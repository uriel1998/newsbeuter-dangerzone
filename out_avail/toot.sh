#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
##############################################################################


#get install directory
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LOUD=0

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


function toot_send {

    if [ "$title" == "$link" ];then
        title=""
    fi
    
    if [ ${#link} -gt 36 ]; then 
        loud "Sending to shortener function"
        yourls_shortener
    fi
    
    binary=$(grep 'toot =' "${XDG_CONFIG_HOME}/cw-bot/${prefix}cw-bot.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    outstring=$(printf "(%s) %s - %s %s %s" "$pubtime" "$title" "$description" "$link" "$hashtags")

    #Yes, I know the URL length doesn't actually count against it.  Just 
    #reusing code here.

    if [ ${#outstring} -gt 500 ]; then
        outstring=$(printf "(%s) %s - %s %s" "$pubtime" "$title" "$description" "$link")
        if [ ${#outstring} -gt 500 ]; then
            outstring=$(printf "%s - %s %s %s" "$title" "$description" "$link")
            if [ ${#outstring} -gt 500 ]; then
                outstring=$(printf "(%s) %s %s " "$pubtime" "$title" "$link")
                if [ ${#outstring} -gt 500 ]; then
                    outstring=$(printf "%s %s" "$title" "$link")
                    if [ ${#outstring} -gt 500 ]; then
                        short_title=`echo "$title" | awk '{print substr($0,1,110)}'`
                        outstring=$(printf "%s %s" "$short_title" "$link")
                    fi
                fi
            fi
        fi
    fi

   
    # Get the image, if exists, then send the tweet
    if [ ! -z "$imgurl" ];then
        
        Outfile=$(mktemp)
        curl "$imgurl" -o "$Outfile" --max-time 60 --create-dirs -s
        loud "Image obtained, resizing."       
        if [ -f /usr/bin/convert ];then
            /usr/bin/convert -resize 800x512\! "$Outfile" "$Outfile" 
        fi
        Limgurl=$(echo "--media $Outfile")
    else
        Limgurl=""
    fi

    if [ ! -z "$cw" ];then
        #there should be commas in the cw! apply sensitive tag if there's an image
        if [ ! -z "$imgurl" ];then
            #if there is an image, and it's a CW'd post, the image should be sensitive
            cw=$(echo "--sensitive -p \"$cw\"")
        else
            cw=$(echo "-p \"$cw\"")
        fi
    else
        cw=""
    fi
    
    postme=$(printf "%s post \"%s\" %s %s -u %s --quiet" "$binary" "$outstring" "$Limgurl" "$cw" "$account_using")
    eval ${postme}
    
    if [ -f "$Outfile" ];then
        rm "$Outfile"
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
        toot_send
    fi
fi
