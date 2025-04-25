#!/bin/bash

RootDir=$(dirname $(realpath $BASH_SOURCE))

# Config File
eval $(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' $RootDir/config.json)

# Check for a file with argument switch -f
if [ "$1" == "-f" ]; then
  shift
  if [ -z "$1" ]; then
    echo "Usage: $0 -f <markdown_file>"
    exit 1
  elif [ ! -s "$1" ]; then
    echo "Error: File '$1' does not exist or is empty."
    exit 1
  fi
fi

MarkdownFilePath=$(realpath $1)
Title=$(basename $MarkdownFilePath .md)
MarkdownFilename=$(basename $MarkdownFilePath)
DestinationPath=$(dirname $(realpath $MarkdownFilePath))
MermaidFilename=$DestinationPath/$Title.mermaid.md
OutputFilename=${Title}.html
TempFilename=/tmp/${Title}.html
DestinationFile=$DestinationPath/$Title.html

printf "MERMAID: Converting %s to %s\n" $MarkdownFilename $MermaidFilename
$MmdcPath -q -i $MarkdownFilePath -o $MermaidFilename

printf "PANDOC: Converting %s to %s\n" $MermaidFilename $TempFilename
$PandocPath $MermaidFilename --from markdown --template=$RootDir/template.html --output $TempFilename --standalone --toc --toc-depth=2 --metadata title="$Title" --metadata date="$(date +%Y-%m-%d)" 

printf "FLATTEN HTML: Converting %s to %s\n" $TempFilename $DestinationFile
$PythonPath $RootDir/flattenHTML.py -i $TempFilename -o $DestinationFile

rm $TempFilename
rm $MermaidFilename
ls $DestinationPath/$Title*svg 2>/dev/null | xargs rm -f
