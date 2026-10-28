#!/bin/bash
#=============================================================================#
# compare_live.sh
#
# Compares cruisehtml.sh with the old Fortran cruisehtml.x for every cruise
# listed in the live xbtinfo files. Only useful while cruisehtml.x still
# exists (build it with: make -f cruisehtml.mk).
#
# Prints one line per cruise:
#   MATCH  same page name and bytes (after the allowed Next-link fix)
#   DIFF   different, followed by the diff
#   SKIP   cruisehtml.x wrote no page, or a page with NUL bytes (its own bug)
# then the totals. Exits 1 if any cruise differs.
#
# Usage:
#   compare_live.sh <live xbtinfo dir>
#   compare_live.sh /home/jbrzensk/XBT        # workstation
#   compare_live.sh /data/xbt                 # Savu
#=============================================================================#

if [[ $# -ne 1 || ! -d "$1" ]]; then
    echo "Usage: $0 <live xbtinfo dir>" >&2
    exit 1
fi
LIVE=$(cd "$1" && pwd)
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
X="$REPO/cruisehtml.x"
SH="$REPO/cruisehtml.sh"

if [[ ! -x "$X" ]]; then
    echo "Error: $X not found. Build it with: make -f cruisehtml.mk" >&2
    exit 1
fi

# has_nul <file>: true if the file contains a NUL byte.
has_nul() {
    ! LC_ALL=C tr -d '\000' < "$1" | cmp -s - "$1"
}

# cruise_ids <code>: the cruise IDs in lines 4-303 of xbtinfo.<code>.
cruise_ids() {
    if [[ $1 == p28 ]]; then
        LC_ALL=C awk 'NR > 3 && NR <= 303 && /^[0-9][0-9][0-9][0-9][a-z]/ { print substr($0, 1, 5) }' \
            "$LIVE/xbtinfo.$1" | sort -u
    else
        LC_ALL=C awk 'NR > 3 && NR <= 303 && /^[0-9][0-9][0-9][0-9]/ { print substr($0, 1, 4) }' \
            "$LIVE/xbtinfo.$1" | sort -u
    fi
}

match=0
diffs=0
skip=0
for code in p22 p15 i15 i21 p28 p05 p09 p13 p31 p34 p37 s37 p40; do
    if [[ ! -r "$LIVE/xbtinfo.$code" ]]; then
        echo "NOTE xbtinfo.$code not found in $LIVE - skipping $code"
        continue
    fi
    for id in $(cruise_ids "$code"); do
        c="$code$id"
        W=$(mktemp -d)
        mkdir "$W/x" "$W/sh"
        ln -s "$LIVE/xbtinfo.$code" "$W/x/xbtinfo.$code"
        ln -s "$LIVE/xbtinfo.$code" "$W/sh/xbtinfo.$code"

        (
            cd "$W/x" || exit 1
            if [[ $code == p28 ]]; then
                printf '%s\n%s\n' "${c:0:7}" "$c"
            else
                printf '%s\n' "$c"
            fi | "$X" > "$W/x.log" 2>&1
        )
        (cd "$W/sh" && "$SH" "$c") > "$W/sh.log" 2>&1

        xpage=("$W"/x/*.html)
        spage=("$W"/sh/*.html)
        if [[ ! -f "${xpage[0]}" ]] || has_nul "${xpage[0]}"; then
            echo "SKIP $c (cruisehtml.x output is broken)"
            skip=$((skip + 1))
        elif [[ ! -f "${spage[0]}" ]]; then
            echo "DIFF $c: cruisehtml.sh wrote no page: $(head -1 "$W/sh.log")"
            diffs=$((diffs + 1))
        elif [[ $(basename "${xpage[0]}") != $(basename "${spage[0]}") ]]; then
            echo "DIFF $c: cruisehtml.sh wrote $(basename "${spage[0]}"), cruisehtml.x wrote $(basename "${xpage[0]}")"
            diffs=$((diffs + 1))
        elif ! sed 's/<font size=3">/<font size="3">/' "${xpage[0]}" | cmp -s - "${spage[0]}"; then
            echo "DIFF $c: pages differ"
            diff <(sed 's/<font size=3">/<font size="3">/' "${xpage[0]}") "${spage[0]}" | head -20
            diffs=$((diffs + 1))
        else
            echo "MATCH $c"
            match=$((match + 1))
        fi
        rm -rf "$W"
    done
done

echo "$match MATCH, $diffs DIFF, $skip SKIP"
(( diffs == 0 ))
