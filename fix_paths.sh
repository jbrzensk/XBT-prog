#!/usr/bin/env bash
#======================================================================
# fix_paths.sh - Strip directory paths from ferret plot files to make 
# everything relative to current directory
#
# Usage:
#   ./fix_paths.sh XXX.fer
#
# This script will:
#   1. Create a backup of XXX.fer as XXX.fer.bak
#   2. Replace every quoted path like "/kakopo/xbt/data..../file.tem"
#      with just "file.tem"
#======================================================================

# Exit if no file provided
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <datfile>"
    exit 1
fi

datfile="$1"

# Check that the file exists
if [[ ! -f "$datfile" ]]; then
    echo "Error: File '$datfile' not found!"
    exit 1
fi

# Make a backup
cp "$datfile" "${datfile}.bak"

# Run sed to replace all quoted paths with just filenames
#sed -i 's|".*/\([^/]*\)"|"\1"|g' "$datfile"
sed -i 's|"/data/xbt/[psi][0-9][0-9]/[0-9]\{4\}/\([^"]*\)"|"\1"|g' "$datfile"

# Special case for p09/p06
sed -i 's|"/data/xbt/p09/bathas\.grd"|"\.\./bathas.grd"|g' "$datfile"
sed -i 's|"/data/xbt/p09/bathes\.grd"|"\.\./bathes.grd"|g' "$datfile"
sed -i 's|"/data/xbt/p09/bathss\.grd"|"\.\./bathss.grd"|g' "$datfile"
sed -i 's|"/data/xbt/p06/bathas\.grd"|"\.\./bathas.grd"|g' "$datfile"

echo "✅ Updated $datfile (backup saved as ${datfile}.bak)"
