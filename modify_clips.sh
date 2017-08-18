#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# Script: Download CLIPS, compile from source, and replace the existing CLIPS installation. This 
# assumes apt-get install clips was already run.
#
# Usage: sudo ./modify_clips.sh

# No parameters accepted and the user must run this as an escalated user.
if [[ $# -ne 0 ]]; then
	echo "This script does not take any parameters."
	exit 1
elif [[ $EUID -ne 0 ]] || [[ -z $SUDO_USER ]]; then
	echo "This script must be run as an elevated user."
	exit 1
fi

# Download the new version.
wget https://downloads.sourceforge.net/project/clipsrules/CLIPS/6.30/clips_core_source_630.zip -O /usr/clips.zip

# Unzip the files
unzip /usr/clips.zip -d /usr/clips

# Compile CLIPS.
gcc -o /usr/clips/clips_core_source_630/core/clips -DLINUX=1 /usr/clips/clips_core_source_630/core/*.c -lm

# Remove the old link.
rm /usr/bin/clips

# Add new symbolic link.
ln -s /usr/clips/clips_core_source_630/core/clips /usr/bin/clips
