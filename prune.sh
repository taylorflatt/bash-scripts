#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# A prune script that will remove files in a directory who have existed for longer than 
# a specified number of days.
#
# -a: Automated flag. Sets default (safe) values for flags. If there is a conflict, it 
# resolves to the safest possible option.
#
# Usage: prune -d DIRECTORY -n NUM_DAYS [-a]

function print_usage()
{
	echo "Usage: $0 -d DIRECTORY -n NUM_DAYS [-a]"
}

# Check arguments
if [[ $# < 2 || $# > 5 ]]; then
	print_usage
	exit 1;
fi

directory=
numDays=
automated=

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

# Parse the arguments.
while getopts ":s:d:a" opt; do
	case $opt in
	d)
		directory=$OPTARG
		;;
	n)
		numDays=$OPTARG
		;;
	a)
		automated="TRUE"
	?)
		print_usage
		exit 1	
		;;
	esac
done

if [[ -z $directory ]] || [[ -z $numDays ]]; then
	print_usage
	exit 1
fi

function remove_files()
{
	local dir=$1
	local days=$2
	local automated=$3
	
	if ! $(cd "$dir"); then
		echo "{RED} Error changing directories to $dir{END_COLOR}"
		exit 1
	fi
	
	# This way of processing is a bit more costly but safer.
	local numFiles=
	local totalFiles=
	local date=$(date -d "$days days ago" +%s)
	
	# Check how many total files there are in the directory and find how many 
	# are candidates for removal.
	for file in dir; do
		local fileLastMod=$(date -r "$file" +%s)
		
		# File is marked as needing to be removed.
		if [[ $date -ge $fileLastMod ]]; then
			((numFiles++))
		fi
		
		((totalFiles++))
	done
	
	if [[ numFiles > totalFiles ]]; then
		echo "{RED} Cannot delete more files than actually exist. Something went wrong.{END_COLOR}."
		exit 1
	# Case in which all files could be removed.
	elif [[ numFiles -eq totalFiles ]]; then	
		# If running in non-automated mode, prompt the user for confirmation.
		if [[ -z automated ]]; then
			local index=1
			# Loop a confirmation prompt to the user to make sure this is what they would like to do.
			while [ index -eq 1 ]; do
				echo -n "All files in $dir are over $days days old. Would you like to remove them all? Warning: This is not recoverable. (Default n): (y/n/q (quit)):"
				read delPrompt
				# Remove all files.
				if [[ $delPrompt == "y" ]]; then
					find "$dir" -type f -a -ctime +"$days" -exec rm -i {} \;
					index=0 # Exit loop
				elif [[ $delPrompt == "q" ]]; then
					echo "Exiting without making any changes..."
					exit 1
				# Remove all but the newest file.
				elif [[ $delPrompt == "n" ]]; then
					index=0 # Exit loop
					# Remove all but the last one.
				fi
			done
		else
			echo "Deleting all but the newest file even though it is older than specified."
	
	else 
		find "$1" -type f -a -ctime +"$days" -exec rm -i {} \;
fi
}


exit 0
#EOF
