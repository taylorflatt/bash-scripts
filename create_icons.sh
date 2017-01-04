#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# A script that creates the .desktop files and populates them with the set data. It also adds
# files to the launcher if so desired.
#
# Note: Due to the location of the file, you must be sudo in order to run this script.
#
# NOTE: This may not work since the script is run as sudo (necessary to create the icons)
# but it might be messing up the setting of the launcher icons since this sets it for the 
# user RUNNING the command. So it resets after the current execution. This means the script 
# might need to be split into two scripts which would be incredibly unfortunate. Alternatively,
# the directory could be chmoded to 757 temporarily (originally 755) in order to create the 
# icons and then set the launcher icons. It definitely works when the command isn't run as sudo. 
# Confirmed by running unity --replace. This needs to be discussed at a later date.
#
# Usage: ./create_icons.sh

# Only allow Root and Sudo to run the program
if [[ $EUID -ne 0 ]] || [[ -z $SUDO_USER ]]; then
	echo "This script must be invoked as an elevated 
	user because it might create files in an access 
	strict zone. Please re-run the script as sudo."
	exit 1
fi

# Declare the arrays.
declare -a programPaths
declare -a programData
#declare -a launcherIcons	# Optional

# Create all program paths.
localPath="/usr/share/applications/"
program1Path="${localPath}totem.desktop"
program2Path="${localPath}test2.desktop"
program3Path="${localPath}test3.desktop"
program4Path="${localPath}libreoffice-calc.desktop"

# Add the paths to an array.
programPaths=($program1Path $program2Path $program3Path $program4Path)

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

program4Data="[Desktop Entry]
Version=1.0
Terminal=false
Icon=libreoffice-calc
Type=Application
Categories=Office;Spreadsheet;X-Red-Hat-Base;X-MandrivaLinux-Office-Spreadsheets;
Exec=libreoffice --calc %U
MimeType=application/vnd.oasis.opendocument.spreadsheet;application/vnd.oasis.opendocument.spreadsheet-template;application/vnd.sun.xml.calc;application/vnd.sun.xml.calc.template;application/msexcel;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.ms-excel.sheet.macroenabled.12;application/vnd.openxmlformats-officedocument.spreadsheetml.template;application/vnd.ms-excel.template.macroenabled.12;application/vnd.ms-excel.sheet.binary.macroenabled.12;text/csv;application/x-dbf;text/spreadsheet;application/csv;application/excel;application/tab-separated-values;application/vnd.lotus-1-2-3;application/vnd.oasis.opendocument.chart;application/vnd.oasis.opendocument.chart-template;application/x-dbase;application/x-dos_ms_excel;application/x-excel;application/x-msexcel;application/x-ms-excel;application/x-quattropro;application/x-123;text/comma-separated-values;text/tab-separated-values;text/x-comma-separated-values;text/x-csv;application/vnd.oasis.opendocument.spreadsheet-flat-xml;application/vnd.ms-works;application/clarisworks;application/x-iwork-numbers-sffnumbers;
Name=LibreOffice Calc
GenericName=Spreadsheet"

# End Create file contents.

# Note, the variables MUST be passed in quoted or it won't properly interpret the data.
programData=("$program1Data" "$program2Data" "$program3Data" "$program4Data")

# List of program names that a launcher icon will be added. (Optional)
#launcherIcons=("test2.desktop" "test3.desktop")

# For every program, check if it exists. If it doesn't, create the file and 
# append the appropriate data to it and modify the permissions appropriately.
for ((index=0; index < ${#programPaths[@]}; index++)); do
	if [[ -r ${programPaths[$index]} ]]; then
		echo ${programPaths[$index]}": File exists. Don't do anything."
	else
		echo ${programPaths[$index]}": File does not exist. We need to 
		create the file! Creating the file and adding the contents to the file..."
		if touch ${programPaths[$index]}; then
			echo -e "${programData[$index]}" > ${programPaths[$index]}
			chmod 644 ${programPaths[$index]}
			
			# Maybe need to chown here. Need to check about this.
			
			# Gets the path, reverses it, then removes everything after the / leaving 
			# the backwards filename only. Finally, reverse the file to get the filename.
			fileName=$(echo "${programPaths[$index]}" | rev | cut -d '/' -f 1 | rev)
			
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
			newFavorites=$(echo $currentFavorites | sed s/]/", 'application:\/\/${fileName}']"/)
			
			# Saves the new settings.
			# NOTE: This may not work since the script is run as sudo (necessary to create the icons)
			# but it might be messing up the setting of the launcher icons since this sets it for the 
			# user RUNNING the command. So it resets after the current execution. This means the script 
			# might need to be split into two scripts which would be incredibly unfortunate. Alternatively,
			# the directory could be chmoded to 757 temporarily (originally 755) in order to create the icons 
			# and then set the launcher icons. It definitely works when the command isn't run as sudo.
			gsettings set com.canonical.Unity.Launcher favorites "${newFavorites}"			
		else
			echo "Failed to create ${programPaths[$index]}"
			exit 1
		fi
	fi
done

exit 0
#EOF
