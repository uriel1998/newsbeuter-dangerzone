#!/bin/bash

##############################################################################
#
#  sending script
#  (c) Steven Saus 2022
#  Licensed under the MIT license
# use as output for bookmark program
# to create RSS feed of items (for publication, agaeter, etc)
# 
#https://stackoverflow.com/questions/12827343/linux-send-stdout-of-command-to-an-rss-feed
#
##############################################################################

RSSSavePath="$HOME/documents/output.xml"



function rss_gen {

if [ ! -f "${RSSSavePath}" ];then
    printf '<?xml version="1.0" encoding="utf-8"?>\n' > "${RSSSavePath}"
    printf '<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">\n' >> "${RSSSavePath}"
    printf '  <channel>\n' >> "${RSSSavePath}"
    printf '    <title>My RSS Feed</title>\n' >> "${RSSSavePath}"
    printf '    <description>This is my RSS Feed</description>\n' >> "${RSSSavePath}"
    printf '  </channel>\n' >> "${RSSSavePath}"
    printf '</rss>\n' >> "${RSSSavePath}"    

    TITLE="${title}"
    LINK="${link}"
    DATE="`date`"
    DESC="${title}"
    GUID="${link}" 

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
        rss_gen
    fi
fi
