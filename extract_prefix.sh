#!/usr/bin/env bash
#======================================================================
# extract_prefix.sh
#
# Finds the first file matching (ps)*e.* in the current folder and
# extracts:
#   - prefix: everything before the first 'e', (ps)402502
#   - line_number: first 3 characters with the 'ps', p40 or s40
#
# Prints them to stdout so they can be captured by another script.
#======================================================================
# Decide what prefixes we start with, could be 'p' or 's' or other?

# Detect whether files start with 'p' or 's'
if ls p*e.* &>/dev/null; then
    PREFIX="p"
elif ls s*e.* &>/dev/null; then
    PREFIX="s"
else
    echo "Error: No files found starting with 'p' or 's'."
    exit 1
fi


# Find first matching file
file=$(ls ${PREFIX}*e.* 2>/dev/null | head -n 1)

if [[ -z "$file" ]]; then
    echo "No matching files found!" >&2
    echo "Are you running this from the correct folder?" >&2
    echo "This should only be run in a data folder with (ps)XXXXXXX files." >&2
    exit 1
fi

# Extract everything before the first 'e'
prefix="${file%%e*}"

# Get first 3 characters after 'p'
line_number="${prefix:0:3}"

# Print results so caller can capture them
echo "$line_number $prefix"
