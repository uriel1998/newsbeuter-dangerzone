#!/bin/bash

#bitly is updating thier API - mandatorily - in march 2020, so I'm backburnering this.

function bitly_shortener {
 
bitly_api=$(grep bitly_api "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
bitly_login=$(grep bitly_login "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
bitly_string=$(printf "-s --data \"login=%s&apiKey=%s&longUrl=%s&format=txt\"  http://api.bitly.com/v3/shorten" "$bitly_login" "$bitly_api" "$url")
short_url=$(curl "$bitly_string")

}
