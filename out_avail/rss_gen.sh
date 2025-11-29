#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2025
#  Licensed under the MIT license
# use as output for bookmark program
# to create RSS feed of items (for publication, agaeter, etc)
# 
#https://stackoverflow.com/questions/12827343/linux-send-stdout-of-command-to-an-rss-feed
#
##############################################################################

#TODO: multiple outputs?

if [ ! -d "${XDG_DATA_HOME}" ];then
    export XDG_DATA_HOME="${HOME}/.local/share"
fi
inifile="${XDG_CONFIG_HOME}/agaetr/agaetr.ini"
RSSSavePath=$(grep 'rss_output_path =' "${inifile}" | sed 's/ //g' | awk -F '=' '{print $2}')
self_link=$(grep 'self_link =' "${inifile}" | sed 's/ //g' | awk -F '=' '{print $2}')
 
function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}



function rss_gen_send {

if [ ! -f "${RSSSavePath}" ];then
    loud "[info] Starting XML file"
    printf '<?xml version="1.0" encoding="utf-8"?>\n' > "${RSSSavePath}"
    printf '<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">\n' >> "${RSSSavePath}"
    printf '  <channel>\n' >> "${RSSSavePath}"
    printf '    <title>My RSS Feed</title>\n' >> "${RSSSavePath}"
    printf '    <description>This is my RSS Feed</description>\n' >> "${RSSSavePath}"
    printf '    <link rel="self" href="%s" />\n' "${self_link}" >> "${RSSSavePath}"
    printf '  </channel>\n' >> "${RSSSavePath}"
    printf '</rss>\n' >> "${RSSSavePath}"    

fi
    TITLE="${title}"
    LINK=$(printf "href=\"%s\"" "${link}")
    DATE="`date`"
    DESC=$(printf "%s\nArchive links:\n%s\n" "${description}" "${description2_html}")
    GUID="${link}" 
    loud "[info] Adding entry to RSS feed"
    xmlstarlet ed -L   -a "//channel" -t elem -n item -v ""  \
         -s "//item[1]" -t elem -n title -v "$TITLE" \
         -s "//item[1]" -t elem -n link -v "$LINK" \
         -s "//item[1]" -t elem -n pubDate -v "$DATE" \
         -s "//item[1]" -t elem -n description -v "$DESC" \
         -s "//item[1]" -t elem -n guid -v "$GUID" \
         -d "//item[position()>10]"  "${RSSSavePath}" ; 


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
    echo "[info] Function RSS generator ready to go."
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
            LOUD=0
        fi    
        link="${1}"
        if [ ! -z "$2" ];then
            title="$2"
        fi
        rss_gen
    fi
fi
