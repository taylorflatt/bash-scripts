#!/bin/bash

# Version 0.2
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
newestFile=

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

# Author: pjh
# Print the newest file, if any, matching the given pattern
# Example usage: newest_matching_file 'file*'
# WARNING: Files whose names begin with a dot will not be checked
function newest_matching_file()
{
    # Use ${1-} instead of $1 in case 'nounset' is set
    local -r glob_pattern=${1-}

    if (( $# != 1 )) ; then
        echo 'usage: newest_matching_file GLOB_PATTERN' >&2
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

# Author: Taylor Flatt
# Removes all files except the newest file as determined by the 
# newest_matching_file function.
# Note: It will NOT remove the CWD.
function keep_newest_file()
{
	local dir=$1
	
	# Sets the variable newestFile for comparison below.
	newest_matching_file '*'
	# Remove all files except for the newest file.
	for file in "$dir"; do
		if [[ "$file" == "$newestFile" ]]; then
			echo "Skipping $file since it is the newest file..."
		else
			# Don't remove the root (backup) directory.
			if [[ "$file" -eq "$dir" ]]; then
				echo "Root directory, we should skip."
				echo "Skipping $dir..."
			elif ! rm -r "$file"; then
				echo "Error deleting $file..."
			fi
		fi
	done
}

# Author: Taylor Flatt
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
# Note: ANY input for a third parameter will be read as an automated task.
# Note: In no case will it remove the CWD.
function remove_files()
{
	if [[ $# < 2 ]] || [[ $# > 3]]; then
		echo "Usage: $0 DIRECTORY DAYS [AUTOMATED]"
	fi
	
	local dir=$1
	local days=$2
	
	if [[ $# -eq 3 ]]; then
		local automated=$3
	fi
	
	# Move to the backup directory.
	if ! $(cd "$dir"); then
		echo "{RED} Error changing directories to $dir{END_COLOR}"
		exit 1
	fi
	
	# This way of processing is a bit more costly but allows a safety check.
	local numFiles=
	local totalFiles=
	local date=$(date -d "$days days ago" +%s)
	
	# Check how many total files there are in the directory and find how many 
	# are candidates for removal.
	for file in "$dir"; do
		local fileLastMod=$(date -r "$file" +%s)
		
		# File is marked as needing to be removed.
		if [[ "$date" -ge "$fileLastMod" ]]; then
			((numFiles++)) 
		fi
		
		((totalFiles++))
	done
	
	# Case that should never happen.
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
				echo -n "All files in $dir are over $days days old. Would you like to remove them all? Warning: {RED}This is not recoverable:{END_COLOR} (y/n/q (quit)):"
				read delPrompt
						
				# Remove all files.
				if [[ $delPrompt == "y" ]]; then
					index=0 # Exit loop
					for file in "$dir"; do
						echo "Deleting file: $file"
						if ! rm -r "$file"; then
							echo "Error deleting $file..."
						fi
					done
				# Quit the program.
				elif [[ $delPrompt == "q" ]]; then
					echo "Exiting without making any changes..."
					exit 0
				# Remove all but the newest file.
				elif [[ $delPrompt == "n" ]]; then
					index=0 # Exit loop
					keep_newest_file "$dir" # Removes all files except for the newest.
				fi
			done
		# Remove all but the newest file.
		else
			keep_newest_file "$dir" # Removes all files except for the newest.
			
	# Remove all files prior to the number of dates mentioned.
	else 
		for file in "$dir"; do
		local fileLastMod=$(date -r "$file" +%s)
		
		# File is marked as needing to be removed.
		if [[ "$date" -ge "$fileLastMod" ]]; then
			# Don't remove the root (backup) directory.
			if [[ "$file" -eq "$dir" ]]; then
				echo "Root directory, we should skip."
				echo "Skipping $dir..."
			elif ! rm -ri "$file"; then
				echo "Error deleting $file..."
			fi
		fi
	done
fi
}

exit 0
#EOF
