#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# A prune script that will remove files in a directory who have existed for longer than 
# a specified number of days.
#
# -d, --directory: Directory in which files are subject to be pruned.
# -n, --days: Files older than this number of days are subject to be pruned.
# -a, --automated: Automated flag. This will run the script without user interaction and will take 
# the safest option in deleting files. It leaves at least the newest backup file.
#
# Note: Sudoers and the root user cannot run this script. Limit the amount of possible damage.
#
# Usage: prune -d DIRECTORY -n NUM_DAYS [-a]

# Prevent Root and Sudo
if [[ $EUID -eq 0 ]] || [[ ! -z $SUDO_USER ]]; then
	echo "This script cannot be invoked as an elevated user to prevent potentially undesired effects."
	exit 1
fi

# Displays the usage information.
function print_usage()
{
	echo "Usage: $0 -d DIRECTORY -n NUM_DAYS [-a]"
}

# Displays the help information to a user.
function print_help()
{
	print_usage
	echo "Prunes files in DIRECTORY older tha NUM_DAYS."
	echo ""
	
	echo -e "\t -d DIRECTORY, --directory \t\t Directory whose contents are subject to prune."
	echo -e "\t -n NUM_DAYS, --days \t\t Files older than this will be subject to prune."
	echo -e "\t -a, --automated \t\t\t Runs without user input and will at least keep the most recent file."
	echo ""
	
	echo "Notes:"
	echo "-When -a is not supplied, user interaction is default. User interaction requires confirmation on each removal."
	echo "-This script cannot be run as sudo or root user. This is to reduce as much undefined behavior as possible."
	echo ""
	
	echo "Examples:"
	echo -e "\t prune -d /opt/myBackup -n 20 \t Prunes files older than 20 days from the /opt/myBackup directory."
	echo -e "\t prune -d /mnt/share/backup -n 160 -a \t Prunes files older than 180 days from the /mnt/share/backup directory without user input."
	echo ""
	echo ""
	
	echo "Full documentation and source code can be found at: <www.github.com/taylorflatt/bash-scripts> under the appropriate repository."
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
numFilesDeleted=0
removedFileNames=()

# Global error variables
numFilesError=0
fileErrorNames=()

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

# Parse arguments
while :; do
	case $1 in
		-h|-\?|--help)
			print_help
			exit 0
			;;
		-d|--directory)
			echo "Setting directory"
			directory=("${2-}")
			shift
			;;
		-n|--days)
			echo "Setting days"
			numDays=("${2-}")
			shift
			;;
		-a|--automated)
			echo "Setting automated"
			automated="TRUE"
			;;
		-?*)
			echo "Error, invalid parameter $1"
			exit 1
			;;
		--)
			echo "End of parameters"
			shift
			break
			;;
		*)
			echo "Breaking loop"
			break
	esac
	
	shift
done

# Make sure the inputs are not empty and assigned.
if [[ -z $directory ]] || [[ -z $numDays ]]; then
	echo "First"
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
expr='^[1-9][0-9]*'
if [[ ! $numDays =~ $expr ]]; then
	echo "${RED}NUM_DAYS must be a positive non-zero integer!${END_COLOR}"
	print_usage
	exit 1
fi

# Author: pjh
# Print the newest file, if any, matching the given pattern
# Parameter 1: A regex pattern that will be used to match files in the cwd.
# 
# Usage: newest_matching_file PATTERN
# Example: newest_matching_file 'file*'
#
# WARNING: Files whose names begin with a dot will not be checked
function newest_matching_file()
{
	# Use ${1-} instead of $1 in case 'nounset' is set
	local -r globPattern=${1-}

	if (( $# != 1 )) ; then
		echo 'Usage: newest_matching_file GLOB_PATTERN' >&2
		return 1
	fi

    # To avoid printing garbage if no files match the pattern, set
    # 'nullglob' if necessary
    local -i unsetNullglob=0
    if [[ ":$BASHOPTS:" != *:nullglob:* ]] ; then
        shopt -s nullglob
        unsetNullglob=1
    fi

    for file in $globPattern ; do
        [[ -z $newestFile || $file -nt $newestFile ]] \
            && newestFile=$file
    done

    # To avoid unexpected behaviour elsewhere, unset nullglob if it was
    # set by this function
    (( unsetNullglob )) && shopt -u nullglob

    return 0
}

# Prompt for the user to determine if a file is to be removed.
#
# Usage: prunte_file_prompt
#
# WARNING: This will also actually remove files if the choice is to remove a file.
function prune_file_prompt()
{
	local rmChoice=
	while [[ "$rmChoice" != "y" ]] && [[ "$rmChoice" != "n" ]]; do
		echo -n "Would you like to remove $file? (y/n):"
		read rmChoice
		
		case "$rmChoice" in
			"y")
				rm -rf "$file"
				((numFilesDeleted++))
				;;
			"n")
				echo "Skipping $file..."
				;;
			*)
				echo "Error: Please choose a valid option of y or n."
				;;
		esac
	done
}

