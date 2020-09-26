#!/bin/bash

#get install directory
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ ! -f "$HOME/.config/agaetr/agaetr.ini" ];then
    echo "INI not located; betcha nothing else is set up."
    exit 89
fi
if [ ! -f "$HOME/.local/share/agaetr/posts.db" ];then
    echo "Post database not located, exiting."
    exit 99
fi

mv "$HOME/.local/share/agaetr/posts.db" "$HOME/.local/share/agaetr/posts_back.db"
tail -n +2 "$HOME/.local/share/agaetr/posts_back.db" > "$HOME/.local/share/agaetr/posts.db"
instring=$(head -1 "$HOME/.local/share/agaetr/posts_back.db")
rm "$HOME/.local/share/agaetr/posts_back.db"

#Adding string to the "posted" db

if [ -z "$instring" ];then 

    echo "Nothing to post."
    exit
fi

echo "$instring" >> "$HOME/.local/share/agaetr/posted.db"


OIFS=$IFS
IFS='|'
myarr=($(echo "$instring"))
IFS=$OIFS

#20181227091253|Bash shell find out if a variable has NULL value OR not|https://www.cyberciti.biz/faq/bash-shell-find-out-if-a-variable-has-null-value-or-not/||None|None|#bash shell #freebsd #korn shell scripting #ksh shell #linux #unix #bash shell scripting #linux shell scripting #shell script

#pulling array into named variables so they work with sourced functions

# passing published time (from dd MMM)
posttime=$(echo "${myarr[0]}")
posttime2=${posttime::-6}
pubtime=$(date -d"$posttime2" +%d\ %b)
title=$(echo "${myarr[1]}" | sed 's|["]|“|g' | sed 's|['\'']|’|g' )
link=$(echo "${myarr[2]}")
cw=$(echo "${myarr[3]}")
imgurl=$(echo "${myarr[5]}")
imgalt=$(echo "${myarr[4]}" | sed 's|["]|“|g' | sed 's|['\'']|’|g' )
hashtags=$(echo "${myarr[6]}")
description=$(echo "${myarr[7]}" | sed 's|["]|“|g' | sed 's|['\'']|’|g' )

if [ "$imgurl" = "None" ];then 
    imgurl=""
fi
if [ "$imgalt" = "None" ];then 
    imgalt=""
fi

#Checking the image url before sending it to the client
imagecheck=$(wget -q --spider $imgurl; echo $?)

if [ $imagecheck -ne 0 ];then
    echo "Image no longer available; omitting."
    imgurl=""
    imgalt=""
fi


#Deshortening, deobfuscating, and unredirecting the URL

url="$link"
source "$SCRIPT_DIR/unredirector.sh"
unredirector
link="$url"


# SHORTENING OF URL
# call first (should be only) element in shortener dir to shorten url

if [ "$(ls -A "$SCRIPT_DIR/short_enabled")" ]; then
    shortener=$(ls -lR "$SCRIPT_DIR/short_enabled" | grep ^l | awk '{print $9}')
    if [ -z "$shortener" ];then
        echo "No URL shortening performed."
    else
        if [ "$shortener" != ".keep" ];then 
            short_funct=$(echo "${shortener%.*}_shortener")
            source "$SCRIPT_DIR/short_enabled/$shortener"
            url="$link"
            echo "$SCRIPT_DIR/short_enabled/$shortener"
            eval ${short_funct}
            link="$shorturl"
            echo "$shorturl"
            echo "$link"
        fi
    fi
fi

    
# Parsing enabled out systems. Find files in out_enabled, then import 
# functions from each and running them with variables already established.

posters=$(ls -A "$SCRIPT_DIR/out_enabled")

for p in $posters;do
    if [ "$p" != ".keep" ];then 
        echo "Processing ${p%.*}..."
        send_funct=$(echo "${p%.*}_send")
        source "$SCRIPT_DIR/out_enabled/$p"
        echo "$SCRIPT_DIR/out_enabled/$p"
        eval ${send_funct}
        sleep 5
    fi
done



