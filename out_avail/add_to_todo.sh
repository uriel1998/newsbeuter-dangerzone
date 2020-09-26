#!/bin/bash

function add_to_todo_send {
    
    binary=$(which todo-txt)
    if [ -f ${binary} ];then
        outstring=$(printf "%s : %s" "$title" "$link")
        outstring=$(echo "$binary a \"$outstring\"")
        eval ${outstring}
    fi
}
