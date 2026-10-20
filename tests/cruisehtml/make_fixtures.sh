#!/bin/bash
#=============================================================================#
# make_fixtures.sh
#
# One-time generator for the cruisehtml.sh tests. Run it with the old
# Fortran cruisehtml.x still built in the repo root.
#
#   1. Trims the live xbtinfo files into tests/cruisehtml/xbtinfo/, keeping
#      only the columns cruisehtml reads (1-5 cruise, 25-29 track,
#      73-75 ship). Observer names and other details are blanked.
#   2. Runs cruisehtml.x for every case in cases.txt against the trimmed
#      files and saves the page to tests/cruisehtml/expected/<case>/.
#   3. Checks each page is byte-identical to the page made from the live
#      files, and has no NUL bytes.
#
# Usage:
#   make_fixtures.sh <live xbtinfo dir>
#   make_fixtures.sh /home/jbrzensk/XBT
#=============================================================================#

if [[ $# -ne 1 || ! -d "$1" ]]; then
    echo "Usage: $0 <live xbtinfo dir>" >&2
    exit 1
fi
LIVE=$(cd "$1" && pwd)
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
X="$REPO/cruisehtml.x"

if [[ ! -x "$X" ]]; then
    echo "Error: $X not found. Build it with: make -f cruisehtml.mk" >&2
    exit 1
fi

FIX="$HERE/xbtinfo"
EXP="$HERE/expected"
mkdir -p "$FIX" "$EXP"

# ---- 1. Trim the xbtinfo files ----------------------------------------------
for code in p22 p15 p28 p05 p09 p13 p31 p34 p37 s37 p40; do
    src="$LIVE/xbtinfo.$code"
    if [[ ! -f "$src" ]]; then
        echo "Error: $src not found." >&2
        exit 1
    fi
    LC_ALL=C awk '{
        out = sprintf("%-5s%19s%-5s%43s%s", substr($0,1,5), "", \
                      substr($0,25,5), "", substr($0,73,3))
        sub(/ +$/, "", out)
        print out
    }' "$src" > "$FIX/xbtinfo.$code"
done
ln -sfn xbtinfo.p15 "$FIX/xbtinfo.i15"
ln -sfn xbtinfo.p15 "$FIX/xbtinfo.i21"
echo "Trimmed xbtinfo files written to $FIX"

# ---- 2. and 3. Reference pages ----------------------------------------------
# run_x <work dir> <xbtinfo dir> <case>: run cruisehtml.x for one case.
run_x() {
    local dir=$1 src=$2 c=$3
    local code=${c:0:3}
    ln -s "$src/xbtinfo.$code" "$dir/xbtinfo.$code"
    (
        cd "$dir" || exit 1
        if [[ $code == p28 ]]; then
            printf '%s\n%s\n' "${c:0:7}" "$c"
        else
            printf '%s\n' "$c"
        fi | "$X" > "$dir/../$(basename "$dir").log" 2>&1
    )
}

# has_nul <file>: true if the file contains a NUL byte.
has_nul() {
    ! LC_ALL=C tr -d '\000' < "$1" | cmp -s - "$1"
}

status=0
count=0
while read -r c; do
    [[ -z "$c" ]] && continue
    work=$(mktemp -d)
    mkdir "$work/trim" "$work/live"
    run_x "$work/trim" "$FIX" "$c"
    run_x "$work/live" "$LIVE" "$c"

    trim_pages=("$work"/trim/*.html)
    live_pages=("$work"/live/*.html)
    if [[ ${#trim_pages[@]} -ne 1 || ! -f "${trim_pages[0]}" ]]; then
        echo "FAIL $c: expected one page from trimmed files" >&2
        status=1
    elif [[ ${#live_pages[@]} -ne 1 || ! -f "${live_pages[0]}" ]]; then
        echo "FAIL $c: expected one page from live files" >&2
        status=1
    elif [[ $(basename "${trim_pages[0]}") != $(basename "${live_pages[0]}") ]]; then
        echo "FAIL $c: page names differ between trimmed and live files" >&2
        status=1
    elif ! cmp -s "${trim_pages[0]}" "${live_pages[0]}"; then
        echo "FAIL $c: trimmed and live pages differ" >&2
        diff "${live_pages[0]}" "${trim_pages[0]}" >&2
        status=1
    elif has_nul "${trim_pages[0]}"; then
        echo "FAIL $c: page contains NUL bytes" >&2
        status=1
    else
        mkdir -p "$EXP/$c"
        rm -f "$EXP/$c"/*.html
        cp "${trim_pages[0]}" "$EXP/$c/"
        count=$((count + 1))
    fi
    rm -rf "$work"
done < "$HERE/cases.txt"

echo "Reference pages written: $count"
exit $status
