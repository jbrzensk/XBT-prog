#!/usr/bin/env bash
#======================================================================
# extract_prefix.sh
#
# Finds the first file matching p*e.* in the current folder and
# extracts:
#   - prefix: everything before the first 'e', p402502
#   - line_number: first 3 characters with the 'p', p40
#
# Prints them to stdout so they can be captured by another script.
#======================================================================

# Find first matching file
file=$(ls p*e.* 2>/dev/null | head -n 1)

if [[ -z "$file" ]]; then
    echo "No matching files found!" >&2
    echo "Are you running this from the correct folder?" >&2
    echo "This should only be run in a data folder with pXXXXXXX files." >&2
    exit 1
fi

# Extract everything before the first 'e'
prefix="${file%%e*}"

# Get first 3 characters after 'p'
line_number="${prefix:0:3}"

# Print results so caller can capture them
echo "$line_number $prefix"
