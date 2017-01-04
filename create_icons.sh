#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# A script that creates the .desktop files and populates them with the set data.
#
# Note: Due to the location of the file, you must be sudo in order to run this script.
#
# Usage: ./create_icons.sh

# Only allow Root and Sudo to run the program
if [[ $EUID -ne 0 ]] || [[ -z $SUDO_USER ]]; then
	echo "This script must be invoked as an elevated 
	user because it might create files in an access 
	strict zone. Please re-run the script as sudo."
	exit 1
fi

# Declare the two arrays.
declare -a programPaths
declare -a programData
declare -a launcherIcons	# Optional

# Create all program paths.
program1Path="/usr/share/applications/totem.desktop"
program2Path="/usr/share/applications/test2.desktop"
program3Path="/usr/share/applications/test3.desktop"

# Add the paths to an array.
programPaths=($program1Path $program2Path $program3Path)

# Create file contents.
program1Data="[Desktop Entry]
Categories=Office;Network;Email;
Comment=Simple text-based Mail User Agent
Comment[de]=Einfaches, Text-basiertes Mailprogramm
Exec=mutt %u
Icon=mutt
Name=mutt
Name[de]=Mutt
MimeType=x-scheme-handler/mailto;
NoDisplay=true
Terminal=true
Type=Application"

program2Data="[Desktop Entry]
Categories=Office;Network;Email;
Comment=Simple text-based Mail User Agent
Comment[de]=Einfaches, Text-basiertes Mailprogramm
Exec=mutt %u
Icon=mutt
Name=mutt
Name[de]=Mutt
MimeType=x-scheme-handler/mailto;
NoDisplay=true
Terminal=true
Type=Application"

program3Data="[Desktop Entry]
Categories=Office;Network;Email;
Comment=Simple text-based Mail User Agent
Comment[de]=Einfaches, Text-basiertes Mailprogramm
Exec=mutt %u
Icon=mutt
Name=mutt
Name[de]=Mutt
MimeType=x-scheme-handler/mailto;
NoDisplay=true
Terminal=true
Type=Application"
# End Create file contents.

# Note, the variables MUST be passed in quoted or it won't properly interpret the data.
programData=("$program1Data" "$program2Data" "$program3Data")

# (OPTIONAL) List of program names that a launcher icon will be added.
#launcherIcons=("test2.desktop" "test3.desktop")

# For every program, check if it exists. If it doesn't, create the file and 
# append the appropriate data to it and modify the permissions appropriately.
for ((index=0; index < ${#programPaths[@]}; index++)); do
	if [[ -r ${programPaths[$index]} ]]; then
		echo ${programPaths[$index]}": File exists. Don't do anything."
	else
		echo ${programPaths[$index]}": File does not exist. We need to 
		create the file! Creating the file and adding the contents to the file..."
		if  touch ${programPaths[$index]}; then
			echo -e "${programData[$index]}" > ${programPaths[$index]}
			chmod 644 ${programPaths[$index]}
			
			# Maybe need to chown here. Need to check about this.
			
			# Gets the path, reverses it, then removes everything after the / leaving 
			# the backwards filename only. Finally, reverse the file to get the filename.
			# Note that since it executes in a subshell, you have to capture the output.
			
			fileName=$(echo "${programPaths[$index]}" | rev | cut -d '/' -f 1 | rev)
			echo "Filename from PATH:  $fileName "
			
			# Compare against the list of icons that you want added to the launcher in 
			# case you don't want all.
			#for ((count=0; count < ${#launcherIcons[@]}; count++)); do
			#	if [[ "$fileName" = "${launcherIcons[$count]}" ]]; then
			#		# Add it to the launcher (taskbar).
			#		echo "Add icon"
			#	fi
			#done
			
			# Gets the current list of launcher icons.
			currentFavorites=$(gsettings get com.canonical.Unity.Launcher favorites)
			
			# Check to make sure it isn't already added to the favorites list.
			#if [[ ${currentFavorites} = *"$fileName"* ]]; then
			#	# File is already added to the favorites list.
			#fi
			
			# Adds the icon to the launcher by appending it to the favorites list.
			newFavorites=$(echo $currentFavorites | sed s/]/", '${fileName}']"/)
			
			# Saves the new settings.
			gsettings set com.canonical.Unity.Launcher favorites "${newFavorites}"
			
			
		else
			echo "Failed to create ${programPaths[$index]}"
			exit 1
		fi
	fi
done

exit 0
#EOF
