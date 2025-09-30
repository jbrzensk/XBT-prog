#!/usr/bin/env bash
#####################################################################
# run_analysis.sh - Preprocess XBT Data
#
# Description:
#   This script performs all preprocessing steps for a given raw
#   XBT data folder. It automatically detects filenames and
#   determines the appropriate processing steps based on the file.
#
# Usage:
#   Run this script from within the 'raw' directory of the data
#   you want to process:
#       ./run_analysis.sh
#
# Prerequisites:
#   - Ensure that any necessary file renaming has been completed
#     prior to running this script.
#   - The script must be executed from the 'raw' directory.
#
# Output:
#   - All log messages and details are written to 'analysis.log'.
#   - All processing movements happen here, and appropriate files
#     are copied one folder above this (raw..)
#
# Behavior:
#   - Exits immediately if any command fails (set -e).
#   - Verifies that it is executed in the correct 'raw' directory.
#   - Generates helpful error messages if something doesn't work.
#
# Requires:
#   - mvraw.sh
#   - analyze_stations.sh
#   - gpsposnew.x
#   - check_renav.sh
#   - tenm3_chgcoef.x
#####################################################################

cwd=$(pwd)
if [[ ! "$cwd" =~ /raw$ ]]; then
    echo ""
    echo "********************************************************"
    echo "Error: This script must be run from the 'raw' directory."
    echo "********************************************************"
    echo ""
    exit 1
fi
#################################
# Move the raw data files
#################################
# Run mvraw.sh
echo ""
echo "Running mvraw.sh"
mvraw.sh > analysis.log 2>&1
echo ""

#################################
# Run analyze_stations.sh
#################################
echo "Running analyze_stations.sh"
analyze_stations.sh 2>&1 | tee -a analysis.log

#################################
# Run gpsposnew.x, using options 1,4,and 0
#################################
echo "Running gpsposnew.x"
echo -e "1\n4\n0\n" | gpsposnew.x >> analysis.log 2>&1
echo ""

#################################
# Check the renav.dat for entries and see if user wants a stop
#################################
echo "Checking renav.dat for entries..."
check_renav.sh 2>&1 | tee -a analysis.log
# Because we piped the output, we check the status of the last command
# in PIPESTATUS.
status=${PIPESTATUS[0]}
if [[ $status -ne 0 ]]; then
    echo "Exiting main script because user chose to quit."
    exit 1
fi

#################################
# Move specific files up one directory (edit the pattern as needed)
#################################
echo "Moving processed files up one directory"
mv p*e.* ..

echo "Moving control.dat and p*.dat"
cp control.dat ..
cp p*.dat ..
# making a backup because some of the FORTRAN scripts
# are very aggresive in clobbering files!!
pdatfile=$(ls p*.dat 2>/dev/null | head -n 1)
if [[ -n "$pdatfile" ]]; then
    cp "$pdatfile" "old_${pdatfile}"
    echo "Copied $pdatfile -> old_${pdatfile}"
else
    echo "No .dat files found"
fi

echo "Analysis complete and files moved."
echo ""

#################################
# Change Coefficient
# NOTE: tenm3_chgcoef is super aggresive and
# clobbers the dat file! Check to make
# sure thats not happening
#################################
pushd .
cd ..
# This gets the first file matching p*e.*
file=$(ls p*e.* 2>/dev/null | head -n 1)
# Display the base name without extension, thats what we will use 
# for the next few commands
if [[ -n "$file" ]]; then
    base="${file%e.*}"   # remove 'e.NNN' to get pXXXXXXX
    echo "First pXXXXXXX: $base"
else
    echo "No files matching p*e.* found"
fi
# Add the a to the ending
dat_file="${base}.dat"
new_name="${base}a"
# Finding the min and max drops from stations
mindrop=$(awk 'NR==1 {print $1}' $dat_file )
maxdrop=$(awk 'NR==FNR{lines[NR]=$0} END{split(lines[NR],a); print a[1]}' $dat_file )
# Make sure awk actually found something!!
if [[ -z "$mindrop" || -z "$maxdrop" ]]; then
    echo "Error: Could not determine min or max drop from $dat_file"
    echo "Exiting script."
    exit 1
fi

# Run tenm3_chgcoef.x
echo "Running tenm3_chgcoef.x"
echo "Changing coefficients for ${base}, min drop: ${mindrop}, max drop: ${maxdrop}"
# Those values are passed to tenm3_chgcoef.x
# The 'n' at the end is to not change the dat file name:
echo -e "${new_name}\n${mindrop} ${maxdrop}\nn" | tenm3_chgcoef.x 2>&1 | tee -a analysis.log



#################################
# End the program
#################################
popd
# And run this one more time, so we dont have to scroll
echo "Running analyze_stations.sh"
analyze_stations.sh 2>&1 | tee -a analysis.log
