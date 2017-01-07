#!/bin/bash

# Version 1.3
# Author: Taylor Flatt
# A script that adds the icons to the launcher for the user running this script.
#
# Note: This script cannot be run as sudo or it will not properly set the icons.
#
# Usage: ./create_launcher_icons.sh

# NOTE: This MUST be changed if launcher_desktop directory is moved. Otherwise, this will not work.
localLauncherDir="/usr/share/appbash_pinnable/launcher_desktop"		# Local launcher directory for *.desktop.

# Font colors for error messages.
RED=`tput setaf 1`
END_COLOR=`tput sgr0`

function print_usage()
{
	escalated=$1

	echo ""
	echo "Usage: $0 "; echo ""
	if [[ $escalated -eq 1 ]]; then
		
		echo "${RED}This program cannot be run as sudo.${END_COLOR}"
		echo "That would result in the icons not being set for this user properly."
		echo "Please run as non-sudo"
	else
		cwd=$(pwd)
		echo "${RED}This program doesn't take any parameter inputs.${END_COLOR}"
		echo "It simply sets the launcher icons for all *.desktop files located in"
		echo "directory: ${cwd}/launcher_desktop"
	fi
	
	echo ""
}

# No parameters accepted and the user must not run this as an escalated user.
if [[ $# -ne 0 ]]; then
	print_usage 0
	exit 1
elif [[ $EUID -eq 0 ]] || [[ -n $SUDO_USER ]]; then
	print_usage 1
	exit 1;
fi

# Declare the array.
declare -a launcherIcons			# Will contain the *.desktop(s) without paths.

# For every file (with *.desktop)  in the specical directory
if [[ -d $localLauncherDir ]]; then
	for file in $localLauncherDir/*; do
		if [[ ! -d "$file" && "$file" = *".desktop" ]]; then
			# This returns just the name without the "special/" dir attached.
			# Remove everything before file.desktop relative/path/to/file.desktop
			launcherIcons+=("${file##*/}")
		fi
	done
else
	echo ""
	echo "${RED}Could not find ${localLauncherDir}.${END_COLOR}"
	echo "Please make sure this directory exists in the same directory as this script!"
	echo ""
fi

# For each launcher *.desktop in $localLauncherDir/, add it to the launcher list.
for ((index=0; index < ${#launcherIcons[@]}; index++)); do
	fileName=${launcherIcons[$index]}

	# Retrieve ['application://ubiquity.desktop', ..., 'application://firefox.desktop']
	currentFavorites=$(gsettings get com.canonical.Unity.Launcher favorites)

	# If the file isn't current in the list of launcher icons, add it.
	if [[ ${currentFavorites} != *"$fileName"* ]]; then
		newFavorites=$(echo $currentFavorites | sed s/]/", 'application:\/\/${fileName}']"/)
		gsettings set com.canonical.Unity.Launcher favorites "${newFavorites}"
		echo "Adding ${fileName} to the list of launcher favorites."
	fi
done

# Note:	If a user were to ever mess up their gsettings for com.canonical.Unity.Launcher favorites
#	The settings can be reset (Ubuntu 16.04) with the following bash command:
#	$ gsettings reset com.canonical.Unity.Launcher favorites

exit 0
#EOF
