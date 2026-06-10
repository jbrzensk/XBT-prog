#!/usr/bin/env bash
#####################################################################
# check_xbtinfo_updated.sh - Verify xbtinfo file matches cruise files
#
# Description:
#   Checks whether the last cruise entry in an xbtinfo file matches
#   the cruise number embedded in the data files (e.g. p402508e.001)
#   in the current directory.
#
# Usage:
#   check_xbtinfo_updated.sh [xbtinfo_file]
#
#   If no argument is given, the script auto-detects the xbtinfo file
#   by reading the line prefix from the data files and searching the
#   current directory then ../../ for the matching xbtinfo.<prefix>.
#
# Examples:
#   check_xbtinfo_updated.sh xbtinfo.p40
#   check_xbtinfo_updated.sh ../../xbtinfo.p09
#   check_xbtinfo_updated.sh          # auto-detect
#####################################################################

# ---- Locate the xbtinfo file ----------------------------------------
# Given as command line argument $1
if [[ $# -ge 1 ]]; then
    XBTINFO="$1"
    if [[ ! -f "$XBTINFO" ]]; then
        echo "Error: xbtinfo file '$XBTINFO' not found."
        exit 1
    fi
else
    # Auto-detect: find a data file, extract prefix+line (e.g. p40)
    data_file=$(ls [psi][0-9][0-9][0-9][0-9][0-9][0-9]e.* 2>/dev/null | head -1)
    if [[ -z "$data_file" ]]; then
        echo "Error: No data files found matching [psi]######e.* in current directory."
        echo "Usage: $0 <xbtinfo_file>"
        exit 1
    fi

    # Extract line prefix (first 3 chars of filename) to determine xbtinfo name
    line_prefix="${data_file:0:3}"   # e.g. p40
    xbtinfo_name="xbtinfo.${line_prefix}"

    # Look for xbtinfo file in current directory, then ../../
    if [[ -f "./${xbtinfo_name}" ]]; then
        XBTINFO="./${xbtinfo_name}"
    elif [[ -f "../../${xbtinfo_name}" ]]; then
        XBTINFO="../../${xbtinfo_name}"
    else
        echo "Error: Could not find '${xbtinfo_name}' in ./ or ../../"
        echo "Usage: $0 <xbtinfo_file>"
        exit 1
    fi
    echo "Auto-detected xbtinfo file: $XBTINFO"
fi

# ---- Get cruise number from files in current directory --------------
# Filename format: <1-char prefix><2-digit line><4-digit cruise>e.<NNN>
# e.g. p402508e.001  →  cruise = chars 3-6 (0-indexed)

data_file=$(ls [psi][0-9][0-9][0-9][0-9][0-9][0-9]e.* 2>/dev/null | head -1)

if [[ -z "$data_file" ]]; then
    echo "Error: No data files found matching [psi]######e.* in current directory."
    exit 1
fi

file_cruise="${data_file:3:4}"

# ---- Check if cruise number exists anywhere in the xbtinfo data block ----
# The data block starts after the "---" separator line and ends at the
# first blank line. Search that block for the cruise number from the files.

found=$(awk -v cruise="$file_cruise" '
    /^-+$/                            { in_data=1; next }
    in_data && /^$/                   { exit }
    in_data && /^[0-9]{4}[[:space:]]/ { if ($1 == cruise) { print $1; exit } }
' "$XBTINFO")

# ---- Compare and report ---------------------------------------------

echo "xbtinfo file        : $XBTINFO"
echo "Cruise in data files: $file_cruise  (from $data_file)"
echo ""

# Report back, and return error code in case called from another script.
# This is called from run_image_gen.sh to verify that the xbtinfo file has been updated 
# with the new cruise before proceeding.
if [[ -n "$found" ]]; then
    echo "OK: cruise $file_cruise found in $XBTINFO."
    exit 0
else
    echo "WARNING: cruise $file_cruise not found in $XBTINFO."
    echo "Please add cruise $file_cruise to $XBTINFO before proceeding."
    exit 1
fi
