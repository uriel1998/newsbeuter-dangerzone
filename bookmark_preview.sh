#!/bin/bash

printf "Title:\n%s\n\nDescription:\n%s\n\nURL:\n%s\n\nFeed:\n%s\n\n" "${1}" "${2}" "${3}" "${4}" | rich -m -a rounded -d 2,0,2,0 -y --print -W 30 -c -w 30 -