# Removes all files except the newest file as determined by the newest_matching_file function.
# Parameter 1: The directory from which files will be removed.
# 
# Usage: keep_newest_file DIRECTORY
#
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
			if [[ "$file" == "$dir" ]]; then
				echo "Root directory, we should skip."
				echo "Skipping $dir..."
			# Prune files (Interactive).
			elif [[ -z $automated ]]; then
				prune_file_prompt
			# Prune files (Non-interactive).
			else
				# Force the removal in case the file is write protected.
				if rm -rf "$file"; then
					echo "Deleting file: $file"
					((numFilesDeleted++))
				else
					echo "Error deleting $file..."
					((numFilesError++))
					fileErrorNames+=("$file")
				fi
			fi
		fi
	done
	
	return 0
}

# Prunes files depending on user input.
# Parameter 1: The directory from which files will be removed.
# Parameter 2: The number of days from the current date in which files prior 
# to that date will be removed. 
# Parameter 3: Whether or not the script should run in an automated fashion. 
# This will suppress any user interaction and will only perform safe deletes.
#
# Usage: prune_file DIRECTORY DAYS [AUTOMATED]
#
# Example: prune_files /home/user1/directory7/backupDir 20 
# Example: prune_files /home/user1/directory7/backupDir 20 TRUE
#
# Note: ANY input for a third parameter will be read as an automated task. Typically 
# passing in the value set for $automated in the main script parameter works just as well.
# Note: In no case will it remove the CWD.
function prune_files()
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
	if [[ ! -d "$dir" ]]; then
		echo "${RED}DIRECTORY must be a real and accessible directory.${END_COLOR}"
		exit 1
	fi
	
	# Move to the backup directory.
	if ! cd "$dir"; then
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
		
		echo "Found: $file"
		
		# File is marked as needing to be removed.
		if [[ "$date" -ge "$fileLastMod" ]]; then
			echo "File: $file is set to be removed."
			((numFiles++)) 
		fi
		
		((totalFiles++))
	done
	
	# If numFiles=totalFiles, then this determines if all files in dir will be removed.
	local deleteAll=
	
	# Case: Number of files to delete outnumbers the files in the directory. (Did we catch . or ..?)
	if [[ numFiles > totalFiles ]]; then
		echo "{RED}Cannot delete more files than actually exist. Something went wrong.{END_COLOR}."
		exit 1
	# Case: All files in the directory are marked for pruning. Check with the user if interactive, otherwise keep newest file.
	elif [[ numFiles -eq totalFiles ]]; then
		if [[ -z "$automated" ]]; then
			delPrompt=
			while [[ "$delPrompt" != "y" ]] && [[ "$delPrompt" != "n" ]]; do
				echo -n "All files in $dir are over $days days old. Would you like to save the NEWEST file in the directory and delete the rest? ${RED}Warning: This is not recoverable: ${END_COLOR} (y/n/q (quit)):"
				read delPrompt
				
				echo ""
				case "$delPrompt" in
					"y")
						deleteAll="FALSE"
						;;
					"q")
						echo "Exiting without making any changes..."
						exit 0
						;;
					"n")
						deleteAll="TRUE"
						;;
					*)
						echo "${RED}Error: Please choose a valid option of y or n or q.${END_COLOR}"
						echo ""
						;;
				esac
			done
		else
			deleteAll="FALSE"
		fi
	fi
	
	# Remove files (Interactive)
	if [[ -z "$automated" ]]; then
		if [[ "$deleteAll" == "TRUE" ]]; then
			for file in *; do
				prune_file_prompt
			done
		elif [[ "$deleteAll" == "FALSE" ]]; then
			keep_newest_file "$dir"
		else											# Typical removal case.
			for file in *; do
				local fileLastMod=$(date -r "$file" +%s)
				if [[ "$date" -ge "$fileLastMod" ]]; then
					# Don't remove the root (backup) directory.
					if [[ "$file" == "$dir" ]]; then 	
						echo "Root directory, we should skip."
						echo "Skipping $dir..."
					else
						prune_file_prompt
					fi
				fi
			done
		fi
	# Remove files (Non-interactive)
	else
		keep_newest_file "$dir"
	fi
}

# Prune (Non-interactive).
if [[ -z "$automated" ]]; then
	prune_files "$directory" "$numDays"
# Prune (Interactive).
else
	prune_files "$directory" "$numDays" "$automated"
fi

echo "${GREEN}Successfully removed $numFilesDeleted files from $directory! ${END_COLOR}"

# If there is an error (or more), indicate the files that failed to be removed.
if [[ $numFilesError -ne 0 ]]; then
	echo ""
	echo ""
	echo "${RED} The following $numFilesError files failed to delete:{END_COLOR}"
	printf 'Removed %s...\n' "${fileErrorNames[@]}"
fi

exit 0
#EOF
