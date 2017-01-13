#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# Script: Adds a virtual box OS to Virtual Box from a template.
#
# Note: This uses a readarray which requires Bash 4.0.
#
# Usage: ./create_virtualbox.sh TEMPLATE

print_usage()
{
	echo ""
	echo "Usage: $0 TEMPLATE"
	echo ""
}

if [[ $# -ne 1 ]]; then
	print_usage
	exit 1
fi

# Local variables.
template=$1
vmName=
os=
ram=

# Gets the text to the right of the input delimited by a :.
get_value()
{
	local result=$(echo "$1" | cut -d ':' -f2)
	
	# Removes in-line comments (if any).
	if [[ "$result" = *"#"* ]]; then
		result=$(echo "$result" | cut -d '#' -f1)
	fi
	
	echo "$result"
}

readarray -t lines < "$template"

for line in "${lines[@]}"; do
	case "$line" in
		# Line is a comment.
		"#"*)
			;;
		# Process VM Name.
		"NAME:"*)
			# Get the current list of VMs and make sure the new one isn't already on it.
			currentVms=$(VBoxManage list vms)
			vmName=$(get_value "$line")
			if [[ $currentVms = *"$vmName"* ]]; then
				echo "A VM with the name $vmName has already been created. You must first delete it."
				exit 1
			fi
			;;
		# Process OS Type.
		"OS:"*)
			os=$(get_value "$line")
			;;
		# Process RAM.
		"RAM:"*)
			ram=$(get_value "$line")
			# Make sure the RAM value is an integer.
			if [ "$ram" -ne "$ram" ] 2> /dev/null; then
				echo "The RAM value should be an integer representing the number of MB of RAM for the VM."
				exit 1
			fi
			;;
		# Catch any error/syntax fault.
		*)
			echo "Unrecognized syntax: $line"
			exit 1
			;;
	esac
done

# Create and register the VM.
#VBoxManage createvm --name $vmName --ostype "$os" --register

# Modify its properties.
#VBoxManage modifyvm $vmName --memory "$ram"

# If any problem occurs after creating the VM, we should probably unregister it or give the user 
# the option to do so. The command is: VBoxManage unregistervm $vmName

exit 0
