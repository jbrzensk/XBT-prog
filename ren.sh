#!/bin/bash
#
# Rename cruise data files from one prefix to another, in place, wherever
# they actually live under $dir. Station files (e/q/s/SRP) are renamed to
# the new cruise prefix; every other file keeps its name. Any occurrence
# of the cruise1 name found inside a file's content is then replaced with
# cruise2. A pristine backup of every original file is kept in
# $dir/orig_dir before any edits are made.
#
# BRZENSKI 2026-02-10
#
# Usage:
#   1. Edit the variables at the top of the script to specify:
#      - cruise1: the original cruise prefix (e.g., "p372309")
#      - cruise2: the new cruise prefix to rename to (e.g., "s372309")
#      - dir: the top-level directory to operate in
#	ex: /kakapo/data/xbt/p06/2602/raw/Sio/Data/
#   2. Run the script from inside $dir itself. It then searches $dir's
#      subfolders recursively to find the actual cruise1 source files
#      (which may live a level or more below $dir):
#      cd $dir && ./ren.sh
#
############################################################################
# Edit these variables for each run:
############################################################################
cruise1="p402508"   # starting name
cruise2="p402588"   # what to change to
dir="/home/jbrzensk/XBT/p40/2508/raw/" # need the trailing slash!
############################################################################

orig_dir="${dir}orig_dir/"

echo ""
echo "Renaming files from ${cruise1} to ${cruise2} in: $dir"
echo ""

# Check that the destination directory exists
if [ ! -d "$dir" ]; then
    echo "Error: Destination directory does not exist: $dir"
    exit 1
fi

# Require the script to be run from inside $dir itself. The source-folder
# search below recurses from cwd looking for the cruise1 numbered files,
# so running from the wrong place would have it search (and potentially
# clean up) an unrelated directory tree.
if [ "$(pwd -P)" != "$(cd "$dir" && pwd -P)" ]; then
    echo "Error: This script must be run from inside $dir"
    echo "Current directory: $(pwd)"
    exit 1
fi

# The authoritative sign that $dir has already been processed is the
# presence of renamed cruise2 station files somewhere under it -- check
# that directly, rather than relying on orig_dir alone, since orig_dir
# could be missing (deleted, or this destination was renamed by something
# other than this script) even though the data is already done. Trusting
# orig_dir's absence as "safe to run" is what let a previous run blindly
# reuse a stray leftover cruise1 folder (e.g. a manual "OldName" backup)
# as the source and re-process an already-finished destination.
mapfile -t cruise2_dirs < <(find . -type f -name "${cruise2}e.[0-9][0-9][0-9]" -exec dirname {} \; | sort -u)

if [ "${#cruise2_dirs[@]}" -gt 1 ]; then
    echo "Error: Found ${cruise2}e.NNN files in more than one folder --"
    echo "not sure which is the affected one:"
    printf '  %s\n' "${cruise2_dirs[@]}"
    exit 1
fi

if [ "${#cruise2_dirs[@]}" -eq 1 ]; then
    processed_dir="${cruise2_dirs[0]}"

    if [ ! -d "$orig_dir" ]; then
        echo "Error: $processed_dir already contains ${cruise2}-named station"
        echo "files, but no $orig_dir backup was found. Refusing to run,"
        echo "since there's no way to tell whether it's safe to touch this"
        echo "data. If you're sure it needs to be re-processed, move or"
        echo "remove the existing ${cruise2} files first."
        exit 1
    fi

    # orig_dir exists too -- figure out whether that prior run actually
    # finished (no leftover cruise1 references anywhere) or died partway
    # through.
    if grep -rl "$cruise1" . --exclude-dir=orig_dir 2>/dev/null | grep -q .; then
        echo "Error: $orig_dir exists but $processed_dir still has leftover"
        echo "${cruise1} references in some files -- a previous run must"
        echo "have failed partway through. Cleaning up the incomplete run"
        echo "so it can be retried..."

        cp -p "${orig_dir}"* "${processed_dir}/"
        rm -f "${processed_dir}/${cruise2}"*
        rm -rf "$orig_dir"

        echo "Cleanup complete. Please re-run the script."
        exit 1
    else
        echo "Error: $orig_dir already exists and $processed_dir looks"
        echo "fully processed, which means this script has already been"
        echo "run for this data. Refusing to run again to avoid clobbering"
        echo "the existing backup and files."
        exit 1
    fi
fi

# Locate the directory (anywhere under cwd, at any depth) that actually
# contains the numbered cruise1 station files -- the script may be run
# from a parent folder above where the raw data actually lives.
mapfile -t source_dirs < <(find . -type f -name "${cruise1}e.[0-9][0-9][0-9]" -exec dirname {} \; | sort -u)

if [ "${#source_dirs[@]}" -eq 0 ]; then
    echo "Error: No source files found matching ${cruise1}e.NNN anywhere under $(pwd)"
    exit 1
elif [ "${#source_dirs[@]}" -gt 1 ]; then
    echo "Error: Found ${cruise1}e.NNN files in more than one folder --"
    echo "not sure which is the real source:"
    printf '  %s\n' "${source_dirs[@]}"
    echo "Re-run the script from inside the correct folder."
    exit 1
fi

source_dir="${source_dirs[0]}"
echo "Found source files in: $source_dir"
cd "$source_dir" || exit 1

# Back up a pristine copy of every source file before any edits are made.
mkdir -p "$orig_dir"
echo "Backing up original files to: $orig_dir"
for f in *; do
    [ -f "$f" ] || continue
    cp -p "$f" "$orig_dir"
done

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

    echo "Renaming station $src -> ${cruise2}*${dst}"

    mv "${cruise1}e.${src}" "${cruise2}e.${dst}"
    mv "${cruise1}q.${src}" "${cruise2}q.${dst}"
    mv "${cruise1}s.${src}" "${cruise2}s.${dst}"
    mv "${cruise1}r_${src}.SRP" "${cruise2}r_${dst}.SRP"
done

# Replace every instance of cruise1 with cruise2 inside the files' content,
# in place. The orig_dir backup is left untouched.
echo ""
echo "Updating internal references from ${cruise1} to ${cruise2} in: $source_dir"
for f in *; do
    [ -f "$f" ] || continue
    if grep -q "$cruise1" "$f" 2>/dev/null; then
        sed -i "s/${cruise1}/${cruise2}/g" "$f"
        echo "  updated: $f"
    fi
done

echo ""
echo "Done."
