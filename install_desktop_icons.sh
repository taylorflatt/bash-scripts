#!/bin/bash

# Version 1.2
# Author: Taylor Flatt
# A script that creates the .desktop and icon files and populates them to $remotePath and $remoteIconPath.
# 
# Note: This script must be run with sudo to copy/modify the files properly.
#
# Usage: sudo ./install_desktop_icons.sh

# Create path variables.
remotePath="/usr/share/applications"			# Remote working dir for *.desktop and icons.
remoteIconPath="${remotePath}/Icons/48x48"		# Remote icon directory.

localIconDir="$(pwd)""/icons"				# Local icon directory.
localLauncherDir="launcher_desktop"			# Local launcher directory for *.desktop.
localNonLauncherDir="nonlauncher_desktop"		# Local non-launcher directory for *.desktop.

copy=0							# Bool to check if ANY desktop files were copied.
iconCopied=0						# Bool to check if ANY icon files were copied.

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
		echo ${RED}"This program must be run as sudo.${END_COLOR} Not doing so would result in the"
		echo "icons and *.desktop files being unable to copy. Please run as sudo."
		echo ""
	else
		echo ${RED}"This program doesn't take any parameter inputs.${END_COLOR} It simply "
		echo "copies the desktop icons and *.desktop to $remotePath/."
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

# Declare the arrays. Note: the indexes will be matching.
declare -a remoteProgramPaths				# Remote path where .desktop files will be placed
declare -a localProgramData				# Data for each .desktop file.

# For every file (with *.desktop) in the launcher_icon directory, 
# add it to the program paths and save its data.
for file in $localNonLauncherDir/* $localLauncherDir/*; do
	if [[ ! -d "$file" && "$file" = *".desktop" ]]; then
		remoteProgramPaths+=("${remotePath}/${file##*/}")	# Add ${remotePath}/$filename
		localProgramData+=("$(cat $file)")
	fi
done

# Copy the icons from the CWD to a new icons directory.
if mkdir -p "$remoteIconPath" 2> /dev/null; then
	declare -a localIconPath
	for file in $localIconDir/*; do
		if [[ ! -d "$file" ]]; then
			if cp $file $remoteIconPath 2> /dev/null; then
				localIconPath+=($file)
				iconCopied=1
			else
				echo ""
				echo ${RED}"Couldn't copy the contents of:"
				echo "${file}"${END_COLOR}
				echo ""
				echo "Please make sure the following local icons directory exists:"
				echo "${localIconDir}"
				echo ""
				exit 1
			fi
		fi
	done
	if [[ $iconCopied -eq 0 ]]; then
		echo "No icons were copied to ${remoteIconPath}"
	else
		# Output all elements of the localIconPath array as being copied
		echo "Copied the following icons to ${remoteIconPath}"
		
		for ((index=0; index < ${#localIconPath[@]}; index++)); do
			echo "  ${localIconPath[index]}"
		done
		echo ""
	fi
	
else
	echo ""
	echo "Couldn't create the Icon's directory. Make sure the local icons directory exists."
	echo "The program is looking for $localIconDir . Make sure there are no typos."
	echo ""
	exit 1
fi

# For every *.desktop, 
# If exists in remotePath and differs then replace the existing file.
# If it doesn't exist create it, add the file contents, and set permissions appropriately.
for ((index=0; index < ${#remoteProgramPaths[@]}; index++)); do
	remoteFileContents="$(cat ${remoteProgramPaths[$index]} 2> /dev/null)"
	# If the file exists (and readable) and its contents differ, then replace the contents.
	if [[ -r ${remoteProgramPaths[$index]} && "${localProgramData[$index]}" != "$remoteFileContents" ]]; then
		echo ${remoteProgramPaths[$index]}": file differs replacing contents."
		echo -e "${localProgramData[$index]}" > ${remoteProgramPaths[$index]}; copy=1		
	# Else If the file doesn't exist create it
	elif [[ ! -e ${remoteProgramPaths[$index]} ]]; then
		echo ${remoteProgramPaths[$index]}": Creating file..."
		if touch ${remoteProgramPaths[$index]}; then
			echo ${remoteProgramPaths[$index]}": Adding file contents..."
			echo -e "${localProgramData[$index]}" > ${remoteProgramPaths[$index]}; copy=1
			echo ${remoteProgramPaths[$index]}": Changing file permissions..."
			chmod 644 ${remoteProgramPaths[$index]}
		else
			echo ${RED} ${remoteProgramPaths[$index]}": ERROR couldn't create file!"${END_COLOR}
			exit 1
		fi
	else
		echo ${remoteProgramPaths[$index]}" is up to date."
	fi
done

# Print the final message depending on what was actually done.
if [[ $copy -eq 0 && $iconCopied -eq 0 ]]; then
	echo "${GREEN}No .desktop or icons were modified or added to $remotePath/*.${END_COLOR}"
elif [[ $copy -eq 1 && $iconCopied -eq 0 ]]; then
	echo "${GREEN}Completed transfer of all *.desktop to $remotePath/*.${END_COLOR}"
elif [[ $copy -eq 0 && $iconCopied -eq 1 ]]; then
	echo "${GREEN}Completed transfer of all icons to $remotePath/*.${END_COLOR}"
else
	echo "${GREEN}Completed transfer of all *.desktop and icons to $remotePath/*.${END_COLOR}"
fi

exit 0
#EOF

