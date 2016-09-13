#!/bin/bash

# Version 0.5
# Author: Taylor Flatt
# A prune script that will remove files in a directory who have existed for longer than 
# a specified number of days.
#
# -a: Automated flag. This will run the script without user interaction and will take 
# the safest option in deleting files. It leaves at least the newest backup file.
#
# Usage: prune -d DIRECTORY -n NUM_DAYS [-a]

function print_usage()
{
	echo "Usage: $0 -d DIRECTORY -n NUM_DAYS [-a]"
}

function print_help()
{
	echo "This script removes files from a directory that are older than a supplied number of days."
	echo "I'll fill the rest out later."
}

# Check arguments
if [[ $# < 1 || $# > 5 ]]; then
	print_usage
	exit 1;
fi

# Global variables
directory=
numDays=
automated=
newestFile=
numFiles=

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

# Parse the arguments.
while getopts ":d:n:ha" opt; do
	case $opt in
	d)
		directory=$OPTARG
		;;
	n)
		numDays=$OPTARG
		;;
	h)
		print_help
		exit 0
		;;
	a)
		automated="TRUE"
		;;
	?)
		print_usage
		exit 1	
		;;
	esac
done

# Make sure the inputs are not empty and assigned.
if [[ -z $directory ]] || [[ -z $numDays ]]; then
	print_usage
	exit 1
fi

# Make sure the input is a valid directory.
if [[ ! -d $directory ]]; then
	echo "${RED}DIRECTORY must be a real and accessible directory.${END_COLOR}"
	print_usage
	exit 1
fi

# Only want a positive integer, compare bitwise.
expr='^([1-9][0-9]?)+$'
if [[ ! $numDays =~ $expr ]]; then
	echo "${RED}NUM_DAYS must be a positive non-zero integer!${END_COLOR}"
	print_usage
	exit 1
fi

echo "Directory: $directory"
echo "Number of Days: $numDays"
echo "Automated: $automated"
echo "Newest File: $newestFile"
echo "Number of files found: $numFiles"

