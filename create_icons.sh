#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# A script that creates the .desktop files and populates them with the set data. It also adds
# files to the launcher if so desired.
#
# Note: To add the icons and .desktop files, the script must be run as sudo. To add icons to the 
# launcher, the script must be run as a non-escalated user (non-root/non-sudoer). These actions are 
# mutually exclusive.
#
# Example: Typical usage might be:
#	sudo ./create_icons.sh ~/Desktop/Icons/		# Creates the icons and *.desktop files.
#	./create_icons.sh				# Adds icons to the launcher (if any).
#
# TODO: Read all files in a directory and assign the name and file contents to the script arrays 
# dynamically. If the icon is in a special directory, assign its name to the icon array as well 
# as storing its contents.
#
# Usage: ./create_icons.sh [ICON_PATH]

escalated=0

if [[ $EUID -eq 0 ]] || [[ ! -z $SUDO_USER ]]; then
	escalated=1
fi

iconDir=
madeIconsAlready=0

if [[ $# -ne 1 && $escalated -eq 1 ]]; then
	echo "Running this script as root requires that a single parameter be set for the location 
	of the icon's directory that needs copied."
	exit 1
elif [[ $# -ne 0 && $escalated -eq 0 ]]; then
	echo "This script must be run without a parameter input when run as a non-escalated user."
	exit 1
else
	iconDir=$1
fi

# Declare the arrays.
declare -a programPaths
declare -a programData
declare -a launcherIcons

# Create all program paths.
localPath="/usr/share/applications/"
program1Name="weka.desktop"
program2Name="matlab.desktop"

# Add the paths to an array.
programPaths=("${localPath}$program1Name" "${localPath}$program2Name")

# Create file contents.
program1Data="[Desktop Entry]
Name=weka
GenericName=Machine learning algorithms for data mining tasks
Exec=/usr/bin/weka
Icon=/usr/share/applications/Icons/48x48/weka.png
Terminal=false
Type=Application
Categories=Education;Science;Java
Encoding=UTF-8"

program2Data="[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=matlab -desktop
Name=MATLAB
Icon=/usr/share/icons/hicolor/48x48/apps/matlab.png
Categories=Development;Math;Science
Comment=Scientific computing environment
StartupNotify=true
StartupWMClass=com-mathworks-util-PostVMInit"

# End Create file contents.

# Note, the variables MUST be passed in quoted or it won't properly interpret the data.
programData=("$program1Data" "$program2Data")

# List of program names that a launcher icon will be added. (Optional)
launcherIcons=("$program1Name" "$program2Name")

# For every program, check if it exists. If it doesn't, create the file and 
# append the appropriate data to it and modify the permissions appropriately.
for ((index=0; index < ${#programPaths[@]}; index++)); do
	# Script is run as an escalated user, create the icons and .desktop files.
	if [[ $escalated -eq 1 ]]; then
		newIconDir="${localPath}Icons/48x48"
		# Copy the icons from a specified directory to a new icons directory only once.
		if [[ $madeIconsAlready -eq 0 ]]; then
			if mkdir -p $newIconDir; then
				echo "Copying all icons from $iconDir to $newIconDir"
				cp -r $iconDir/. $newIconDir
				madeIconsAlready=1
			else
				echo "Couldn't create the Icon's directory."
				exit 1
			fi
		fi

		fileContents="$(cat ${programPaths[$index]})"

		# If the file exists and its contents are different, then replace the contents.
		if [[ -r ${programPaths[$index]} && "${programData[$index]}" != "$fileContents" ]]; then
			echo -e "${programData[$index]}" > ${programPaths[$index]}
			echo ${programPaths[$index]}": File exists and contents differ."
		# File doesn't exist, so it needs created.
		elif [[ ! -r ${programPaths[$index]} ]]; then
			# File doesn't exist.
			echo "Running as sudo. Need to create the file"
			# Create the file, add the contents, and change its permissions.
			if touch ${programPaths[$index]}; then
				echo -e "${programData[$index]}" > ${programPaths[$index]}
				chmod 644 ${programPaths[$index]}
			else
				echo "Couldn't create the .desktop file."
				exit 1
			fi
		else
			echo "File exists but the contents are the same. Not modifying the file."
		fi

	# Only modify the launcher icons.
	else
		fileName=$(echo "${programPaths[$index]}" | rev | cut -d '/' -f 1 | rev)
		echo "Running as normal user. Need to check launcher icons."

		# Only add the icons from launcherIcons array to the launcher.
		for ((count=0; count < ${#launcherIcons[@]}; count++)); do
			if [[ "$fileName" = "${launcherIcons[$count]}" ]]; then
				currentFavorites=$(gsettings get com.canonical.Unity.Launcher favorites)
				echo "Icon needs to be added to the list of launcher favorites."

				# If the file isn't current in the list of launcher icons, add it.
				if [[ ${currentFavorites} != *"$fileName"* ]]; then
					newFavorites=$(echo $currentFavorites | sed s/]/", 'application:\/\/${fileName}']"/)
					gsettings set com.canonical.Unity.Launcher favorites "${newFavorites}"
					echo "File isn't in the list of launcher favorites. Add it."
				fi
			fi
		done	
	fi
done

exit 0
#EOF
