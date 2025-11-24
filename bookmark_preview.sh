#!/bin/bash

Instring="$@" 
Command=$(echo "$Instring" | sed 's/ (/./g' | sed 's/)//g' | sed 's/:man:/:man -Pcat:/g' | awk -F ':' '{print $2 " " $1}')
eval "$Command" 
awk -v market1="$market1" -v market2="$market2" '
       $0 ~ "^"market1{found=1;next}
       $0 ~ "^"market2{found=0}found'
       
       
       awk '/Upright Meaning Guide/{flag=1;next}/Want to continue to/{flag=0}flag'
       
       
       grep -v shadow ./cards.dat | grep -e "name:.*${cardname}" -A 21 
       
       awk -v start="${bob}" '/\'start\'/{flag=1;next}/end_card/{flag=0}flag'
       
       awk -v start="${bob}" '/{start}/{flag=1;next}/Want to continue to/{flag=0}flag'
       
       
       img2txt.py --ansi --targetAspect=0.5 --maxLen=30 ./cups01.jpg
       jp2a ./cups01.jpg --colors
       asciiart -c -w 30 ./cups04.jpg 
