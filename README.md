# dangerzone!

### (officially *newsbeuter-dangerzone* )

Enhanced, modular, bookmarking for newsboat, newsbeuter, or (for that matter) 
anything that can pass a title and an URL to a program...or even from clipboard!

![dangerzone logo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/dangerzone-open-graph.png "logo")  

![demo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/docs/demo.gif "demo")  

![GUI demo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/docs/gui-demo.png "GUI demo")  

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Services Setup](#5-services-setup)
 6. [Usage](#7-usage)
 7. [Other Files](#8-other-files)
 8. [TODO](#9-todo)

***

## 1. About

### Credit

`dangerzone` (previously called `newsbeuter-dangerzone`, though it's still in 
that repo) is a modular bookmarking script for the [newsboat](https://newsboat.org/) and [newsbeuter](https://www.newsbeuter.org/) 
RSS readers, but will work with anything that can spit out a string and an URL. 
It doesn't even need the string - if there is no title passed, it will determine 
one from the URL.

It can also *deobfuscate* incoming links and optionally shorten outgoing links.

This uses the ini file format used by [agaetr](https://github.com/uriel1998/agaetr), 
primarily for API keys and binary file locations; however, if your binaries are on `$PATH` 
and you export keys as environment variables, you can skip that entirely. 

It also uses the url deobfuscating from [muna](https://github.com/uriel1998/muna).

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
* [yad](https://sourceforge.net/projects/yad-dialog/) - for GUI mode
* [xclip](https://github.com/astrand/xclip) - for capturing URL on clipboard

and one of the following (or something else that is sending URLs to `dangerzone` - see the GUI mode under [usage](#7-usage)):

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
or hand-edited in, and you have exported the needed API keys to environment variables.

If you are already using `agaetr`, then just *add* the lines that do not exist. The 
example in this repo shows *only* the possible options for `dangerzone`. 

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

Some have been removed due to changes in the API that made it impractical (Facebook), and 
some (such as the one for Twitter/X) because of API issues and because I don't give a
shit about fascists.

### Shorteners

#### YOURLS (shortener)  * 

Go to your already functional YOURLS instance.  Get the API key from 
Place the URL of your instance and API key into `agaetr.ini`.  

`yourls_api =`  
`yourls_site =`  

### Bookmarking Helpers

#### GUI browser (output) 

Uses XDG-OPEN; no configuration should be needed.  *However*, there are additional 
examples to show how you can make more outputs so you can choose your GUI browser. 
One is included specifically for Firefox and for Chromium, there's also a "work 
browser" one showing an example of where I have it open a specific profile with Waterfox.

If you're looking at how to adapt this for your own use case, these are probably 
the ones to look at.

#### Save to Surfraw / Elinks Bookmark file (output)  

Examples to show the different paths; this is essentially the "default" bookmarking 
behavior of newsbeuter/newsboat.  They have almost identical formats.

#### Submit to the Wayback Machine (output)  

While there is an official client, I wrote this using curl calls and [API Keys](https://archive.org/account/s3.php). 
You need an account there to get your own API keys.  Place them into `agaeter.ini`, or export `WAYBACK_SECRET` and `WAYBACK_ACCESS` as environment variables.

#### Mastodon via toot (output)  

Install and set up [toot](https://github.com/ihabunek/toot/).  If `toot` is not in 
your `$PATH`, then you need to place the location of the binary into `agaetr.ini`.

#### todo.txt / todoman (output)  

This actually has integrations for two different todo systems, both [Todo-txt](http://todotxt.org/) and [todoman](https://github.com/pimutils/todoman), 
depending on what is available and installed. It will try `todo-txt` first. It will 
add a task made up of the title and the URL. This is a good example of where adding 
a description during the bookmark creation process is very useful.

### Shaarli (output) *

Saves the URL to your Shaarli instance.

Install and set up the [Shaarli-Client](https://github.com/shaarli/python-shaarli-client). 
Make sure you set up the configuration file for the client properly. Place the 
location of the binary into `agaetr.ini` or into your $PATH.

#### Wallabag (output)

Saves the article to a Wallabag instance.

Install and set up [Wallabag-cli](https://github.com/Nepochal/wallabag-cli). If
`wallabag` is not in your `$PATH`, then use the `agaetr.ini` to specify its location. 
Note that shorteners and wallabag don't get along all the time.



#### Send to email (output)  *

*DO NOT BACKGROUND THIS ONE*

Uses [mutt](http://www.mutt.org/) for sending the email, and if it finds my 
[pplsearch](https://github.com/uriel1998/ppl_virdirsyncer_addysearch) address book 
helper.  Otherwise sends to the email address specified on line 12 of the script.

It will also attach the body of the article as plain text.  There are three ways 
demonstrated in the script (lines 21-28) itself - using lynx, using pandoc, and 
a horribly convoluted bespoke filter which uses [hxclean and hxnormalize and hxunent](https://packages.debian.org/jessie/html-xml-utils) from html-xml-utils, [htmltidy](https://htmltidy.net/), [iconv](https://en.wikipedia.org/wiki/Iconv), and sed.

The default is to use `lynx`.  


#### Capture to JPG/PNG/PDF (output)  *

Utilizes [cutycapt](http://cutycapt.sourceforge.net/), if [detox](http://detox.sourceforge.net/) is in 
$PATH, it will be used to sanitize the title string for use as a filename. Saves 
in the $HOME directory.


#### Video/Audio via YouTube-Dl (output) *

These are examples of how `dangerzone` can be used with other programs that handle 
URLs or even as a standalone tool.

Install and set up [youtube-dl](https://youtube-dl.org/) in your $PATH. Without 
editing, these scripts save audio/video into `$HOME/Downloads/mp3` and `$HOME/Downloads/videos` 
respectively.

## 6. Usage

Inside newsbeuter/newsboat, press Ctrl-B (by default) to bring up the bookmarking 
options - it will prompt you with (pre-filled when possible) URL, title, 
description, and feed. Anything you add into the "description" string will be 
added to the title string.  *If no title string is passed, the program will 
attempt to fetch the title from the webpage.*

You will then have a `fzf` created interface with all the enabled "out" options 
available to you. Choose as many or few as you like (press TAB to multi-select).

![demo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/docs/demo.gif "demo")  

The individual modules are written so that they may be sourced by your other 
scripts as well. The function called is [filename]_send, so inside `pdf_capture` 
the function is `pdf_capture_send` Pertinent variables are "${title}" and "${link}" .

### GUI mode

Using GUI mode (and the clipboard support) will allow you to use this framework 
with any program.  If you invoke `bookmark.sh -g [URL] [TITLE]` you will be 
presented with a dialog to use any of the helper programs. 

That is only a partial solution, though. So if you simply invoke `bookmark.sh -g` 
*without* anything else, it will use `xclip` to get the URL from the clipboard, then 
present the GUI interface.  

![GUI demo](https://github.com/uriel1998/newsbeuter-dangerzone/raw/master/docs/gui-demo.png "GUI demo")  

This means that you can bind any hotkey you like to call `bookmark.sh -g` and 
have it pull the URL from your clipboard, using it as a lightweight extension that 
future updates can't break.

## 8. Other files

There are other files in this repository:

* `muna.sh` - Exactly the same as [muna](https://github.com/uriel1998/muna). Used to remove redirections and shortening. 

* `urlportal.sh` - I use this as my "browser" helper. Originally from [Gotbletu](https://github.com/gotbletu/shownotes/blob/master/urlportal.sh), 
I added a few things:

* Proper running of GUI image viewers
* -g switch to use GUI instead of CLI
* -c switch to use CLI instead of GUI
* Configurable default of the above
* Switched references to rtv to tuir
* uses [`terminal-image-cli`](https://github.com/sindresorhus/terminal-image-cli) by default instead of chafa.

* `renderer.sh` - I use this for rendering articles in `newsboat`. It's the funky 
bespoke method I mention above about sending mail.

## 9. TODO

* Test the URL for validity 
# TODO: add preview function to each of the modules for fzf --preview giving a quick explanation of what it does
# CHECK FOR THIS by checking for the preview string which will contain the path of the posters!!!!!!!!!!!!! so
# bookmarker_preview=$(ps aux | grep fzf | grep -v "grep" | grep -c ${SCRIPT_DIR}/out_enabled")
# so if that's > 0 then.... yup.
# TODO: modules for each possible browser?
# TODO: Allow calling an editor with multiselect capabilities of fzf?
# TODO: Preview current values (and allow editing of) with fzf selection screen
 # upgraded tmux to 55, so have --tmux popup!
# TODO - notify-send integration for output
