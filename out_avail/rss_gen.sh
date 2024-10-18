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

#TODO: multiple outputs?

if [ ! -d "${XDG_DATA_HOME}" ];then
    export XDG_DATA_HOME="${HOME}/.local/share"
fi

RSSSavePath="$XDG_DATA_HOME/agaetr/output.xml"



function rss_gen_send {

if [ ! -f "${RSSSavePath}" ];then
    printf '<?xml version="1.0" encoding="utf-8"?>\n' > "${RSSSavePath}"
    printf '<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">\n' >> "${RSSSavePath}"
    printf '  <channel>\n' >> "${RSSSavePath}"
    printf '    <title>My RSS Feed</title>\n' >> "${RSSSavePath}"
    printf '    <description>This is my RSS Feed</description>\n' >> "${RSSSavePath}"
    printf '    <link rel="self" href="https://stevesaus.me/output.xml" />\n' >> "${RSSSavePath}"
    printf '  </channel>\n' >> "${RSSSavePath}"
    printf '</rss>\n' >> "${RSSSavePath}"    

fi
    TITLE="${title}"
    LINK=$(printf "href=\"%s\"" "${link}")
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


https://stackoverflow.com/questions/12827343/linux-send-stdout-of-command-to-an-rss-feed

I'm looking to use a personal RSS Feed for system reporting, so I'm wondering if it's possible to create a script that sends its $1 to an RSS feed, ala self_test_command > rss_report.sh. I don't currently have an RSS feed set up, either, so what would be the easiest way to set up an RSS feed running from a Linux box?

    linuxrssstdout

Share
Improve this question
Follow
asked Oct 10, 2012 at 19:56
Suchipi's user avatar
Suchipi
77311 gold badge66 silver badges2323 bronze badges
Add a comment
2 Answers
Sorted by:
6

There is another solution using xmlstarlet:

Create an initial rss feed file feed.xml:

<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
  <channel>
    <title>My RSS Feed</title>
    <description>This is my RSS Feed</description>
  </channel>
</rss>

Create a shell script that uses xmlstarlet to add items:

#!/bin/sh

TITLE="My RSS entry"
LINK="http://example.com/entry4711"
DATE="`date`"
DESC="Good news"
GUID="http://example.com/entry4711" 

xmlstarlet ed -L   -a "//channel" -t elem -n item -v ""  \
     -s "//item[1]" -t elem -n title -v "$TITLE" \
     -s "//item[1]" -t elem -n link -v "$LINK" \
     -s "//item[1]" -t elem -n pubDate -v "$DATE" \
     -s "//item[1]" -t elem -n description -v "$DESC" \
     -s "//item[1]" -t elem -n guid -v "$GUID" \
     -d "//item[position()>10]"  feed.xml ; 

To have a generic solution one would prefer passing the parameters from the commandline of course.

The -d command ensures that the feed does not grow inifinet but has at most 10 items.
