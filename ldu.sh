#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# A script (Local Disk/Directory Usage) that checks the current disk usage of the CWD.
# 
# TODO: Add flag for sorting asc/desc. Add flag to show total usage relative to total system.
#	Find something faster than the "find" command to get the directories.
#
# Usage: ./ldu.sh

# Font colors for error/success messages.
RED=`tput setaf 1`
GREEN=`tput setaf 2`
END_COLOR=`tput sgr0`

function print_usage()
{
	echo ""
	echo "Usage: "
	echo "$ $0 "; echo ""

	echo ${RED}"This program doesn't take any parameter inputs.${END_COLOR} It checks the size of "
	echo "the current working directory and displays it."
	echo ""
}

declare -a allDirs

for dir in $(find ${PWD} -maxdepth 1); do
	if $(test -d ${dir}); then
		#echo $(basename ${dir})
		allDirs+=("${dir}")
	fi
done

#printf "\e[4mSize\tPath\e[0m\n"
printf "Size\tPath\n"
echo "------------------------------------------------------------------------------------"

# Iterates through the mounts checking if they are currently mounted. If not, mount them.
for ((index=1; index < ${#allDirs[@]}; index++)); do
	du -hs ${allDirs[$index]}
done

echo ""
echo "Total (CWD)"
echo "------------------------------------------------------------------------------------"
printf "$(du -hs ${allDirs[0]})\n"


exit 0
#EOF

