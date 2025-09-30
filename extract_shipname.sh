#!/usr/bin/env bash
#======================================================================
# extract_control.sh
#
# Reads a control.dat file with lines in the format:
# Key = Value
# Converts keys to Bash-friendly variable names and exports them.
#
# This is mainly used to extract the shipname, hence the name, but it
# extracts all values from control.dat, and saves them as variables
# which can be used in bash scripts calling this script.
#
# Usage:
#   source extract_control.sh control.dat
# control.dat contents:
# Ship Name =Tallahassee
# Cruise Name =p402502
# Operator Name =Michael Funke
# Max Ship Speed =18.00
# Max Plot  Temp =32
# Min Plot  Temp =0
# Max Minutes to Dead Reckon =10
# Max min duration between drops =150
# Max Displacement =450
# Max Rms Displacement =110
# Min dtdz =-0.011
# Min dtdz Displacement Test =0.0005
# Max Delta =4.6
# Max 700m Delta =0.8
# Check Profile Depth =720
# XBT's left in the autolauncher =FALSE
#======================================================================

# Determine control file
if [[ $# -eq 1 ]]; then
    control_file="$1"
else
    control_file="control.dat"
fi

# Check that file exists
if [[ ! -f "$control_file" ]]; then
    echo "Error: '$control_file' not found!" >&2
    return 1 2>/dev/null || exit 1
fi

# Function to trim leading/trailing whitespace
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Read file line by line
while IFS='=' read -r key value; do
    # Skip empty lines or lines without '='
    [[ -z "$key" || -z "$value" ]] && continue

    # Trim spaces from key and value
    key=$(trim "$key")
    value=$(trim "$value")

    # Sanitize key: replace invalid characters with underscore
    key="${key//[^a-zA-Z0-9_]/_}"

    # Export variable
    export "$key"="$value"
done < "$control_file"
