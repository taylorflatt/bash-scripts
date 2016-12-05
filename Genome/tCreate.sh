#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# Script will then create the necessary files and add the job to the scheduler.
#
# Make sure that the file structure already exists. Run cDir.sh.
#
# Usage: tCreate TEST_SET_NUM TEST_NAME_NUM

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
if [[ ! -d /share/scratch/tflatt/$testSet/$testName/Logs ]]; then
        echo "The Log directory doesn't exist. Please check on this. Exiting......"
        exit 1
fi

# Make sure scripts directory exists.
if [[ ! -d /share/scratch/tflatt/Scripts/$testSet/$testName ]]; then
        echo "The Scripts directory doesn't exist. Please check on this. Exiting......"
        exit 1
fi

# Check if the config.txt file exists.
if [[ ! -e /share/scratch/tflatt/Scripts/$testSet/$testName/config.txt ]]; then
	echo "The config.txt file isn't in the proper directory. Exiting......"
	exit 1
fi

# Create the assembly.sh script.
/share/bio/masurca/bin/masurca /share/scratch/tflatt/Scripts/$testSet/$testName/config.txt -o /share/scratch/tflatt/$testSet/$testName/assembly.sh

# Check if the assembly.sh file exists.
if [[ ! -e /share/scratch/tflatt/$testSet/$testName/assembly.sh ]]; then
	echo "The assembly.sh file isn't in the proper directory. Exiting......"
	exit 1
fi

cd /share/scratch/tflatt/$testSet/$testName/

# Add the job to the scheduler.
qsub -pe make 20 -V -b y -cwd -q largemem.q -o /share/scratch/tflatt/$testSet/$testName/Logs/output.log -e /share/scratch/tflatt/$testSet/$testName/Logs/error.log -N $testName /share/scratch/tflatt/$testSet/$testName/assembly.sh

printf "\nThe job has been added to the scheduler. Run qstat to check on your job or qdel to delete it."
exit 0
#EOF
