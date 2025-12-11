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
#   - Checks for existence of "e" files ( i.e. this hasnt been run )
#   - Generates helpful error messages if something doesn't work.
#
# Requires:
#   - mvraw.sh
#   - analyze_stations.sh
#   - gpsposnew.x
#   - check_renav.sh
#   - tenm3_chgcoef.x
#####################################################################
# Set general name for output log
OUTPUT_LOG="analysis.log"

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
mvraw.sh 2>&1 | tee -a $OUTPUT_LOG
echo ""


# Decide what prefixes we start with, could be 'p' or 's' or other?
echo "Detecting file prefix (p or s) ..."

# Detect whether files start with 'p' or 's'
if ls p*q.* &>/dev/null; then
    PREFIX="p"
elif ls s*q.* &>/dev/null; then
    PREFIX="s"
else
    echo "Error: No files found starting with 'p' or 's'."
    exit 1
fi
echo "Detected prefix: $PREFIX"
echo ""


# Check if there are 'e' files
count=$(compgen -G "${PREFIX}??????e.???" | wc -l)

echo "Found $count files matching ${PREFIX}XXXXXXe.XXX"
echo ""

if (( count <= 20 )); then
    echo ""
    echo "********************************************************"
    echo "Error: Expected more than 20 files matching ${PREFIX}XXXXXXe.XXX"
    echo "This suggests that the analysis has already been run."
    files_above=$(ls ../${PREFIX}*e.* 2>/dev/null | wc -l)
    echo "Found $files_above files matching ../${PREFIX}*e.*in the parent dir."
    echo "If you wish to re-run the analysis, please cp the "
    echo "files back into this 'raw' directory and try again."
    echo "********************************************************"
    echo ""
    exit 1
fi

#################################
# Run analyze_stations.sh
#################################
echo "Running analyze_stations.sh"
analyze_stations.sh 2>&1 | tee -a $OUTPUT_LOG

#################################
# Run gpsposnew.x, using options 1,4,and 0
#################################
echo "Running gpsposnew.x with choices 1,4,0"
echo -e "1\n4\n0\n" | gpsposnew.x 2>&1 | tee -a $OUTPUT_LOG
echo ""

#################################
# Check the renav.dat for entries and see if user wants a stop
#################################
echo "Checking renav.dat for entries..."
check_renav.sh 2>&1 | tee -a $OUTPUT_LOG

# Because we piped the output, we check the status of the last command
# in PIPESTATUS.
status=${PIPESTATUS[0]}
if [[ $status -ne 0 ]]; then
    echo "Exiting main script because user chose to quit in check_renav.sh."
    exit 1
fi

#####################################################################
# Move specific files up one directory (edit the pattern as needed)
#####################################################################
echo "Moving processed files up one directory"
mv ${PREFIX}*e.* ..

echo "Moving control.dat and ${PREFIX}*.dat"
cp control.dat ..
cp ${PREFIX}*.dat ..

# making a backup because some of the FORTRAN scripts
# are very aggresive in clobbering files!!
# Find one matching file
psdatfile=$(ls ${PREFIX}[0-9][0-9][0-9][0-9][0-9][0-9]*.dat 2>/dev/null | head -n 1)

if [[ -n "$psdatfile" ]]; then
    cp "$psdatfile" "old_${psdatfile}"
    echo "Copied $psdatfile -> old_${psdatfile} as a backup."
else
    echo "No .dat files found with correct pattern."
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

# This gets the first file matching p*e.* or s*e.*
file=$(ls ${PREFIX}*e.* 2>/dev/null | head -n 1)

# Display the base name without extension, thats what we will use 
# for the next few commands
if [[ -n "$file" ]]; then
    base="${file%e.*}"   # remove 'e.NNN' to get pXXXXXXX
    echo "First ${PREFIX}XXXXXXX: $base"
else
    echo "No files matching ${PREFIX}*e.* found"
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
echo -e "${new_name}\n${mindrop} ${maxdrop}\nn" | tenm3_chgcoef.x 2>&1 | tee -a $OUTPUT_LOG



#################################
# End the program
#################################
popd
# And run this one more time, so we dont have to scroll
echo "Running analyze_stations.sh"
analyze_stations.sh 2>&1 | tee -a $OUTPUT_LOG
