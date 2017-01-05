#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# A script that creates the .desktop files and populates them with the set data.
#
# Note: This script must be run with sudo to copy/modify the files properly.
#
# Usage: ./install_desktop_icons.sh

# Create path variables.
remotePath="/usr/share/applications/"			# Remote wd for *.desktop and icons.
localIconDir="$(pwd)""/icons"					# Local icon directory.
localLauncherDir="launcher_desktop/"			# Local launcher directory for *.desktop.
localNonLauncherDir="nonlauncher_desktop/"		# Local non-launcher directory for *.desktop.
remoteIconPath="${remotePath}Icons/48x48"		# Remove icon directory.
scriptName=										# How the script is being called.
copy=0											# Bool to check if ANY files were copied.

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

function print_usage()
{
	escalated=$1
	if [[ $escalated -eq 1 ]]; then
		echo ""
		echo "Usage: $0 "; echo ""
		echo ${RED}"This program must be run as sudo.${END_COLOR} Not doing so would result in the"
		echo "icons and *.desktop files being unable to copy. Please run as sudo."
		echo ""
	else
		echo ""
		echo "Usage: $0 "; echo ""
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

# Declare the arrays.
declare -a programPaths
declare -a programData

# Get the current script's path/name. Depends upon how it was called.
if [[ ${BASH_SOURCE[0]} != *"$(pwd)"* ]]; then
	# Local: Remove the ./ from the front of the path to get the name of the script.
	scriptName="${0: 2}"
else
	# Full: Remove the entire path to get the name of the script.
	scriptName=$(echo "$0" | rev | cut -d '/' -f 1 | rev)
fi

# For every file (with *.desktop) in the cwd and launcher_icon directory, 
# add it to the program paths and save its data.
for file in $localNonLauncherDir* $localLauncherDir*; do
	if [[ ! -d "$file" && "$file" != "$scriptName" && "$file" = *".desktop" ]]; then
		if [[ "$file" = *"$localLauncherDir"* ]]; then
			programPaths+=("${remotePath}${file##*/}")
		else
			programPaths+=("${remotePath}$file")
		fi
		programData+=("$(cat $file)")
	fi
done

# Copy the icons from the CWD to a new icons directory.
if mkdir -p "$remoteIconPath" &> /dev/null; then
	if ! cp -r $localIconDir/. $remoteIconPath &> /dev/null; then
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

# For every program, check if it exists. If it doesn't, create the file and 
# append the appropriate data to it and modify the permissions appropriately.
for ((index=0; index < ${#programPaths[@]}; index++)); do
	fileContents="$(cat ${programPaths[$index]} 2> /dev/null)"
	# If the file exists (and readable) and its contents are different, then replace the contents.
	if [[ -r ${programPaths[$index]} && "${programData[$index]}" != "$fileContents" ]]; then
		echo -e "${programData[$index]}" > ${programPaths[$index]}; copy=1
		echo ${programPaths[$index]}": Remote contents differ from local modifying remote file..."
	elif [[ ! -r ${programPaths[$index]} ]]; then
		echo ${programPaths[$index]}": Creating file..."
		if touch ${programPaths[$index]}; then
			echo ${programPaths[$index]}": Adding file contents..."
			echo -e "${programData[$index]}" > ${programPaths[$index]}; copy=1
			echo ${programPaths[$index]}": Changing file permissions..."
			chmod 644 ${programPaths[$index]}
		else
			echo ${RED} ${programPaths[$index]}": ERROR couldn't create file!"${END_COLOR}
			exit 1
		fi
	else
		echo ${programPaths[$index]}": Remote contents are the same as local doing nothing..."
	fi
done

if [[ $copy -eq 0 ]]; then
	echo "${GREEN}Nothing modified or added to $remotePath*.${END_COLOR}"
else
	echo "${GREEN}Completed transfer of all *.desktop and icons to $remotePath*.${END_COLOR}"
fi

exit 0
#EOF

