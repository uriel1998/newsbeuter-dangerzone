#!/bin/sh

# Create a macro in your /.newsbeuter/config file
# macro o set external-url-viewer "dehtml >> ~/imagetemp/imglinks.txt" ; show-urls ; next-unread ; set external-url-viewer "urlview"
# therefore anything you type ,o (see macro support http://www.newsbeuter.org/doc/newsbeuter.html#_macro_support ) over
# has its text saved to a straight text file.  Then you run this bash script on exiting newsbeuter.

cd ~/imagetemp
if [ -f imglinks.txt ]; then
	# extracting all links with jpg or png or gif extensions....
	cat imglinks.txt | awk -F "[ \"]" '{ for (i = 1; i<=NF; i++) if ($i ~ /\.jpeg/) print $i }' >> imglinks2.txt
	cat imglinks.txt | awk -F "[ \"]" '{ for (i = 1; i<=NF; i++) if ($i ~ /\.jpg/) print $i }' >> imglinks2.txt
	cat imglinks.txt | awk -F "[ \"]" '{ for (i = 1; i<=NF; i++) if ($i ~ /\.png/) print $i }' >> imglinks2.txt
	cat imglinks.txt | awk -F "[ \"]" '{ for (i = 1; i<=NF; i++) if ($i ~ /\.gif/) print $i }' >> imglinks2.txt
	# use wget to download all those images and delete the old files.
	wget -i imglinks2.txt
	rm imglinks.txt
	rm imglinks2.txt
fi
