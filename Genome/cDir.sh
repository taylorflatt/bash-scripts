#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# Script that will create the file structure for each test case necessary.
#
# This should be run before tCreate.sh in order to setup the proper file structure.
#
# Usage: cDir TEST_SET_NUM TEST_NAME_NUM

# Check Parameters
switch=0
if [[ $# != 2 ]]; then
        echo "Make sure you enter the name of the test and its set."
		switch=1
fi

# Check if the input consists of numbers.
regex='^[0-9]+$'
if ! [[ $1 =~ $regex ]] ; then
   echo "Please enter a number for TEST_SET_NUM" >&2
   switch=1
fi

if ! [[ $2 =~ $regex ]] ; then
   echo "Please enter a number for TEST_NAME_NUM" >&2
   switch=1
fi

if [[ switch -eq 1 ]]; then
	echo "Exiting..."
	exit 1
fi

# Set test values
sName='Test_Set_'
tName='Test'

testSet=$sName$1
testName=$tName$2

# Make sure logs directory exists.
if [[ -d /share/scratch/tflatt/$testSet/$testName/Logs ]]; then
  echo "The Log directory already exists. Please check on this. Exiting......"
	exit 1
fi

# Make sure scripts directory exists.
if [[ -d /share/scratch/tflatt/Scripts/$testSet/$testName ]]; then
	echo "The Scripts directory already exists. Please check on this. Exiting......"
	exit 1
fi

# Only create the directories if an error hasn't been encountered.
echo "Creating directory /share/scratch/tflatt/$testSet/$testName/Logs......"
mkdir -p /share/scratch/tflatt/$testSet/$testName/Logs

echo "Creating directory /share/scratch/tflatt/Scripts/$testSet/$testName......"
mkdir -p /share/scratch/tflatt/Scripts/$testSet/$testName

printf "\nAll folders successfully added."
exit 0
#EOF
