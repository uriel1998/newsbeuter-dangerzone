#!/bin/sh


This is here for pipe-to commands, I guess? Will do more with it later.

while read line
do
  echo "$line" >> /home/steven/1.1
done < "${1:-/dev/stdin}"


# Create a macro in your /.newsbeuter/config file
# macro o set external-url-viewer "dehtml >> ~/imagetemp/imglinks.txt" ; show-urls ; next-unread ; set external-url-viewer "urlview"
# therefore anything you type ,o (see macro support http://www.newsbeuter.org/doc/newsbeuter.html#_macro_support ) over
# has its text saved to a straight text file.  Then you run this bash script on exiting newsbeuter.

