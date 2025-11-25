#!/bin/bash

##############################################################################
# muna, by Steven Saus 3 May 2022
# steven@stevesaus.com
# Licenced under the Apache License
##############################################################################

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"


function loud() {
    if [ "${LOUD:-0}" -eq 1 ];then
        echo "$@"
    fi
}


strip_tracking_url() {
	# because this is a bash function, it's using the variable $url as the returned
	# variable.  So there's no real "return" other than setting that var.
    local base_no_frag frag path qs cleaned_qs cleaned_url
    local orig_effective clean_effective

    if [ -z "${url}" ]; then
        printf 'Usage: strip_tracking_url "URL"\n' >&2
        return 1
    fi

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
                    tracking = "^(utm_[^=]*|fbclid|gclid|dclid|mc_cid|mc_eid|igshid|pk_campaign|pk_source|pk_medium|pk_kwd|ss_source|pk_cid)$"
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

    # Handle Squarespace / similar redirectors that embed the real URL in ?u=
    # Example:
    # https://z6h1.engage.squarespace-mail.com/r?...&u=https%3A%2F%2Fwww.example.com%2F...&...
    if printf '%s\n' "${url}" | grep -qE '[?&]u='; then
        loud "[info] Detected embedded target URL in 'u=' parameter; extracting"

        # Extract the value of the u= parameter (still URL-encoded)
        local encoded_target
        encoded_target="$(
            printf '%s\n' "${url}" \
            | sed -n 's/.*[?&]u=\([^&]*\).*/\1/p'
        )"

        if [ -n "${encoded_target}" ]; then
            # URL-decode without python/perl:
            # 1) '+' -> space
            # 2) %XX -> corresponding byte via printf '%b'
            local decoded data
            data="${encoded_target//+/ }"
            decoded="$(printf '%b' "${data//%/\\x}")"
            if [[ "${decoded}" == *http* ]];then
                loud "[info] Unwrapped redirect to ${decoded}"
                url="${decoded}"
            else
                loud "[info] Failed to decode embedded URL; leaving original URL unchanged"
            fi
        else
            loud "[info] No 'u=' parameter value found; leaving original URL unchanged"
        fi
    fi

    # switching to wget b/c reasons
    local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0"
    local headers
    headers="$(
        wget \
            --spider \
            --server-response \
            --timeout=10 \
            --max-redirect=20 \
            --no-check-certificate \
            -erobots=off \
            --no-cache \
            --user-agent="${ua}" \
            "${url}" 2>&1
    )"
    local code
    code="$(
        printf '%s\n' "${headers}" \
        | awk '/HTTP\/[0-9.]* / {print $2; exit}'
    )"
    #checks for null as well
    if [ -z "${code}" ]; then
        loud "[info] Page/server not found, trying Internet Archive"
        firsturl="${url}"
        #In the JSON the Internet Archive returns, the string
        # "archived_snapshots": {}
        # is returned if it does not exist in the Archive either.
        # swapping out for wget
        #api_ia=$(curl -s http://archive.org/wayback/available?url="$url")
        api_ia="$(
            wget \
                --quiet \
                --timeout=5 \
                --tries=1 \
                --no-check-certificate \
                -erobots=off \
                --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0" \
                -O - \
                "http://archive.org/wayback/available?url=${url}"
        )"

        NotExists="$(printf '%s\n' "${api_ia}" | grep -c -e '"archived_snapshots": {}')"
        if [ "${NotExists}" != "0" ]; then
            SUCCESS=1 #that is, not a success
            loud "[error] Web page is gone and not in Internet Archive!"
            loud "[error] For page ${firsturl}"
            unset -v "${url}"
            unset -v "${firsturl}"
        else
            loud "[info] Fetching Internet Archive version of"
            loud "[info] page ${firsturl}"
            url="$(
                printf '%s\n' "${api_ia}" \
                | awk -F 'url": "' '{print $3}' 2>/dev/null \
                | awk -F '", "' '{print $1}' \
                | awk -F '"' '{print $1}'
            )"
            unset -v firsturl
        fi
    else
        if printf '%s\n' "${code}" | grep -q -e "3[0-9][0-9]"; then
            loud "[info] HTTP ${code} redirect"
            resulturl=""
            resulturl="$(
                printf '%s\n' "${headers}" \
                | grep "^Location" \
                | tail -1 \
                | awk '{print $2}'
            )"
            if [ -z "${resulturl}" ]; then
                loud "[info] No new location found"
                resulturl="${url}"
            else
                loud "[info] New location found"
                url="${resulturl}"
                loud "[info] REprocessing ${url}"
                headers="$(curl -k -s -m 5 --location -sS --head "${url}")"
                code="$(printf '%s\n' "${headers}" | head -1 | awk '{print $2}')"
                if printf '%s\n' "${code}" | grep -q -e "3[0-9][0-9]"; then
                    loud "[info] Second redirect; passing as-is"
                fi
            fi
        fi
        if printf '%s\n' "${code}" | grep -q -e "2[0-9][0-9]"; then
            loud "[info] HTTP ${code} exists"
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
        strip_tracking_url
        if [ $SUCCESS -eq 0 ];then
            # If it gets here, it has to be standalone
            echo "$url"
        else
            exit 99
        fi
    fi
fi
