#!/bin/bash
#
# Copy cruise data files from one prefix to another,
# retaining the original files.
#
# BRZENSKI 2026-02-10
#
# Usage:
#   1. Edit the variables at the top of the script to specify:
#      - cruise1: the original cruise prefix (e.g., "p372309")
#      - cruise2: the new cruise prefix to copy to (e.g., "s372309")
#      - dir: the destination directory where the new files should be copied
#   2. Run the script from the directory containing the source files:
#      ./ren_new.sh
#
############################################################################
# Edit these variables for each run:
############################################################################
cruise1="P132504"   # starting name
cruise2="p132601"   # what to change to
dir="/home/jbrzensk/XBT/p13/250404/raw/raw_alt/" # need the trailing slash!
############################################################################

echo ""
echo "Renaming files from ${cruise1} to ${cruise2} into directory: $dir"
echo ""

# Check that the destination directory exists
if [ ! -d "$dir" ]; then
    echo "Error: Destination directory does not exist: $dir"
    exit 1
fi

# Auto-detect the highest file number from existing source files.
# Looks at the e.NNN files to determine the range.
max_num=0
for f in ${cruise1}e.[0-9][0-9][0-9]; do
    if [ -f "$f" ]; then
        num="${f##*.}"          # extract the NNN suffix
        num=$((10#$num))        # strip leading zeros for arithmetic
        if [ "$num" -gt "$max_num" ]; then
            max_num=$num
        fi
    fi
done

if [ "$max_num" -eq 0 ]; then
    echo "Error: No source files found matching ${cruise1}e.NNN"
    exit 1
fi

echo "Detected $max_num stations (${cruise1}e.001 .. ${cruise1}e.$(printf '%03d' $max_num))"

for i in $(seq 1 "$max_num"); do
    src=$(printf "%03d" "$i")
    dst=$(printf "%03d" "$i")

    echo "Copying station $src -> ${dir}${cruise2}*${dst}"

    cp "${cruise1}e.${src}" "${dir}${cruise2}e.${dst}"
    cp "${cruise1}q.${src}" "${dir}${cruise2}q.${dst}"
    cp "${cruise1}s.${src}" "${dir}${cruise2}s.${dst}"
    cp "${cruise1}r_${src}.SRP" "${dir}${cruise2}r_${dst}.SRP"
done
