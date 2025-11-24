#!/bin/bash
  
##############################################################################
# muna, by Steven Saus 3 May 2022
# steven@stevesaus.com
# Licenced under the Apache License
##############################################################################  
  

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

 
function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


strip_tracking_url() {
	# because this is a bash function, it's using the variable $url as the returned
	# variable.  So there's no real "return" other than setting that var.
    local base_no_frag frag path qs cleaned_qs cleaned_url
    local orig_effective clean_effective
    local -a curl_opts

    if [ -z "${url}" ]; then
        printf 'Usage: strip_tracking_url "URL"\n' >&2
        return 1
    fi

    curl_opts=(
        --silent
        --location
        --max-time 5
        --connect-timeout 5
        --output /dev/null
        --write-out '%{url_effective}'
    )

    # Separate fragment (#...)
    case "${url}" in
        *\#*)
            frag="${url#*#}"
            base_no_frag="${url%%#*}"
            ;;
        *)
            frag=""
            base_no_frag="${url}"
            ;;
    esac

    # Separate query string (?...)
    case "${base_no_frag}" in
        *\?*)
            qs="${base_no_frag#*\?}"
            path="${base_no_frag%%\?*}"
            ;;
        *)
            qs=""
            path="${base_no_frag}"
            ;;
    esac

    # Strip known tracking parameters from query
    if [ -n "${qs}" ]; then
        cleaned_qs="$(
            printf '%s\n' "${qs}" | awk -F'&' '
                BEGIN {
                    # Extend this regexp with more tracking param names if you like
                    tracking = "^(utm_[^=]*|fbclid|gclid|dclid|mc_cid|mc_eid|igshid|pk_campaign|pk_source|pk_medium|pk_kwd|pk_cid)$"
                }
                {
                    out = ""
                    for (i = 1; i <= NF; i++) {
                        key = $i
                        sub(/=.*/, "", key)   # strip everything after =
                        if (key ~ tracking) {
                            continue
                        }
                        if (out == "") {
                            out = $i
                        } else {
                            out = out "&" $i
                        }
                    }
                    print out
                }
            '
        )"
    else
        cleaned_qs=""
    fi

    # Rebuild cleaned URL
    cleaned_url="${path}"
    if [ -n "${cleaned_qs}" ]; then
        cleaned_url="${cleaned_url}?${cleaned_qs}"
    fi
    if [ -n "${frag}" ]; then
        cleaned_url="${cleaned_url}#${frag}"
    fi

    # If nothing changed, no need to test
    if [ "${cleaned_url}" = "${url}" ]; then
        loud "[info] No change after cleaning"
    else
		loud "[info] Cleaned url to ${url}"
		url="${cleaned_url}"
	fi
}





function unredirector {
	# because this is a bash function, it's using the variable $url as the returned
	# variable.  So there's no real "return" other than setting that var.
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
        if [ "${1}" == "-q" ];then
            # backwards compatability, this is now default behavior
            shift
        fi
        if [ "${1}" == "--loud" ];then
            LOUD=1
            shift
        else
            LOUD=0
        fi
        url="${1}"
        SUCCESS=0
        strip_tracking_url
        unredirector
 
        if [ $SUCCESS -eq 0 ];then
            # If it gets here, it has to be standalone
            echo "$url"    
        else
            exit 99
        fi
    fi
fi
