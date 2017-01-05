#!/bin/bash

# Version 1.1
# Author: Taylor Flatt
# A script that adds the icons to the launcher for the user running this script.
#
# Note: This script cannot be run as sudo or it will not properly set the icons.
#
# Usage: ./create_launcher_icons.sh

localLauncherDir="launcher_desktop/"		# Local launcher directory for *.desktop.

function print_usage()
{
	escalated=$1

	echo ""
	echo "Usage: $0 "; echo ""

	if [[ $escalated -eq 1 ]]; then
		echo "This program cannot be run as sudo. That would result in the"
		echo "icons not being set for this user properly. Please run as non-"
		echo "sudo"; echo ""
	else
		cwd=$(pwd)
		echo "This program doesn't take any parameter inputs. It simply "
		echo "sets the launcher icons for all *.desktop files located in"
		echo "directory: ${cwd}/${localLauncherDir}" ; echo ""
	fi
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
declare -a launcherIcons			          # Will contain the *.desktops without paths.

# Create all program paths.
localPath="/usr/share/applications/"		# Local icon directory.

# For every file (with *.desktop)  in the specical directory
for file in $localLauncherDir*; do
	if [[ ! -d "$file" && "$file" = *".desktop" ]]; then
		# This returns just the name without the "special/" dir attached.
		# Remove everything before file.desktop relative/path/to/file.desktop
		launcherIcons+=("${file##*/}")
	fi
done

# For each launcher *.desktop in $localLauncherDir, add it to the launcher list.
for ((index=0; index < ${#launcherIcons[@]}; index++)); do
	fileName=${launcherIcons[$index]}

	# Retrieve ['application://ubiquity.desktop', ..., 'application://firefox.desktop']
	currentFavorites=$(gsettings get com.canonical.Unity.Launcher favorites)

	# If the file isn't current in the list of launcher icons, add it.
	if [[ ${currentFavorites} != *"$fileName"* ]]; then
		#newFavorites=$(echo $currentFavorites | sed s/]/", 'application:\/\/${fileName}']"/)
		#gsettings set com.canonical.Unity.Launcher favorites "${newFavorites}"
		echo "File isn't in the list of launcher favorites. Add it."
	fi
done

exit 0
#EOF
