#!/bin/bash

# Version 0.3.1
# Author: Taylor Flatt
# Script: Adds a virtual box OS to Virtual Box from a template.
#
# Note: This uses a readarray which requires Bash 4.0.
# Note: Command references: https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm
# Note: The get_share_path() function WILL NOT return an accurate path if that path contains spaces.
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

# Global variables.
template=$1
vmName=
os=
cores=
ram=
vram=
ioapic=
numNics=0	# Number of NICs the user put in the template.
virtex=
shareName=
sharePath=

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

# Gets the particular NIC number for dynamic variable creation.
get_nic_num()
{
	local nicNum=$(echo "$1" | cut -c 4- | cut -d ':' -f1)
	echo "$nicNum"
}

# Gets the name of the share. Should be the FIRST word (and cannot have spaces).
# The space restriction is also enforced within VirtualBox.
get_share_name()
{
	local shareName=$(echo "$1" | cut -d ' ' -f1)
	echo "$shareName"
}

# Gets the absolute path of the share. Should be the SECOND word.
# NOTE: This WILL fail if the path has spaces in it. Need to figure out an alternative.
get_share_path()
{
	local sharePath=$(echo "$1" | cut -d ' ' -f2)
	echo "$sharePath"
}

# Makes sure that the NIC was entered properly with the full range of possible values.
verify_nic()
{
	local nic=$1
	possibleValues=("none" "null" "nat" "bridged" "intnet" "hostonly" "generic" "natnetwork")
	
	# Make sure it is a valid value.
	for val in "${possibleValues[@]}"; do
		if [[ "$nic" = "$val" ]]; then
			found=1
			break;
		fi
	done
	
	# If it isn't, display the list of possible values.
	if [[ $found -ne 1 ]]; then
		echo "ERROR: The value input for $nic was not recognized. Please enter one of the following: ${possibleValues[@]}"
		exit 1
	fi
}

readarray -t lines < "$template"

for line in "${lines[@]}"; do
	case "$line" in
		# Line is a comment.
		"#"*)
			;;
		# Line is empty.
		"")
			;;
		# Process VM Name.
		"NAME:"*)
			# Get the current list of VMs and make sure the new one isn't already on it.
			currentVms=$(VBoxManage list vms)
			vmName=$(get_value "$line")
			if [[ $currentVms = *"$vmName"* ]]; then
				echo "ERROR: A VM with the name $vmName has already been created. You must first delete it."
				exit 1
			fi
			;;
		# Process OS Type.
		"OS:"*)
			os=$(get_value "$line")
			;;
		# Process CPU Cores.
		"CORES:"*)
			cores=$(get_value "$line")
			
			# Make sure the cores value is an integer.
			if [ "$cores" -ne "$cores" ] 2> /dev/null; then
				echo "ERROR: The CORES value should be an integer representing the number of CPU cores for the VM."
				exit 1
			fi
			;;
		# Process RAM.
		"RAM:"*)
			ram=$(get_value "$line")
			
			# Make sure the ram value is an integer.
			if [ "$ram" -ne "$ram" ] 2> /dev/null; then
				echo "ERROR: The RAM value should be an integer representing the number of MB of RAM for the VM."
				exit 1
			fi
			;;
		# Process I/O APIC.
		"IOAPIC:"*)
			ioapic=$(get_value "$line")
			
			# Convert to all lowercase.
			ioapic="${ioapic,,}"
			if [[ "$ioapic" != "on" ]] && [[ "$ioapic" != "off" ]]; then
				echo "ERROR: The IOAPIC value should either be \"on\" or \"off\". Case doesn't matter."
				exit 1
			fi
			;;
		# Process VRAM.
		"VRAM:"*)
			vram=$(get_value "$line")
			
			# Make sure the RAM value is an integer.
			if [ "$vram" -ne "$vram" ] 2> /dev/null; then
				echo "ERROR: The VRAM value should be an integer representing the number of MB of VRAM for the VM."
				exit 1
			fi
			;;
		# Process NICs. TODO: May need to process extra information about the NIC (specific information).
		"NIC"*)
			value=$(get_value "$line")
			
			# Convert to all lowercase.
			value="${value,,}"
			
			# Make sure it is a valid value.
			verify_nic $value
			
			# Dynamically assign the nic value (should probably use associative arrays to get with the times).
			nicNum=$(get_nic_num "$line")
			nic="nic$nicNum"
			eval ${nic}=$value
			
			((numNics+=1))
			
			### DEBUG ###
			echo ""
			echo "Value: $value"
			echo "numNics: $numNics"
			echo "NIC1: $nic1"
			echo "NIC2: $nic2"
			echo "NIC3: $nic3"
			echo "NIC4: $nic4"
			echo ""
			### /DEBUG ###
			;;
		# Process VT-X or AMD-V
		"VTX"*|"AMDV"*)
			virtex=$(get_value "$line")
			
			# Convert to all lowercase.
			virtex="${virtex,,}"
			if [[ "$virtex" != "on" ]] && [[ "$virtex" != "off" ]]; then
				echo "ERROR: The VT-X/AMD-V value should either be \"on\" or \"off\". Case doesn't matter."
				exit 1
			fi
			;;
		# Process Shared Folders
		"SHARE:"*)
			value=$(get_value "$line")
			
			shareName=$(get_share_name "$value")
			sharePath=$(get_share_path "$value")		# NOTE: This will be INCORRECT if the path has spaces in it.			
			;;
		# Catch any error/syntax fault.
		*)
			echo "Unrecognized syntax: $line"
			exit 1
			;;
	esac
done

# Might need to add additional checks for data integrity (expect an INT for ram for instance).

# Create and register the VM.
#VBoxManage createvm --name $vmName --ostype "$os" --register

# Modify its properties.
#VBoxManage modifyvm $vmName --cpus "$cores"
#VBoxManage modifyvm $vmName --memory "$ram" --vram "$vram"
#VBoxManage modifyvm $vmName --ioapic "$ioapic"

# Manage the 4 possible adapters.
for(( index=1; index <= $numNics; index++ )); do
	# Using indirect substitution, nic[1..4] can be referenced efficiently dynamically.
	command="nic$index"
	#VBoxManage modifyvm $vmName --"$command" "${!command}"
done

#VBoxManage modifyvm $vmName --hwvirtex "$virtex"
#VBoxManage sharedfolder $vmName --name $shareName --hostpath $sharePath


# If any problem occurs after creating the VM, we should probably unregister it or give the user 
# the option to do so. The command is: VBoxManage unregistervm $vmName


exit 0
