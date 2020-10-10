#!/bin/sh

##############################################################################
#
#  My renderer for newsboat/newsbeuter
#  (c) Steven Saus 2020
#  Licensed under the MIT license
#
##############################################################################

TempDir=$(mktemp -d)
ArticleFile="$TempDir/Article.html"
OutFile="$TempDir/OutFile.html"

while IFS= read -r line; do
  printf '%s\n' "$line" >> $ArticleFile
done

cat $ArticleFile | sed -e 's/<img[^>]*>//g' | sed -e 's/<div[^>]*>//g' | hxclean | hxnormalize -e -L -s 2>/dev/null | tidy -quiet -omit -clean 2>/dev/null | hxunent | iconv -t utf-8//TRANSLIT - | sed -e 's/\(<em>\|<i>\|<\/em>\|<\/i>\)/&🞵/g' | sed -e 's/\(<strong>\|<b>\|<\/strong>\|<\/b>\)/&🞶/g' |lynx -dump -stdin -display_charset UTF-8 -width 140 | sed -e 's/\*/•/g' | sed -e 's/Θ/🞵/g' | sed -e 's/Φ/🞯/g' | sed 's/^/
\t/'

echo "."

echo "##################################################################################################################################"

rm $OutFile
rm $ArticleFile
rmdir $TempDir
