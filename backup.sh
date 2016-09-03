#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# Generic backup script with minimal flare. This is meant to be run as a 
# scheduled task - not from the commandline.
#
# This version only supports backing up of a single file to a directory.
#
# Usage: backup

# Modify these values to suit the specific backup operation.
#
# The full path file or directory you wish to copy.
source=""

# The full path destination of the backup.
destination=""
#
# End Parameter modification

#########################################################################

# First determine if the target directory must first be created.
if [[ ! -d "$destination" ]]; then
	echo "Could not find the target directory."
	echo "Creating $destination"
	if ! mkdir "$destination" 2> /dev/null; then
		printf "\n\nCreating $destination failed! Exiting.\n"
		exit 1;
	else
		echo "Successfully created $destination ..."
	fi
fi

# Move to the destination directory.
cd "$destination"

# Copy the file to the destination.
if ! cp "$source" "$destination"; then
	printf "\n\nError copying $source   to   $destination. Exiting.\n"
	exit 1;
fi

print "Successfully backed up $source to $destination"
exit 0
#EOF
