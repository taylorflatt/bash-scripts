#!/bin/bash

# Version 1.1
# Author: Taylor Flatt
# A script that creates the .desktop and icon files and populates them to $remotePath and $remoteIconPath.
# 
#
# Note: This script must be run with sudo to copy/modify the files properly.
#
# Usage: ./install_desktop_icons.sh

# Create path variables.
remotePath="/usr/share/applications/"			# Remote wd for *.desktop and icons.
remoteIconPath="${remotePath}Icons/48x48"		# Remote icon directory.

localIconDir="$(pwd)""/icons"					# Local icon directory.
localLauncherDir="launcher_desktop/"			# Local launcher directory for *.desktop.
localNonLauncherDir="nonlauncher_desktop/"		# Local non-launcher directory for *.desktop.

copy=0											# Bool to check if ANY files were copied.

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

function print_usage()
{
	escalated=$1

	echo ""
	echo "Usage: $0 "; echo ""

	if [[ $escalated -eq 1 ]]; then
		echo ${RED}"This program must be run as sudo.${END_COLOR} Not doing so would result in the"
		echo "icons and *.desktop files being unable to copy. Please run as sudo."
		echo ""
	else
		echo ${RED}"This program doesn't take any parameter inputs.${END_COLOR} It simply "
		echo "copies the desktop icons and *.desktop to $remotePath."
		echo ""
	fi
}

# No parameters accepted and the user must run this as an escalated user.
if [[ $# -ne 0 ]]; then
	print_usage 0
	exit 1
elif [[ $EUID -ne 0 ]] || [[ -z $SUDO_USER ]]; then
	print_usage 1
	exit 1
fi

# Declare the arrays. Note: that the indexes need to be matching.
declare -a remoteProgramPaths				# Path where .desktop files will be placed
declare -a localprogramData					# Data for each .desktop file.

# For every file (with *.desktop) in the cwd and launcher_icon directory, 
# add it to the program paths and save its data.
for file in $localNonLauncherDir* $localLauncherDir*; do
	if [[ ! -d "$file" && "$file" = *".desktop" ]]; then
		remoteProgramPaths+=("${remotePath}${file##*/}")
		localprogramData+=("$(cat $file)")
	fi
done

# Copy the icons from the CWD to a new icons directory.
if mkdir -p "$remoteIconPath" 2> /dev/null; then
	if ! cp -r $localIconDir/. $remoteIconPath 2> /dev/null; then
		echo ""
		echo ${RED}"Couldn't copy the contents of the local Icon's directory."${END_COLOR}
		echo "Make sure the local icons directory exists. The program is"
		echo "looking for $localIconDir . Make sure there are no typos."
		echo ""
		exit 1
	fi
else
	echo ""
	echo "Couldn't create the Icon's directory. Make sure the local icons directory exists."
	echo "The program is looking for $localIconDir . Make sure there are no typos."
	echo ""
	exit 1
fi

# For every *.desktop, check if it exists. If it doesn't exist create it, add the file contents, and 
# set permissions appropriately. If it differs then modify the existing file.
for ((index=0; index < ${#remoteProgramPaths[@]}; index++)); do
	fileContents="$(cat ${remoteProgramPaths[$index]} 2> /dev/null)"
	# If the file exists (and readable) and its contents are different, then replace the contents.
	if [[ -r ${remoteProgramPaths[$index]} && "${localprogramData[$index]}" != "$fileContents" ]]; then
		echo -e "${localprogramData[$index]}" > ${remoteProgramPaths[$index]}; copy=1
		echo ${remoteProgramPaths[$index]}": Remote contents differ from local modifying remote file..."
	elif [[ ! -r ${remoteProgramPaths[$index]} ]]; then
		echo ${remoteProgramPaths[$index]}": Creating file..."
		if touch ${remoteProgramPaths[$index]}; then
			echo ${remoteProgramPaths[$index]}": Adding file contents..."
			echo -e "${localprogramData[$index]}" > ${remoteProgramPaths[$index]}; copy=1
			echo ${remoteProgramPaths[$index]}": Changing file permissions..."
			chmod 644 ${remoteProgramPaths[$index]}
		else
			echo ${RED} ${remoteProgramPaths[$index]}": ERROR couldn't create file!"${END_COLOR}
			exit 1
		fi
	else
		echo ${remoteProgramPaths[$index]}": Remote contents are the same as local doing nothing..."
	fi
done

if [[ $copy -eq 0 ]]; then
	echo "${GREEN}Nothing modified or added to $remotePath*.${END_COLOR}"
else
	echo "${GREEN}Completed transfer of all *.desktop and icons to $remotePath*.${END_COLOR}"
fi

exit 0
#EOF

