#!/bin/bash

# Version 1.0
# Author: Taylor Flatt
# Script: Runs the appropriate test data through the requested db file using blastn for comparison for a specific test.
#
# Note: There is a better way to program this without reusing code, but this does the job right now. Doesn't need to 
# be fancy.
#
# Note: EVAL_NUM should be a decimal (0.0000000001 for instance).
#
# Usage: ./runTest.sh TEST_NAME EVAL_NUM TEST_NUM 

if [[ $# != 3 ]]; then
	echo "Please enter a test to run (exactly one of these choices) [clc/ctg/scf/all] and the TEST_NUM [1,2,3...,n] and the e-val number as a decimal."
	exit 1
fi

regex='^[0-9]+$'
if ! [[ $3 =~ $regex ]]; then
	echo "Please enter a number for the TEST_NUM."
	exit 1
fi

evalNum=$2
testNum=$3
testName=Test$testNum

if [[ $1 == "clc" ]]; then
	db_path=/home/student/Desktop/GenomeAssembleComparisons/CLC_DB/dbFile_all
	outDir1=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CLC/output-ctg.txt
	outDir2=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CLC/output-scf.txt
	query1=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/genome.ctg.fasta.txt
	query2=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/genome.scf.fasta.txt

	if [[ ! -e $query1 ]]; then
		echo "We can't find the CTG query file!"
		exit 1
	fi

	if [[ ! -e $query2 ]]; then
		echo "We can't find the SCF query file!"
		exit 1
	fi

	# Check if the output directories exist. Create them if they don't.
	if [[ ! -d "/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF/" ]]; then
		echo "Creating SCF directory..."		
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF
	fi

	if [[ ! -d "/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/" ]]; then
		echo "Creating CTG directory..."
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/
	fi
elif [[ $1 == "ctg" ]]; then
	db_path=/home/student/Desktop/GenomeAssembleComparisons/Masurca_CTG_DB/dbFile_all
	query=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/genome.ctg.fasta.txt
	outDir=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/output.txt

	if [[ ! -e $query ]]; then
		echo "We can't find the CTG query file!"
		exit 1
	fi

	# Check if the output directory exists. Create it if it doesn't.
	if [[ ! -d /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/ ]]; then
		echo "Creating CTG directory..."
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/
	fi
elif [[ $1 == "scf" ]]; then
	db_path=/home/student/Desktop/GenomeAssembleComparisons/Masurca_SCF_DB/dbFile_all
	query=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/genome.scf.fasta.txt
	outDir=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF/output.txt

	if [[ ! -e $query ]]; then
		echo "We can't find the SCF query file!"
		exit 1
	fi

	# Check if the output directory exists. Create it if it doesn't.
	if [[ ! -d /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF/ ]]; then
		echo "Creating SCF directory..."
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF/
	fi
elif [[ $1 == "all" ]]; then
	clc_db_path=/home/student/Desktop/GenomeAssembleComparisons/CLC_DB/dbFile_all
	ctg_db_path=/home/student/Desktop/GenomeAssembleComparisons/Masurca_CTG_DB/dbFile_all
	scf_db_path=/home/student/Desktop/GenomeAssembleComparisons/Masurca_SCF_DB/dbFile_all

	query1=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/genome.ctg.fasta.txt
	query2=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/genome.scf.fasta.txt

	clc_outDir1=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CLC/output-ctg.txt
	clc_outDir2=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CLC/output-scf.txt

	ctg_outDir=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/output.txt

	scf_outDir=/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF/output.txt

	if [[ ! -e $query1 ]]; then
		echo "We can't find the CTG query file!"
		exit 1
	fi

	if [[ ! -e $query2 ]]; then
		echo "We can't find the SCF query file!"
		exit 1
	fi

	# Check if the output directories exist. Create them if they don't.
	if [[ ! -d "/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CLC/" ]]; then
		echo "Creating CLC directory..."		
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CLC
	fi

	# Check if the output directories exist. Create them if they don't.
	if [[ ! -d "/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG/" ]]; then
		echo "Creating CTG directory..."		
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/CTG
	fi

	# Check if the output directories exist. Create them if they don't.
	if [[ ! -d "/home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF/" ]]; then
		echo "Creating SCF directory..."		
		mkdir -p /home/student/Desktop/GenomeAssembleComparisons/Tests/$testName/SCF
	fi

	# No error checking, just rushing through it at the moment.
else
	echo "Please enter either clc, ctg, or scf as a testing comparison to run."
	exit 1
fi

if [[ $1 == "clc" ]]; then
	echo "Running blast analysis on CTG Data using CLC Db..."	
	blastn -task dc-megablast -db $db_path -query $query1 -out $outDir1 -evalue $evalNum
	blastn -task dc-megablast -db $db_path -query $query1 -out $outDir1.6 -outfmt 6 -evalue $evalNum

	echo "Running blast analysis on SCF Data using CLC Db..."
	blastn -task dc-megablast -db $db_path -query $query2 -out $outDir2 -outfmt 6 -evalue $evalNum
	blastn -task dc-megablast -db $db_path -query $query2 -out $outDir2.6 -outfmt 6 -evalue $evalNum
elif [[ $1 == "all" ]]; then
	echo "Running blast analysis on CTG Data using CLC Db..."	
	blastn -task dc-megablast -db $clc_db_path -query $query1 -out $clc_outDir1 -evalue $evalNum
	blastn -task dc-megablast -db $clc_db_path -query $query1 -out $clc_outDir1.6 -outfmt 6 -evalue $evalNum

	echo "Running blast analysis on SCF Data using CLC Db..."
	blastn -task dc-megablast -db $clc_db_path -query $query2 -out $clc_outDir2 -evalue $evalNum
	blastn -task dc-megablast -db $clc_db_path -query $query2 -out $clc_outDir2.6 -outfmt 6 -evalue $evalNum
	
	echo "Running blast analysis on CTG Data using Masurca Db..."
	blastn -task dc-megablast -db $ctg_db_path -query $query1 -out $ctg_outDir -evalue $evalNum
	blastn -task dc-megablast -db $ctg_db_path -query $query1 -out $ctg_outDir.6 -outfmt 6 -evalue $evalNum

	echo "Running blast analysis on SCF Data using Masurca Db..."
	blastn -task dc-megablast -db $scf_db_path -query $query2 -out $scf_outDir -evalue $evalNum
	blastn -task dc-megablast -db $scf_db_path -query $query2 -out $scf_outDir.6 -outfmt 6 -evalue $evalNum
else
	echo "Running blast analysis on $1 Data using Masurca Db..."
	blastn -task dc-megablast -db $db_path -query $query -out $outDir -evalue 0.01
	blastn -task dc-megablast -db $db_path -query $query -out $outDir.6 -outfmt 6 -evalue 0.01
fi

echo "The blast run has completed successfully. You will find the output in the test folders."
exit 0
#EOF