# Author: pjh
# Print the newest file, if any, matching the given pattern
# Example usage: newest_matching_file 'file*'
# WARNING: Files whose names begin with a dot will not be checked
function newest_matching_file()
{
    # Use ${1-} instead of $1 in case 'nounset' is set
    local -r glob_pattern=${1-}

    if (( $# != 1 )) ; then
        echo 'Usage: newest_matching_file GLOB_PATTERN' >&2
        return 1
    fi

    # To avoid printing garbage if no files match the pattern, set
    # 'nullglob' if necessary
    local -i need_to_unset_nullglob=0
    if [[ ":$BASHOPTS:" != *:nullglob:* ]] ; then
        shopt -s nullglob
        need_to_unset_nullglob=1
    fi

    for file in $glob_pattern ; do
        [[ -z $newestFile || $file -nt $newestFile ]] \
            && newestFile=$file
    done

    # To avoid unexpected behaviour elsewhere, unset nullglob if it was
    # set by this function
    (( need_to_unset_nullglob )) && shopt -u nullglob

    return 0
}

# Removes all files except the newest file as determined by the 
# newest_matching_file function.
# Note: It will NOT remove the CWD.
function keep_newest_file()
{
	if [[ $# -ne 1 ]]; then
		echo "Usage: keep_newest_file DIRECTORY"
		return 1
	fi
	
	local dir=$1
	
	# Make sure the input is a valid directory.
	if [[ ! -d $dir ]]; then
		echo "${RED}DIRECTORY must be a real and accessible directory.${END_COLOR}"
		return 1
	fi
	
	newest_matching_file '*'
	# Remove all files except for the newest file.
	for file in *; do
		if [[ "$file" == "$newestFile" ]]; then
			echo "Skipping $file since it is the newest file..."
		else
			# Don't remove the root (backup) directory.
			if [[ "$file" -eq "$dir" ]]; then
				echo "Root directory, we should skip."
				echo "Skipping $dir..."
			elif [[ -z $automated ]]; then
				if rm -ir "$file"; then		# Require interaction
					echo "Deleting file: $file"
				else
					echo "Error deleting $file..."
				fi
			else
				if rm -r "$file"; then		# No interaction
					echo "Deleting file: $file"
				else
					echo "Error deleting $file..."
				fi
			fi
		fi
	done
	
	return 0
}

# Removes files depending on user input.
# Parameter 1: The directory from which files will be removed.
# Parameter 2: The number of days from the current date in which files prior 
# to that date will be removed. 
# Parameter 3: Whether or not the script should run in an automated fashion. 
# This will suppress any user interaction and will only perform safe deletes.
#
# Usage: remove_files /home/user1/directory7/backupDir 20 
# Usage: remove_files /home/user1/directory7/backupDir 20 TRUE
#
# Note: ANY input for a third parameter will be read as an automated task. Typically 
# passing in the value set for $automated in the main script parameter works just as well.
# Note: In no case will it remove the CWD.
function remove_files()
{
	if [[ $# < 2 ]] || [[ $# > 3 ]]; then
		echo "Usage: $0 DIRECTORY DAYS [AUTOMATED]"
	fi
	
	local dir=$1
	local days=$2
	
	# Check if the script should run w/o user interaction.
	if [[ $# -eq 3 ]]; then
		local automated=$3
	fi
	
	# Make sure the input is a valid directory.
	if [[ ! -d $dir ]]; then
		echo "${RED}DIRECTORY must be a real and accessible directory.${END_COLOR}"
		return 1
	fi
	
	# Move to the backup directory.
	if ! $(cd "$dir"); then
		echo "${RED}Error changing directories to $dir ${END_COLOR}"
		return 1
	fi
	
	# This way of processing is a bit more costly but allows a safety check.
	local totalFiles=
	local date=$(date -d "$days days ago" +%s)
	
	# Check how many total files there are in the directory and find how many 
	# are candidates for removal.
	for file in *; do
		local fileLastMod=$(date -r "$file" +%s)
		
		# File is marked as needing to be removed.
		if [[ "$date" -ge "$fileLastMod" ]]; then
			((numFiles++)) 
		fi
		
		((totalFiles++))
	done
	
	# If numFiles=totalFiles, then this determines if all files in dir will be removed.
	local deleteAll=
	
	##########################
	# Problem Cases
	##########################
	# Case in which the number of files to delete is more than the files in the directory.
	if [[ numFiles > totalFiles ]]; then
		echo "{RED}Cannot delete more files than actually exist. Something went wrong.{END_COLOR}."
		exit 1
	# Case in which all files could be removed.
	elif [[ numFiles -eq totalFiles ]]; then
		if [[ -z $automated ]]; then
			local index=1
			while [ index -eq 1 ]; do
				echo -n "All files in $dir are over $days days old. Would you like to remove all but the 
				newest file from the directory? Type n to delete ALL files. Warning: ${RED}This is not recoverable: ${END_COLOR} (y/n/q (quit)):"
				read delPrompt
				
				case "$delPrompt" in
					"y")
						deleteAll="FALSE"
						index=0 	# Exit loop
						;;
					"q")
						echo "Exiting without making any changes..."
						exit 0
						;;
					"n")
						deleteAll="TRUE"
						index=0		# Exit loop
						;;
					*)
						echo "Error: Please choose an option."
						;;
				esac
			done
		else
			deleteAll="FALSE"
		fi
	fi
	
	##########################
	# Remove Files
	##########################
	if [[ -z $automated ]]; then
		if [[ "$deleteAll" == "TRUE" ]]; then
			for file in *; do
				if rm -ir "$file"; then
					echo "Deleting file: $file"
				else
					echo "Error deleting $file..."
				fi
			done
		elif [[ "$deleteAll" == "FALSE" ]]; then
			keep_newest_file "$dir"
		else											# Typical removal case.
			for file in *; do
				local fileLastMod=$(date -r "$file" +%s)
				if [[ "$date" -ge "$fileLastMod" ]]; then
					if [[ "$file" -eq "$dir" ]]; then 	# Don't remove the root (backup) directory.
						echo "Root directory, we should skip."
						echo "Skipping $dir..."
					elif rm -ir "$file"; then
						echo "Deleting file: $file"
					else
						echo "Error deleting $file..."
					fi
				fi
			done
		fi
	else
		keep_newest_file "$dir"
	fi
}

# Run the prune.
#if [[ -z "$automated" ]]; then
#	remove_files "$dir" "$days"
#else
#	remove_files "$dir" "$days" "AUTOMATE"
#fi

echo "${GREEN}Successfully removed $numFiles from $dir! ${END_COLOR}"

exit 0
#EOF
