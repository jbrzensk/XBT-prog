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

# Preflight: verify all required tools are in PATH before touching any data
for tool in mvraw.sh analyze_stations.sh gpsposnew.x check_renav.sh tenm3_chgcoef.x; do
    if ! command -v "$tool" &>/dev/null; then
        echo "Error: required tool '$tool' not found in PATH."
        exit 1
    fi
done

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
elif ls i*q.* &>/dev/null; then
    PREFIX="i"
else
    echo "Error: No files found starting with 'p' or 's'."
    exit 1
fi
echo "Detected prefix: $PREFIX"
echo ""


# Determine run state based on where e-files are.
count=$(compgen -G "${PREFIX}??????e.???" | wc -l)
count_parent=$(ls ../${PREFIX}*e.* 2>/dev/null | wc -l)

echo "Found $count e-files in raw/, $count_parent in parent."
echo ""

# If there are efiles, this must be the first run.
# If there are no efiles, but they arein the above dir, then this is a rerun.
# If neither of those are true, something else is wrong. Stop and figure it out.
RESUME=false
if (( count > 20 )); then
    echo "Starting full pipeline."
elif (( count == 0 && count_parent > 0 )); then
    echo "********************************************************"
    echo "e-files already in parent — resuming from tenm3 step."
    echo "********************************************************"
    echo ""
    RESUME=true
elif (( count > 0 && count <= 20 )); then
    echo ""
    echo "********************************************************"
    echo "Error: Only $count e-files found in raw/ — expected more than 20."
    echo "This may indicate partial or corrupted data."
    echo "********************************************************"
    echo ""
    exit 1
else
    echo ""
    echo "********************************************************"
    echo "Error: No e-files found in raw/ or parent directory."
    echo "********************************************************"
    echo ""
    exit 1
fi

if [[ "$RESUME" == false ]]; then
    #################################
    # Run analyze_stations.sh
    #################################
    echo "Running analyze_stations.sh"
    analyze_stations.sh 2>&1 | tee -a $OUTPUT_LOG

    # Need the stations.dat file for future steps, so make sure it is generated.
    if [[ ! -s "stations.dat" ]]; then
        echo "Error: stations.dat missing or empty after analyze_stations.sh."
        exit 1
    fi

    #################################
    # Run gpsposnew.x, using options 1,4,and 0
    #################################
    echo "Running gpsposnew.x with choices 1,4,0"
    echo -e "1\n4\n0\n" | gpsposnew.x 2>&1 | tee -a $OUTPUT_LOG
    echo ""

    # Check to make sure renav.dat was generated. The script generates
    # a blank file even if there are no renav files.
    if [[ ! -f "renav.dat" ]]; then
        echo "Error: renav.dat not found after gpsposnew.x."
        exit 1
    fi

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

    moved=$(ls ../${PREFIX}*e.* 2>/dev/null | wc -l)
    if (( moved == 0 )); then
        echo "Error: e-files not found in parent directory after mv."
        exit 1
    fi
    echo "Confirmed $moved e-files in parent."

    echo "Moving control.dat and ${PREFIX}*.dat"
    if [[ ! -f "control.dat" ]]; then
        echo "Error: control.dat not found — cannot copy to parent."
        exit 1
    fi
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
fi

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
    echo "Error: No files matching ${PREFIX}*e.* found in parent."
    exit 1
fi

# Add the a to the ending
dat_file="${base}.dat"
new_name="${base}a"

if [[ ! -f "$dat_file" ]]; then
    echo "Error: expected dat file '$dat_file' not found."
    exit 1
fi

# Run tenm3_chgcoef.x, unless the 'a' output already exists
if ls "${new_name}"* &>/dev/null; then
    echo "tenm3 output '${new_name}*' already exists — skipping tenm3_chgcoef.x."
else
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

    if ! ls "${new_name}"* &>/dev/null; then
        echo "Error: tenm3_chgcoef.x did not produce expected output '${new_name}*'."
        exit 1
    fi
    echo "Confirmed tenm3 output: $(ls ${new_name}* | head -1)"
fi

#################################
# End the program
#################################
# Return to raw directory
popd

# And run this one more time, so we dont have to scroll
echo "Running analyze_stations.sh"
echo ""
echo ""

analyze_stations.sh 2>&1 | tee -a $OUTPUT_LOG

# Add note to edit the xbtinfo.XX file
echo ""
echo "*****************EDIT XBTINFO FILE**********************"
echo "Note: Please remember to manually edit the xbtinfo.XX file"
echo "to reflect any changes made during this analysis."
echo "********************************************************"
echo ""
