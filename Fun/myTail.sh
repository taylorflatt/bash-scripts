#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# A basic rewrite of the tail command. It prints the last 10 lines of a file (mimics that of tail).
#
# Usage: ./myTail.sh

if [[ $# -ne 1 ]]; then
	echo "You must input a file"
	exit 1
fi

if [[ ! -e $1 ]]; then
	echo "That file doesn't exist!"
	exit 1
fi

file=$1

# Number of lines in the file.
endLine=$(cat $file | wc -l)
startLine=$((endLine - 10))","
endLine=$endLine"p"

# Jump to ((numLines-10)).
echo "Get lines variable with sed"
lines=$(sed -n "$startLine$endLine" < file)

echo "$lines"

exit 0
