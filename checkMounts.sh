#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# A script that checks if a directory is currently mounted. If not, then it will 
# proceed to mount the directory.
# 
# Note: This script must be run with root in order to properly mount the directories.
# Note: This is designed to be running on Unraid. As such I didn't check for a sudoer.
#
# Usage: ./checkMounts.sh

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

function print_usage()
{
	escalated=$1

	echo ""
	echo "Usage: "
	echo "$ sudo $0 "; echo ""

	if [[ $escalated -eq 1 ]]; then
		echo ${RED}"This program must be run as sudo/root.${END_COLOR} Not doing so would result in a"
		echo "likely failure to successfully remount. Please run as sudo."
		echo ""
	else
		echo ${RED}"This program doesn't take any parameter inputs.${END_COLOR} It checks if a directory"
		echo "is mounted and if not, remounts it."
		echo ""
	fi
}

# No parameters accepted and the user must run this as an escalated user.
if [[ $# -ne 0 ]]; then
	print_usage 0
	exit 1
elif [[ $EUID -ne 0 ]]; then
	echo "I SEE $EUID"
	print_usage 1
	exit 1
fi

declare -a myMounts
myMounts+=("test_mount")

# Iterates through the mounts checking if they are currently mounted. If not, mount them.
for ((index=0; index < ${#myMounts[@]}; index++)); do
	dir="absolute_path_to_mount_point"
	if  mountpoint -q "${dir}"; then
		echo "${GREEN}${myMounts[$index]} has already been mounted.${END_COLOR}"
	else
		if [YOUR_MOUNT_COMMAND_GOES_HERE]; then
			echo "${GREEN}Successfully mounted ${myMounts[$index]}${END_COLOR}"
		else
			echo "${RED}ERROR: mounting ${myMounts[$index]}${END_COLOR}"
		fi
	fi
done


exit 0
#EOF

