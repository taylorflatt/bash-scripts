#!/bin/bash

# Version 1.4
# Author: Taylor Flatt
# Recursive backup script that will backup both regular files as well as directories. 
# Meant to be run as a cron script.
#
# The -t option adds the date to the destination (root) folder if one is created. If a 
# single file is being backed up, then that file will have the date added to its name.
#
# Usage: backup SOURCE DESTINATION [-t]

function print_usage()
{
	echo "Usage: $0 -s SOURCE -d DESTINATION [-t]"
}

# Check arguments
if [[ $# < 2 || $# > 5 ]]; then
	print_usage
	exit 1;
fi

source=
destination=
date=

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

# Parse the arguments.
while getopts ":s:d:t" opt; do
	case $opt in
	s)
		source=$OPTARG
		echo "Source was set to: $OPTARG"
		;;
	d)
		destination=$OPTARG
		echo "Destination was set to: $OPTARG"
		;;
	t)
		date=`date "+-%Y-%m-%d"`
		echo "The program will use a date in the naming schema."
		;;
	?)
		print_usage
		exit 1	
		;;
	esac
done

# These options are required, error if they aren't set.
if [[ -z $source ]] || [[ -z $destination ]]; then
	print_usage
	exit 1
fi

# Set here so it isn't accidentally overwritten above.
if [[ ! -z $date ]]; then
	destination="$destination$date"
fi

# Function that will copy a file from one directory to another.
# Parameter 1: A specific file that will be copied to another location.
# Parameter 2: The destination directory of the file. (Backup location).
# Parameter 3: (Optional) If backing up a single file, then it will place the 
# date on the file if the date option is checked. Include any non-null value for 
# this behavior such as the string "Single_File".
function copy_file()
{
	local fileSource=$1
	local fileDest=$2
	
	# Create the name of the new (backup) file.
	if [[ ! -z $3 && ! -z "$date" ]]; then
		newFile="$fileDest"/"${fileSource##*/}$date".bak
	else
		newFile="$fileDest"/"${fileSource##*/}".bak
	fi
	
	# If the file already exists, don't copy it.
	if [[ ! -f "$newFile" ]] || ! diff "$fileSource" "$newFile" &> /dev/null; then
		if cp --force "$fileSource" "$newFile"; then
			echo "Copying $fileSource to $newFile..."
		else
			echo "${RED}Error copying $fileSource.${END_COLOR}"
			exit 1;
		fi
	else
		echo "Skipping file $fileSource..."
	fi
}

# Function that will copy the contents of a directory from one directory to another.
# This recursive function will iterate through each sub-directory calling copy_file()
# as needed for each file.
# Parameter 1: The source directory of the file.
# Parameter 2: The destination directory of the file. (Backup location).
function copy_directory()
{
	local fileSource=$1
	local fileDest=$2
	
	local absDestDir=$(realpath "$fileDest" 2> /dev/null)
	
	if [[ -z "$absDestDir" ]]; then
		echo "${RED}Error getting the proper destination path.${END_COLOR}"
		exit 1;
	fi
	
	# Check if the backup directory exists. If it doesn't, create it.
	if [[ ! -d "$fileDest" ]]; then
		if ! mkdir "$fileDest" 2> /dev/null; then
			echo "${RED}Error creating the directory: $fileDest${END_COLOR}"
			exit 1;
		fi
	fi
	
	# Move to the proper directory if necessary.
	cd "$fileSource"
	
	for file in .* *; do
		# If a normal file, then copy it.
		if [[ -f "$file" ]]; then
			copy_file "$file" "$fileDest"
		# If a directory, then copy it (without . and ..).
		elif [[ -d "$file" && "$file" != "." && "$file" != ".." ]]; then
			copy_directory "$file" "$absDestDir"/"$file"
		fi
	done
	
	# Reset CWD
	cd ..
}

# Copy the file(s)
if [[ -d "$source" ]]; then
	copy_directory "$source" "$destination"
else
	copy_file "$source" "$destination" "Single_File"
fi

echo "${GREEN}Completed backup of file(s).${END_COLOR}"

exit 0
#EOF
