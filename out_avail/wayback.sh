

function wayback_send {

wayback_access=$(grep wayback_access "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')
wayback_secret=$(grep wayback_secret "$HOME/.config/agaetr/agaetr.ini" | sed 's/ //g' | awk -F '=' '{print $2}')

curl -X POST -H "Accept: application/json" -H "Authorization: LOW ${wayback_access}:${wayback_secret}" -d"url=${link}&capture_outlinks=1&capture_screenshot=1&skip_first_archive=1&if_not_archived_within=1d'" https://web.archive.org/save

#https://docs.google.com/document/d/1Nsv52MvSjbLb2PCpHlat0gkzw0EvtSgpKHu4mk0MnrA/edit#
}
