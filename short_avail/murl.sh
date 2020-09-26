#!/bin/bash

function murl_shortener {
 
murl_string=$(printf "https://murl.com/api.php?url=%s" "$url")
shorturl=$(curl -s "$murl_string")  
echo "$shorturl"
}
