#!/bin/bash

# Version 1.2
# Author: Taylor Flatt
# Recursive backup script that will backup both regular files as well as 
# directories. Meant to be run as a cron script.
#
# This version only supports backing up of a single file to a directory.
#
# Usage: backup SOURCE DESTINATION -[d]

function print_usage()
{
	echo "Usage: $0 SOURCE DESTINATION [-d]"
}

# Check arguments
if [[ $# < 2 || $# > 3 ]]; then
	print_usage
	exit 1;
fi

source=$1
destination=$2

# Assign a date value if required.
if [[ $# -eq 3 ]]; then
	if [[ $3 == "-d" ]]; then
		date=`date "+-%Y-%m-%d"`
		destination="$destination$date"
	else
		print_usage
		exit 1;
	fi
fi

# Function that will copy a file from one directory to another.
# Parameter 1: A specific file that will be copied to another location.
# Parameter 2: The destination directory of the file. (Backup location).
function copy_file()
{
	local fileSource=$1
	local fileDest=$2
	
	# Create the name of the new (backup) file.
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
		echo "Error getting the proper destination path."
		exit 1;
	fi
	
	# Check if the backup directory exists. If it doesn't, create it.
	if [[ ! -d "$fileDest" ]]; then
		if ! mkdir "$fileDest" 2> /dev/null; then
			echo "Error creating the directory: $fileDest"
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
	copy_file "$source" "$destination"
fi

echo "Completed backup of file(s)."

exit 0
#EOF
