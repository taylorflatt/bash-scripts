#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# Gets all proper output files and creates an output directory containing these files.
#
# Usage: tFinish TEST_SET_NUM FIRST_TEST LAST_TEST

# Check Parameters
switch=0
if [[ $# != 3 ]]; then
        echo "Make sure you enter the name of the test along with the first test and last test."
                switch=1
fi

# Check if the input consists of numbers.
regex='^[0-9]+$'
if ! [[ $1 =~ $regex ]] ; then
   echo "Please enter a number for TEST_SET_NUM" >&2
   switch=1
fi

if ! [[ $2 =~ $regex ]] ; then
   echo "Please enter a number for FIRST_TEST" >&2
   switch=1
fi

if ! [[ $3 =~ $regex ]] ; then
   echo "Please enter a number for LAST_TEST" >&2
   switch=1
fi

if [[ switch -eq 1 ]]; then
        echo "Exiting..."
        exit 1
fi

# Set test values
sName='Test_Set_'
tName='Test'
tOut=/share/scratch/tflatt/output

if [[ -d $tOut ]]; then
        overwritePrompt=
        while [[ "$overwritePrompt" != "y" ]] && [[ "$overwritePrompt" != "n" ]]; do

        printf "The output directory already exists in this directory. Would you like
        to delete it? This will remove all the data potentially contained within. If no,
        then the program will exit.\n\nDelete (y/n):"
        read overwritePrompt

        echo ""
        case "$overwritePrompt" in
                "y")
                        printf "Removing $tOut.....\n\n"
                        rm -r $tOut
                        ;;
                "n")
                        echo "Exiting.....\n"
                        exit 0
                        ;;
                *)
                        echo "$Error: Please choose a valid option of y or n. \n\n"
                        echo ""
                        ;;
        esac
done
fi

testSet=$sName$1
firstTestNum=$2
lastTestNum=$3

for (( i = $firstTestNum; i <= $lastTestNum; i++ )); do
        testName=$tName$i
        testDir=$tOut/$testSet/$testName

        # List of files that need to be copied to the output directory.
        file1=/share/scratch/tflatt/$testSet/$testName/CA/10-gapclose/genome.ctg.fasta
        file2=/share/scratch/tflatt/$testSet/$testName/CA/10-gapclose/genome.posmap.ctgscf
        file3=/share/scratch/tflatt/$testSet/$testName/CA/10-gapclose/genome.scf.fasta

        printf "\n$testName: Gathering data.\n"

        # Copy the files and create the necessary directories if required.
        for (( j = 1; j <= 3; j++ )); do
                cFile=file${file}${j}
                if [[ ! -e "${!cFile}" ]]; then
                        echo "${!cFile}: Doesn't exist. So either the test hasn't started or hasn't completed."
                else
                        if [[ ! -d $testDir ]]; then
                                echo "$testDir: Making directory...."
                                mkdir -p $testDir
                        fi
                        echo "${!cFile}: Copying file...."
                        cp ${!cFile} $testDir
                fi
        done
done

printf "\nYour test outputs can be found at $tOut.\n\n"
exit 0
#EOF
