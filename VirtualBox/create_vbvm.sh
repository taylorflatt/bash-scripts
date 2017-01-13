#!/bin/bash

# Version 0.1
# Author: Taylor Flatt
# Script: Adds a virtual box OS to Virtual Box from a template.
#
# Note: This uses a readarray which requires Bash 4.0.
#
# Usage: ./create_vbvm.sh TEMPLATE

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
value=

# Gets the text to the right of the input delimited by a :.
get_value()
{
	local result=$(echo "$1" | cut -d ':' -f2)
	echo "$result"
}

readarray -t lines < "$template"

for line in "${lines[@]}"; do
	case "$line" in
		"#"*)
			echo "This is a commented line"
			;;
		# Process VM Name.
		"NAME:"*)
			# Get the current list of VMs and make sure the new one isn't already on it.
			currentVms=$(VBoxManage list vms)
			vmName=$(get_value "$line")
			if [[ $line = *"$vmName"* ]]; then
				echo "A VM with the name $vmName has already been created. You must first delete it."
				exit 1
			fi
			;;
		# Process OS Type.
		"OS:"*)
			value=$(get_value "$line")
			VBoxManage createvm --name $vmName --ostype "$value" --register
			;;
		# Process RAM.
		"RAM:"*)
			value=$(get_value "$line")
			VBoxManage modifyvm $vmName --memory $value
			;;
		# Catch any error.
		*)
			echo "Unrecognized syntax: $line"
			if [[ $vmName != "" ]]; then
				VBoxManage unregistervm $vmName
			fi
			;;
	esac
done

exit 0
