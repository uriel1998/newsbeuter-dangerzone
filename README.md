newsbeuter-dangerzone
=====================

THIS IS BEING COMPLETELY REWORKED.  

NOTE:  This is meant to be a template for you to model your own solution off of. 

Newsbeuter seems to be one of the quicker and more flexible console-based newsreaders out there.  With Google Reader going away, my RSS reading falls into three categories:

1.  Stuff to read at length later.
2.  Stuff to quickly read and share.
3.  LOLCats.

The first two are fairly easily dealt with through newsbeuter itself and its bookmarking application.  Hit control-B, then for the description type twitter, pocket, and so on.  The bash script will shorten titles (and URLs) when needed.

If you want to use bit.ly, modify the bitly.py script at https://gist.github.com/uriel1998/3310028 to only output an URL.

For twitter, I use ttytter, a nice perl script that you can find at http://www.floodgap.com/software/ttytter/ .  It does a great job of sending simple text updates.

The other services are simply using Mutt ( http://go2linux.garron.me/linux/2010/10/how-send-email-command-line-gmail-mutt-789 ) to send e-mail to Pocket ( http://help.getpocket.com/customer/portal/articles/482759 )  and Buffer ( http://bufferapp.com/guides/email ).  Works great, no need for heavy OAuth APIs for something this simple.  Best of all, if you've got a decent linux machine, you can DO THIS OFFLINE and the mail just sits in the mailqueue until you get a chance to get back on.

The third... well, none of the linux readers works well.  I share LOLCats to my hard drive long enough to share with my girlfriend (hi honey!).  So I created a macro that saves those posts to a text file.

macro o set external-url-viewer "dehtml >> ~/imagetemp/imglinks.txt" ; show-urls ; next-unread ; set external-url-viewer "urlview"

Dehtml is available here: http://www.moria.de/~michael/dehtml/

Then I use the script in question to strip out the image links (with jpg/jpeg/gif/png extensions) and wget ( https://www.gnu.org/software/wget/ )to download them.  BDOW.

# NOTE: DO NOT MAKE THE MAIL ONE BACKGROUNDED - it needs input or put only a static address

#NOTE: Wallabag-cli after 0.5.0 doesn't work for me...

Use a really funky pipe instead of just pandoc, but it looks better to me.  Used in renderer and in mailto
wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | hxclean | hxnormalize -e -L -s 2>/dev/null | tidy -quiet -omit -clean 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | sed -e 's/\(<em>\|<i>\|<\/em>\|<\/i>\)/&🞵/g' | sed -e 's/\(<strong>\|<b>\|<\/strong>\|<\/b>\)/&🞶/g' |lynx -dump -stdin -display_charset UTF-8 -width 140 | sed -e 's/\*/•/g' | sed -e 's/Θ/🞵/g' | sed -e 's/Φ/🞯/g' >> ${tmpfile}
