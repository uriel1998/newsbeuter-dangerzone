#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2025
#  Licensed under the MIT license
#
##############################################################################


#enabled_out_dir, save_directory, profile, my_CONFIG_DIR
#my_CONFIG_DIR & CACHE_DIR

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


function toot_send {

    # check some config things that SHOULD be set, etc.
    if [ -n "${my_CONFIG_DIR}" ];then
        # if the variable is set and exported, they've probably set it up properly.
        ConfigFile="${my_CONFIG_DIR}/newsbeuter_dangerzone.ini"
    else
        loud "[WARN] Configuration variable not set, checking default location."
        # try to find a default quickly.
        CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/newsbeuter_dangerzone"
        # here, though, we're doublechecking.
        if [ -f "${CONFIG_DIR}/newsbeuter_dangerzone.ini" ];then
            ConfigFile="${CONFIG_DIR}/newsbeuter_dangerzone.ini"
        else
            loud "[ERROR] Configuration not found at"
            loud "[ERROR] ${CONFIG_DIR}/newsbeuter_dangerzone.ini"
            exit 97
        fi
    fi



    tempfile=$(mktemp)
    if [ "$title" == "$link" ];then
        title=""
    fi

    account_using=$(grep 'mastodon =' "${ConfigFile}" | sed 's/ //g' | awk -F '=' '{print $2}')
    binary=$(grep 'toot =' "${ConfigFile}" | sed 's/ //g' | awk -F '=' '{print $2}')
    # and this is where I find out the dude made his own crossposter.  Which, cool, but single point of failure, etc.

    # URL length (at least for one) counts for 23.  So let's fix our math and avoid shortening (and then port to agaetr)
    #Yes, I know the URL length doesn't actually count against it.  Just
    #reusing code here.
    bigstring=$(printf "(%s) %s \n\n%s \n\n%s \n%s \n\n%s" "$pubtime" "$title" "$description" "$link" "${description2}" "$hashtags")

    if [ ${#bigstring} -lt 500 ];then
        printf "(%s) %s \n\n%s \n\n%s \n%s \n\n%s" "$pubtime" "$title" "$description" "$link" "${description2}" "$hashtags" > "${tempfile}"
    else
        outstring=$(printf "(%s) %s \n\n%s \n\n%s \n\n%s" "$pubtime" "$title" "$link" "$description2" "$hashtags")
        if [ ${#outstring} -lt 500 ]; then
            printf "(%s) %s \n\n%s \n\n%s \n\n%s" "$pubtime" "$title" "$link" "$description2" "$hashtags" > "${tempfile}"
        else
            outstring=$(printf "(%s) %s \n\n%s \n\n%s" "$pubtime" "$title" "$description2" "$link")
            if [ ${#outstring} -lt 500 ]; then
                printf "(%s) %s \n\n%s \n\n%s" "$pubtime" "$title" "$description2" "$link" > "${tempfile}"
            else
                outstring=$(printf "%s \n\n%s \n\n%s" "$title" "$description2" "$link")
                if [ ${#outstring} -lt 500 ]; then
                    printf "%s \n\n%s \n\n%s" "$title" "$description2" "$link" > "${tempfile}"
                else
                    outstring=$(printf "(%s) %s \n\n%s " "$pubtime" "$title" "$link")
                    if [ ${#outstring} -lt 500 ]; then
                        printf "(%s) %s \n\n%s " "$pubtime" "$title" "$link" > "${tempfile}"
                    else
                        outstring=$(printf "%s \n\n%s" "$title" "$link")
                        if [ ${#outstring} -lt 500 ]; then
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
                Limgurl=$(printf " --media %s --description \"%s\"" "${Outfile}" "${ALT_TEXT}")
            else
                Limgurl=$(printf " --media %s --description \"An image pulled automatically from the post for decorative purposes only.\"" "${Outfile}")
            fi
        else
            Limgurl=""
        fi
    else
        Limgurl=""
    fi

    if [ ! -z "${cw}" ];then
        #there should be commas in the cw! apply sensitive tag if there's an image
        if [ ! -z "${imgurl}" ];then
            #if there is an image, and it's a CW'd post, the image should be sensitive
            cw=$(echo "--sensitive -p \"$cw\"")
        else
            cw=$(echo "-p \"$cw\"")
        fi
    else
        cw=""
    fi

    postme=$(printf "cat %s | %s post %s %s -u %s" "${tempfile}" "$binary" "${Limgurl}" "${cw}" "${account_using}")
    eval ${postme}

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
    echo "[info] Function toot ready to go."
    OUTPUT=0
else
    OUTPUT=1
    if [ "$#" = 0 ];then
        echo -e "Please call this as a function or with \nthe url as the first argument and optional \ndescription as the second."
    else
        if [ "${1}" == "--loud" ];then
            LOUD=1
            shift
        else
            if [ "$LOUD" == "" ];then
                # so it doesn't clobber exported env
                LOUD=0
            fi
        fi
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2" # These should already be cleaned.
        fi
        toot_send
    fi
fi
