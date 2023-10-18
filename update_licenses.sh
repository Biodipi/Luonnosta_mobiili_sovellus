#!/bin/bash

## the script is running in this directory
dir=$(dirname "$0")

## make sure pubspec.yaml exist in this directory
pubfile=$dir/pubspec.yaml
if test -f "$pubfile"; then
	echo ""
else 
	echo "pubspec.yaml not found. please run this script in your project directory"
	exit
fi

## create licenses output directory
out=$dir/assets/licenses/
mkdir -p "$out"

## dependencies in pubspec.yaml are between these keys:
dependencies_key="dependencies:"
dev_dependencies_key="dev_dependencies:"

declare -a arr=()
dependencies=false

while read line; do
	## check if we are reading the dependencies section
	if [[ "$line" == *"$dev_dependencies_key"* ]]; then
		dependencies=false
	elif [[ "$line" == *"$dependencies_key"* ]]; then
		dependencies=true	
	fi
	
	## add if line contains number
	if $dependencies && [[ $line =~ [0-9] ]];then
			
		## Ignore lines with comments
		if [[ "$line" == *"#"* ]]; then
			continue
		fi
	
		arrIN=(${line//:/ })
		arr=("${arr[@]}" ${arrIN[0]} )
	fi

done < "$pubfile"

## array of plugins we want to fetch licenses for
##echo ${arr[@]}

## fetch licenses for each plugin
index=0
for plugin in "${arr[@]}"
do
	index=$((index+1))

	## plugin license url
	url=https://pub.dev/packages/${plugin}/license
	
	## save url html content to a file
	file=$out${plugin}
	echo "$(curl -L -s "$url")" > "$file"
	
	## extract license from the html content
	raw="$(sed 's:^ *::g' < "${file}" | tr -d \\n)"
	extracted=$(sed 's:.*<pre>\([^<]*\)<.*:\1:' <<<"$raw")
	echo "(${index}/${#arr[@]}) ${plugin}"
	
	## escape quotes
	target="&quot;"
	replacement="\""
	extracted=$(echo "$extracted" | sed "s/$target/$replacement/g")

	## escape slashes
	target="&#47;"
	replacement="\/"
	extracted=$(echo "$extracted" | sed "s/$target/$replacement/g")

	## rewrite the file
	echo "$extracted" > "$file"
done