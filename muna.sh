#!/bin/bash
  
##############################################################################
# muna, by Steven Saus 3 May 2022
# steven@stevesaus.com
# Licenced under the Apache License
##############################################################################  
  

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LOUD=0
if [ "$1" == "--verbose" ];then
    shift
    LOUD=1
fi

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}

# because this is a bash function, it's using the variable $url as the returned
# variable.  So there's no real "return" other than setting that var.

function unredirector {
    #Explainer/reminder - curl will return 404 error codes *unless* you have 
    # --fail set, in which case you get the error code. That's done here so 
    # that it handles 404 and missing server exactly the same way, while 
    # letting the 300 level codes pass through normally.
    
    headers=$(curl -k -s --fail -m 5 --location -sS --head "$url")
    code=$(echo "$headers" | head -1 | awk '{print $2}')
    
    #checks for null as well
    if [ -z "$code" ];then
        if [ $LOUD -eq 1 ];then  
            loud "[info] Page/server not found, trying Internet Archive"
        fi
        firsturl="$url"
        
        #In the JSON the Internet Archive returns, the string 
        # "archived_snapshots": {}  
        # is returned if it does not exist in the Archive either.
        
        api_ia=$(curl -s http://archive.org/wayback/available?url="$url")
        NotExists=$(echo "$api_ia" | grep -c -e '"archived_snapshots": {}')
        if [ "$NotExists" != "0" ];then
            SUCCESS=1 #that is, not a success
            if [ $LOUD -eq 1 ];then  
                loud "[error] Web page is gone and not in Internet Archive!" 
                loud "[error] For page $firsturl" 
            fi
            unset -v $url
            unset -v $firsturl
        else
            if [ $LOUD -eq 1 ];then  
                loud "[info] Fetching Internet Archive version of" 
                loud "[info] page $firsturl"
            fi
            url=$(echo "$api_ia" | awk -F 'url": "' '{print $3}' 2>/dev/null | awk -F '", "' '{print $1}' | awk -F '"' '{print $1}')
            unset -v firsturl
        fi
    else
        if echo "$code" | grep -q -e "3[0-9][0-9]";then
            if [ $LOUD -eq 1 ];then  
                loud "[info] HTTP $code redirect"    
            fi
            resulturl=""
            resulturl=$(wget -T 5 -O- --server-response "$url" 2>&1 | grep "^Location" | tail -1 | awk -F ' ' '{print $2}')
            if [ -z "$resulturl" ]; then
                if [ $LOUD -eq 1 ];then  
                    loud "[info] No new location found" 
                fi
                resulturl=$(echo "$url")
            else
                if [ $LOUD -eq 1 ];then  
                    loud "[info] New location found" 
                fi
                url=$(echo "$resulturl")
                if [ $LOUD -eq 1 ];then  
                    loud "[info] REprocessing $url" 
                fi
                headers=$(curl -k -s -m 5 --location -sS --head "$url")
                code=$(echo "$headers" | head -1 | awk '{print $2}')
                if echo "$code" | grep -q -e "3[0-9][0-9]";then
                    if [ $LOUD -eq 1 ];then  
                        loud "[info] Second redirect; passing as-is" 
                    fi
                fi
            fi
        fi
        if echo "$code" | grep -q -e "2[0-9][0-9]";then
            if [ $LOUD -eq 1 ];then  
                loud "[info] HTTP $code exists" 
            fi
        fi
    fi
}

##############################################################################
# Are we sourced?
# From http://stackoverflow.com/questions/2683279/ddg#34642589
##############################################################################

# Try to execute a `return` statement,
# but do it in a sub-shell and catch the results.
# If this script isn't sourced, that will raise an error.
$(return >/dev/null 2>&1)

# What exit code did that give?
if [ "$?" -eq "0" ];then
    loud "[info] Function undirector ready to go."
else
    if [ "$#" = 0 ];then
        echo "Please call this as a function or with the url as the first argument."
        exit 99
    else
        if [ "$1" != "-q" ];then
            # backwards compatability
            url="$1"
            LOUD=0
        else
            url="$2"
            LOUD=1
        fi
        SUCCESS=0
        unredirector
        if [ $SUCCESS -eq 0 ];then
            # If it gets here, it has to be standalone
            echo "$url"    
        else
            exit 99
        fi
    fi
fi
