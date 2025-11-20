#!/usr/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2025
#  Licensed under the MIT license
#
##############################################################################
 

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


function tumblr_send {

    if [ "$title" == "$link" ];then
        title=""
    fi
    

    binary=$(grep 'gotumblr =' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    textfile=$(grep 'textmd =' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    picgo_binary=$(grep 'picgo =' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    workdir=$(echo  $( dirname $(realpath "${textfile}") ))
    # is it in our ini where it should be?
        
    
    
    tbn=$(grep 'TUMBLR_BLOG_NAME=' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    tck=$(grep 'TUMBLR_CONSUMER_KEY=' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    tcs=$(grep 'TUMBLR_CONSUMER_SECRET=' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    tot=$(grep 'TUMBLR_OAUTH_TOKEN=' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    tots=$(grep 'TUMBLR_OAUTH_TOKEN_SECRET=' "${XDG_CONFIG_HOME}/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
    export TUMBLR_BLOG_NAME="${tbn}"
    export TUMBLR_CONSUMER_KEY="${tck}"
    export TUMBLR_CONSUMER_SECRET="${tcs}"
    export TUMBLR_OAUTH_TOKEN="${tot}"
    export TUMBLR_OAUTH_TOKEN_SECRET="${tots}"
    
    #outstring=$(printf "(%s) %s - %s %s %s" "$pubtime" "$title" "$description" "$link" "$hashtags")
   
    # Get the image, if exists. 
    if [ ! -z "${imgurl}" ];then
        # If image is local. upload via picgo
        if [ -f "${imgurl}" ];then
            loud "[info] Image is a local file, uploading via picgo"        
            bob=$(${picgo_binary} u "${imgurl}")
            imgurl=$(echo "${bob}" | grep -e "^http")
        fi    
        # triple check that it's a url
        if [[ $imgurl == http* ]];then
            loud "[info] Image exists, and is an URL"
            Limgurl="${imgurl}"
        else
            Limgurl=""
        fi
    fi
    echo "${title}" > "${textfile}"
    if [[ $binary == *gotumblr_ss.go ]]; then
        # This is on purpose with my hacked version of gotumblr
        echo "${hashtags}" >> "${textfile}"
    fi
    echo " " >> "${textfile}"
    echo "${description}" >> "${textfile}"

    if [ "$Limgurl" != "" ];then 
        if [ "${ALT_TEXT}" != "" ];then
            printf "<img src=\"%s\" alt=\"%s\" >\n" "${Limgurl}" "${ALT_TEXT}" >> "${textfile}"
        else
            printf "<img src=\"%s\" alt=\"A decorative image automatically pulled from the post.\" >\n" "${Limgurl}" >> "${textfile}"
        fi
        echo " " >> "${textfile}"
    fi
    if [ "$link" != "" ];then 
        printf "[%s](%s)" "${title}" "${link}" >> "${textfile}"
        echo " " >> "${textfile}"
    fi
    if [ "$description2_md" != "" ];then
        echo "*** " >> "${textfile}"
        echo " " >> "${textfile}"
        echo "Archive Links:  " >> "${textfile}"
        echo "${description2_md}" >> "${textfile}"
    fi   
    
    CURR_DIR=$(pwd)
    cd "${workdir}"
    runstring=$(printf "go run %s t" "${binary}")
    eval "${runstring}"
    cd "${CURR_DIR}"
    
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
    loud "[info] Function tumblr ready to go."
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
        tumblr_send
    fi
fi
