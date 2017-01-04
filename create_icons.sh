#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# A script that creates the .desktop files and populates them with the set data.
#
# Usage: ./create_icons.sh

# Declare the two arrays.
declare -a programPaths
declare -a programData

# Create all program paths.
program1Path="/home/taylor/Icons/test1"
program2Path="/home/taylor/Icons/test2"
program3Path="/home/taylor/Icons/test3"

# Add the paths to an array.
programPaths=($program1Path $program2Path $program3Path)

# Create the file information.
program1Data="Test1"

program2Data="Test2"

program3Data="Test3"

# Note, the variables must be passed in quoted or it won't properly interpret the data.
programData=("$program1Data" "$program2Data" "$program3Data")

for ((index=0; index < ${#programPaths[@]}; index++)); do
	if [[ -r ${programPaths[$index]} ]]; then
		echo ${programPaths[$index]}": File exists. Don't do anything."
	else
		echo ${programPaths[$index]}": File does not exist. We need to create the file! Creating the file and adding the contents to the file..."
	fi
done

exit 0
#EOF-
