#!/bin/bash
#=============================================================================#
# test_fixtures.sh
#
# Checks the trimmed xbtinfo fixtures keep nothing cruisehtml doesn't read,
# so no observer names (or pieces of them) end up in the repo:
#   - cruise lines (starting with 4 digits): only columns 1-5, 25-29 and
#     73-75 may be non-blank
#   - every other line (headers, notes, observer lists): only columns 1-5
#
# Usage:
#   test_fixtures.sh
#=============================================================================#

HERE=$(cd "$(dirname "$0")" && pwd)

bad=$(LC_ALL=C awk '
    /^[0-9][0-9][0-9][0-9]/ {
        if (length($0) > 75 || substr($0, 6, 19) ~ /[^ ]/ || substr($0, 30, 43) ~ /[^ ]/)
            print FILENAME ":" FNR ": " $0
        next
    }
    length($0) > 5 { print FILENAME ":" FNR ": " $0 }
' "$HERE"/xbtinfo/xbtinfo.[ps]*)

if [[ -n "$bad" ]]; then
    echo "$bad" | head -10
    echo "FAIL $(echo "$bad" | wc -l) fixture line(s) keep text cruisehtml doesn't read"
    exit 1
fi
echo "ok   fixtures keep only the columns cruisehtml reads"
