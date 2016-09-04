#!/bin/bash

# Version 1.1
# Author: Taylor Flatt
# Recursive backup script that will backup both regular files as well as 
# directories. Meant to be run as a cron script.
#
# This version only supports backing up of a single file to a directory.
#
# Usage: backup

###############################################################################
# Modify these values to suit the specific backup operation.
#
# Uncomment the following line to include a date in the destination directory.
date=`date "+-%Y-%m-%d"`

# The absolute path file or directory you wish to copy.
source="/home/taylor/myDir"

# The absolute path destination of the backup.
destination="/home/taylor/backup"
#
# End Parameter modification
###############################################################################

# If the date is unset, then set to empty string.
if [[ ! -z "${date}" ]]; then
	destination="$destination$date"
fi

# If copying a directory, move into it. Else, move into the dir of the file.
#if [[ -d "$source" ]]; then
#	cd "$source"
#else
#	cd "${source%/*}"
#fi

function copy_file()
{
	local fileSource=$1
	local fileDest=$2
	
	newFile="$fileDest"/"${fileSource##*/}".bak
	
	# If the file already exists, don't copy it.
	if [[ ! -f "$newFile" ]] || ! diff "$fileSource" "$newFile" &> /dev/null; then
		if cp --force "$fileSource" "$newFile"; then
			echo "Copying $fileSource..."
		else
			echo "Error copying $fileSource"
			exit 1;
		fi
	else
		echo "Skipping file $fileSource..."
	fi
}

function copy_directory()
{
	local fileSource=$1
	local fileDest=$2
	
	local absDestDir=$(realpath "$fileDest")
	
	# Check if the backup directory exists. If it doesn't, create it.
	if [[ ! -d "$fileDest" ]]; then
		if ! mkdir "$fileDest"; then
			exit 1;
		fi
	fi
	
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
	copy_file "$source" "$destination"
fi

echo "Completed backup of file(s)."

exit 0
#EOF
