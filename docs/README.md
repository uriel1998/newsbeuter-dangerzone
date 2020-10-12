# dangerzone!
### (officially *newsbeuter-dangerzone* )

Enhanced, modular, bookmarking for newsboat, newsbeuter, or (for that matter) 
anything that can pass a title and an URL to a program.

![dangerzone logo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/dangerzone-open-graph.png "logo")  

![demo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/docs/demo.gif "demo")  

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 6. [Services Setup](#5-services-setup)
 7. [Content Warning](#9-advanced-content-warning)
 8. [Usage](#10-usage)
 9. [Other Files](#11-other-files)
 10. [TODO](#12-todo)

***

## 1. About

### Credit

`dangerzone` (previously called `newsbeuter-dangerzone`, though it's still in 
that repo) is a modular bookmarking script for the [newsboat](https://newsboat.org/) and [newsbeuter](https://www.newsbeuter.org/) 
RSS readers, but will work with anything that can spit out a string and an URL.

It can also *deobfuscate* incoming links and optionally shorten outgoing links.

This uses (and even relies somewhat) on the ini file format used by [agaetr](https://github.com/uriel1998/agaetr), 
primarily for content warnings (for Mastodon) and for API keys, it also uses 
the url deobfuscating from [agaetr](https://github.com/uriel1998/agaetr) and [muna](https://github.com/uriel1998/muna).

The urlportal script is modified from [gotbletu](https://github.com/gotbletu/shownotes/blob/master/urlportal.sh)'s 
script, see below.

The modular structure is specifically designed so that it should be easy to 
create a new module for additional services, as it relies on other programs 
to actually do the thing. Therefore, if one posting tool dies, another can be 
found and (relatively) easily swapped in without changing your whole setup.

`dangerzone` is an anglicization of, well, *dangerzone*.  (Nah, I took a GitHub 
suggested repository name and it's too late to change it now.)

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

You will also need:

* [fzf](https://github.com/junegunn/fzf)

and one of the following (or something else that is sending URLs to `dangerzone`):

* [newsboat](https://newsboat.org/)
* [newsbeuter](https://www.newsbeuter.org/) 

You will (obviously) need the bookmarking apps; I've put together several already 
(that I use); obviously you can use your own. See [Services Setup](#5-services-setup) for details.

## 4. Installation

Download or clone the repository, and put the uncompressed files in a location 
of your choice. Change into that directory.

* Edit `bookmark.sh` line 18 so that it matches where you put the files:

`export SCRIPT_DIR="$HOME/.newsboat"`

* If using `newsboat` or `newsbeuter`, edit your `config` file with bookmark-cmd 
set to the path where you put the files:

`# -- Bookmarks ---------------------------------------------------------`  
`bookmark-cmd "~/.newsboat/bookmark.sh"`  
`bookmark-interactive yes`  
`bookmark-autopilot no`  

Any service you would like to use needs to have a symlink made from the "avail" 
directory to the "enabled" directory. For example:

`ln -s $PWD/short_avail/yourls.sh $PWD/short_enabled/yourls.sh`

You may use as many "out" options as you care to; choose 0 or 1 shortening 
services.

### The INI file

Using the INI file is optional *if* all of your binary files are on your $PATH 
or hand-edited in *and* you have no use for content warnings.

I'm adding value to the agaetr.ini file, the format is the same.  The example 
shows the possible options.  You can leave the unused entries blank without 
any difficulty (unless you're using `agaetr`, which it should work with 
seamlessly).  The [Feed] sections are completely ignored with `dangerzone`.

After editing `agaetr.ini`:
 
* `mkdir -p $HOME/.config/agaetr`
* `cp $PWD/agaetr.ini $HOME/.config/agaetr`


## 5. Services Setup

The services are left unbackgrounded here for maximum compatibility. And most 
(except for `cutycapt` or the one that saves all the HTML) only take a second.

### Services Not Covered Here

One of the reason there are multiple different example service wrappers 
(and that they are written in pretty straightforward BASH scripting) 
is so that future users (including myself) can use them as templates or 
examples for other tools or new services with as little fuss as possible 
and without requiring a great deal of knowledge on the part of the user. 

If you create one for another service, please contact me so I can merge it in 
(this repository is mirrored multiple places).


### Shorteners

#### murls (shortener)  

Murls is a free service and does not require an API key. 

#### YOURLS (shortener)  

Go to your already functional YOURLS instance.  Get the API key from 
Place the URL of your instance and API key into `agaetr.ini`.  

`yourls_api =`  
`yourls_site =`  

### Bookmarking Helpers

#### Twitter via Oysttyer (output)  

Posts the title and URL to Twitter using Oysttyer.

Install and set up [oysttyer](https://github.com/oysttyer/oysttyer). Place the 
location of the binary into `agaetr.ini` or into your $PATH.   

### Shaarli (output)

Saves the URL to your Shaarli instance.

Install and set up the [Shaarli-Client](https://github.com/shaarli/python-shaarli-client). 
Make sure you set up the configuration file for the client properly. Place the 
location of the binary into `agaetr.ini` or into your $PATH.

#### Wallabag (output)

Saves the article to a Wallabag instance.

Install and set up [Wallabag-cli](https://github.com/Nepochal/wallabag-cli). 
Place the location of the binary into `agaetr.ini` or into your $PATH.
Note that shorteners and wallabag don't get along all the time.

**NOTE: Wallabag-cli after 0.5.0 doesn't work for me...**

#### todo.txt (output)  

Install and set up [Todo-txt](http://todotxt.org/).  It will add a task made up 
of the title and the URL.

#### Send to email (output)  

*DO NOT BACKGROUND THIS ONE*

Uses [mutt](http://www.mutt.org/) for sending the email, and if it finds my 
[pplsearch](https://github.com/uriel1998/ppl_virdirsyncer_addysearch) address book 
helper.  Otherwise sends to the email address specified on line 12 of the script.

It will also attach the body of the article as plain text.  There are three ways 
demonstrated in the script (lines 21-28) itself - using lynx, using pandoc, and 
a horribly convoluted bespoke filter which uses [hxclean and hxnormalize and hxunent](https://packages.debian.org/jessie/html-xml-utils) from html-xml-utils, [htmltidy](https://htmltidy.net/), [iconv](https://en.wikipedia.org/wiki/Iconv), and sed.

The default is to use `lynx`.  

#### GUI browser (output)  

Uses XDG-OPEN; no configuration should be needed.

#### Capture to JPG/PNG/PDF (output)  

Utilizes [cutycapt](http://cutycapt.sourceforge.net/), if [detox](http://detox.sourceforge.net/) is in 
$PATH, it will be used to sanitize the title string for use as a filename. Saves 
in the $HOME directory.

#### Save to Surfraw / Elinks Bookmark file (output)  

Examples to show the different paths; this is essentially the "default" bookmarking 
behavior of newsbeuter/newsboat.  They have almost identical formats.

#### Submit to the Wayback Machine (output)  

While there is an official client, I wrote this using curl calls and [API Keys](https://archive.org/account/s3.php). 
You need an account there to get your own API keys.  Place them into `agaeter.ini`.

#### Mastodon via toot (output)  

Install and set up [toot](https://github.com/ihabunek/toot/).  Place the 
location of the binary into `agaetr.ini`.

## 9. Content Warning

Currently, content warnings are only used with Mastodon. If you do not wish 
to have automatic content warnings, remove the [CW##] sections of `agaetr.ini`.

If you need ideas for what tags/terms make good content warnings, the file 
`cwlist.txt` is included for your convenience. 

Because of how matching is performed, a filter of "abuse" should catch "child 
abuse" and "sexual abuse", etc. However, it matches whole words, so "war" 
should *not* catch "bloatware" or "warframe".

The content warning system is configured in the `agaetr.ini` as well:

```
[CW9]
keyword = social-media
matches = facebook twitter mastodon social-media online
```

The number after `[CW` does not matter as long as they are not duplicated.
The "keyword" is what is outputted as the content warning, the space-separated 
line after matches is what strings will trigger that keyword as a content 
warning.   

### The keyword should **NOT** be a potentially sensitive word itself.

## 10. Usage

Inside newsbeuter/newsboat, press Ctrl-B (by default) to bring up the bookmarking 
options - it will prompt you with (pre-filled when possible) URL, title, 
description, and feed. Anything you add into the "description" string will be 
added to the title string.

You will then have a `fzf` created interface with all the enabled "out" options 
available to you. Choose as many or few as you like (press TAB to multi-select).

![demo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/docs/demo.gif "demo")  

The individual modules are written so that they may be sourced by your other 
scripts as well. The function called is [filename]_send, so inside `pdf_capture` 
the function is `pdf_capture_send` Pertinent variables are "${title}" and "${link}" .

## 11. Other files

There are other files in this repository:

* `unredirector.sh` - Used by `agaetr` to remove redirections and shortening. 
Exactly the same as [muna](https://github.com/uriel1998/muna).  

* `urlportal.sh` - I use this as my "browser" helper. Originally from [Gotbletu](https://github.com/gotbletu/shownotes/blob/master/urlportal.sh), 
I added a few things:

* Proper running of GUI image viewers
* -g switch to use GUI instead of CLI
* -c switch to use CLI instead of GUI
* Configurable default of the above
* Switched references to rtv to tuir

* `renderer.sh` - I use this for rendering articles in `newsboat`. It's the funky 
bespoke method I mention above about sending mail.

## 12. TODO

