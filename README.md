newsbeuter-dangerzone
=====================

# agaetr

A modular system to take a list of RSS feeds, process them, and send them to 
social media with images, content warnings, and sensitive image flags when 
available. 

![agaetr logo](https://raw.githubusercontent.com/uriel1998/agaetr/master/agaetr-open-graph.png "logo")

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Services Setup](#5-services-setup)
 6. [Feeds Setup](#6-feeds-setup)
 7. [Feed Preprocessing](#7-feed-preprocessing)
 8. [Feed Options](#8-feed-options)
 9. [Advanced Content Warning](#9-advanced-content-warning)
 10. [Usage](#10-usage)
 11. [Other Files](#11-other-files)
 12. [TODO](#12-todo)

***

## 1. About

This uses (and even relies somewhat) on the ini file format used by [agaetr](https://github.com/uriel1998/agaetr), 
primarily for content warnings (for Mastodon) and for API keys.

the urlportal script is modified from https://github.com/gotbletu/shownotes/blob/master/urlportal.sh

`agaetr` can also *deobfuscate* incoming links and optionally shorten outgoing links.

This was created because pay services are expensive, and other options are 
either limited or subject to frequent bitrot.

The modular structure is specifically designed so that it should be easy to 
create a new module for additional services, as it relies on other programs 
to do most of the posting. Therefore, if one posting tool dies, another can be 
found and (relatively) easily swapped in without changing your whole setup.

`agaetr` is an anglicization of ágætr, meaning "famous".

Special thanks to Alvin Alexander's [whose post](https://alvinalexander.com/python/python-script-read-rss-feeds-database) got me on the right track.

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites

These are probably already installed or are easily available from your distro on
linux-like distros:  

* [bash](https://www.gnu.org/software/bash/)  
* [wget](https://www.gnu.org/software/wget/)  
* [awk](http://www.gnu.org/software/gawk/manual/gawk.html)  
* [grep](http://en.wikipedia.org/wiki/Grep)  
* [curl](http://en.wikipedia.org/wiki/CURL)  

You will need some variety of posting mechanism and optionally an URL 
shortening mechanism. See [Services Setup](#5-services-setup) for details.

## 4. Installation

* `mkdir -p $HOME/.config/agaetr`
* `mkdir -p $HOME/.local/agaetr`
* Edit `agaetr.ini` (see instructions below)
* `cp $PWD/agaetr.ini $HOME/.config/agaetr`

Any service you would like to use needs to have a symlink made from the "avail" 
directory to the "enabled" directory. For example:

* `ln -s $PWD/short_avail/yourls.sh $PWD/short_enabled/yourls.sh`

You may use as many "out" options as you care to; choose 0 or 1 shortening 
services.

## 5. Services Setup

### Services Not Covered Here

One of the reason there are multiple different example service wrappers 
(and that they are written in pretty straightforward BASH scripting) 
is so that future users (including myself) can use them as templates or 
examples for other tools or new services with as little fuss as possible 
and without requiring a great deal of knowledge on the part of the user. 

If you create one for another service, please contact me so I can merge it in 
(this repository is mirrored multiple places).


### Shorteners

#### murls  

Murls is a free service and does not require an API key. 

#### YOURLS  

Go to your already functional YOURLS instance.  Get the API key from 
Place the URL of your instance and API key into `agaetr.ini`.  

`yourls_api =`  
`yourls_site =`  

### Outbound parsers

* Mastodon:
* Twitter 
* Shaarli 
* Wallabag                 

#### Twitter via Oysttyer  

Install and set up [oysttyer](https://github.com/oysttyer/oysttyer). Place the 
location of the binary into `agaetr.ini`.  

While `Oysttyer` is by far the easier to set up, it does *not* allow you to 
specify the image that is tweeted.  For that, you need `twython`, below.  

### Shaarli (output)

Install and set up the [Shaarli-Client](https://github.com/shaarli/python-shaarli-client). 
Make sure you set up the configuration file for the client properly. Place the 
location of the binary into `agaetr.ini`.

#### Wallabag (output)

Install and set up [Wallabag-cli](https://github.com/Nepochal/wallabag-cli). 
Place the location of the binary into `agaetr.ini`.

Note that shorteners and wallabag don't get along all the time.

#### todo.txt

#### Send to email

#### GUI browser

#### Capture to JPG/PNG/PDF

#### Save to Surfraw / Elinks Bookmark file

#### Submit to the Wayback Machine

#### Mastodon via toot  

Install and set up [toot](https://github.com/ihabunek/toot/).  Place the 
location of the binary into `agaetr.ini`.

## 9. Content Warning

If you need ideas for what tags/terms make good content warnings, the file 
`cwlist.txt` is included for your convenience. Because of how it matches, a 
filter of "abuse" should catch "child abuse" and "sexual abuse", etc. However, 
it matches whole words, so "war" should *not* catch "bloatware" or "warframe".

The advanced content warning system is configured in the `agaetr.ini` as 
well, following a similar format to the feeds:

```
[CW9]
keyword = social-media
matches = facebook twitter mastodon social-media online
```

The "keyword" is what is outputted as the content warning, the space-separated 
line after matches is what strings will trigger that keyword as a content 
warning.  This will work on *all* feeds where `ContentWarning = yes` is 
configured. 

### The keyword should **NOT** be a potentially sensitive word itself.

## 10. Usage

^B, then fzf


## 11. Other files

There are other files in this repository:

* `unredirector.sh` - Used by `agaetr` to remove redirections and shortening.  Exactly the same as [muna](https://github.com/uriel1998/muna).  

## 12. TODO

### Roadmap:

* 1.0 - Full on installation script including venv
* 1.0 - Per feed prefix string (e.g. "Blogging: $Title")
* 1.0 - urldecode strings in titles and descriptions

### Someday/Maybe:

* test INBOUND wallabag - seems to be broken?
* In and out - Instagram? 
* Per feed output selectors (though that's gonna be a pain)
* Check that send exits cleanly if there's no articles !!
* Check parser doesn't choke if there's a newline at the end of the posts.db file
* If hashtags are in description or title, make first occurance a hashtag
* Create some kind of homespun CW for Twitter, etc
* Out posting for Facebook (pages, at least), Pleroma, Pintrest, IRC, Instagram, Internet Archive, archivebox

Yes, there is pipe-to, which is nice if that's what you want........ 


# NOTE: DO NOT MAKE THE MAIL ONE BACKGROUNDED - it needs input or put only a static address

#NOTE: Wallabag-cli after 0.5.0 doesn't work for me...

Use a really funky pipe instead of just pandoc, but it looks better to me.  Used in renderer and in mailto
wget --connect-timeout=2 --read-timeout=10 --tries=1 -e robots=off -O - "${link}" | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | hxclean | hxnormalize -e -L -s 2>/dev/null | tidy -quiet -omit -clean 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | sed -e 's/\(<em>\|<i>\|<\/em>\|<\/i>\)/&🞵/g' | sed -e 's/\(<strong>\|<b>\|<\/strong>\|<\/b>\)/&🞶/g' |lynx -dump -stdin -display_charset UTF-8 -width 140 | sed -e 's/\*/•/g' | sed -e 's/Θ/🞵/g' | sed -e 's/Φ/🞯/g' >> ${tmpfile}

Uses agaetr style content warning style INI from agaeter
https://git.faithcollapsing.com/agaetr/
