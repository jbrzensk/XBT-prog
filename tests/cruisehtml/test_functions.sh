#!/bin/bash
#=============================================================================#
# test_functions.sh
#
# Unit tests for the functions in cruisehtml.sh (the script is sourced, so
# main does not run). Uses small synthetic xbtinfo files.
#
# Usage:
#   test_functions.sh
#=============================================================================#

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
source "$REPO/cruisehtml.sh" 2>/dev/null || echo "cannot source $REPO/cruisehtml.sh"

fails=0
# check NAME EXPECTED ACTUAL
check() {
    if [[ "$2" == "$3" ]]; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected [$2] got [$3]"
        fails=$((fails + 1))
    fi
}

# row ID TRACK: one xbtinfo line with the track starting at column 25.
row() { printf '%-24s%s\n' "$1" "$2"; }
header() { printf '%s\n' 'Cr    Day/Mo       JDay Track' '-----------------------------' 'header line 3'; }

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

A="$T/A"
{
    header
    row 0101 SA
    echo '-----------------------------'
    row 0102 SH
    row 0103 AS
    echo ''
    echo '0102 later notes'
} > "$A"

B="$T/B"
{
    header
    row 2402a 'D - H'
    row 2402b 'H - D'
} > "$B"

C="$T/C"
{
    header
    row 2107 SA
    row 2201a SA
    row 2209 SA
} > "$C"

D="$T/D"
{
    header
    for n in $(seq 1 299); do row "$(printf '%04d' "$n")" SA; done
    row 0300 SA
    row 0301 SA
} > "$D"

E="$T/E"
sed 's/$/\r/' "$A" > "$E"

# ---- read_xbtinfo ------------------------------------------------------------
check first_prev_self     "0101 |0102 |SA   " "$(read_xbtinfo "$A" 0101)"
check dash_skipped        "0101 |0103 |SH   " "$(read_xbtinfo "$A" 0102)"
check blank_next_self     "0102 |0103 |AS   " "$(read_xbtinfo "$A" 0103)"
check first_match_wins    "0101 |0103 |SH   " "$(read_xbtinfo "$A" 0102)"
check not_found_status    1                   "$(read_xbtinfo "$A" 9999 >/dev/null; echo $?)"
check not_found_silent    ""                  "$(read_xbtinfo "$A" 9999)"
check p28_leg_match       "2402a|2402b|H - D" "$(read_xbtinfo "$B" 2402b)"
check eof_next_self       "2402a|2402b|H - D" "$(read_xbtinfo "$B" 2402b)"
check four_char_on_leg_id "2107 |2209 |SA   " "$(read_xbtinfo "$C" 2201)"
check scan_line_303_found "0299 |0301 |SA   " "$(read_xbtinfo "$D" 0300)"
check scan_line_304_absent 1                  "$(read_xbtinfo "$D" 0301 >/dev/null; echo $?)"
check crlf_same_as_lf     "0102 |0103 |AS   " "$(read_xbtinfo "$E" 0103)"

echo "$fails failed"
(( fails == 0 ))
