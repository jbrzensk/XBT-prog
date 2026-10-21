#!/bin/bash
#=============================================================================#
# test_pages.sh
#
# Runs cruisehtml.sh for each case in cases.txt against the frozen xbtinfo
# files in tests/cruisehtml/xbtinfo/, and compares the page with the
# reference page in tests/cruisehtml/expected/<case>/.
#
# The one allowed every-page fix is applied to the reference page before
# comparing: the Next link's <font size=3"> becomes <font size="3">.
#
# Usage:
#   test_pages.sh              # all cases
#   test_pages.sh p40 p22      # only cases whose code (first 3 chars) matches
#=============================================================================#

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
codes=("$@")

# selected <case>: true if no codes were given, or the case's code is listed.
selected() {
    local code
    (( ${#codes[@]} == 0 )) && return 0
    for code in "${codes[@]}"; do
        [[ ${1:0:3} == "$code" ]] && return 0
    done
    return 1
}

pass=0
fail=0
while read -r c; do
    [[ -z "$c" ]] && continue
    selected "$c" || continue

    # Link the fixtures in through a chain, like a real cruise folder:
    # run/xbtinfo.X -> ../links/xbtinfo.X -> fixture (-> xbtinfo.p15 for i15/i21)
    W=$(mktemp -d)
    mkdir "$W/links" "$W/run"
    for f in "$HERE"/xbtinfo/xbtinfo.*; do
        n=$(basename "$f")
        ln -s "$f" "$W/links/$n"
        ln -s "../links/$n" "$W/run/$n"
    done

    (cd "$W/run" && "$REPO/cruisehtml.sh" "$c") > "$W/out.txt" 2> "$W/err.txt"
    rc=$?

    expected=("$HERE/expected/$c"/*.html)
    got=("$W"/run/*.html)
    reason=""
    if [[ $rc -ne 0 ]]; then
        reason="cruisehtml.sh exited $rc: $(head -1 "$W/err.txt")"
    elif [[ ${#got[@]} -ne 1 || ! -f "${got[0]}" ]]; then
        reason="expected 1 html file, found $(ls "$W"/run/*.html 2>/dev/null | wc -l)"
    elif [[ $(basename "${got[0]}") != $(basename "${expected[0]}") ]]; then
        reason="wrote $(basename "${got[0]}"), expected $(basename "${expected[0]}")"
    elif ! sed 's/<font size=3">/<font size="3">/' "${expected[0]}" | cmp -s - "${got[0]}"; then
        reason="page differs from reference"
    fi

    if [[ -z "$reason" ]]; then
        echo "PASS $c"
        pass=$((pass + 1))
    else
        echo "FAIL $c: $reason"
        if [[ "$reason" == "page differs from reference" ]]; then
            diff <(sed 's/<font size=3">/<font size="3">/' "${expected[0]}") "${got[0]}" | head -20
        fi
        fail=$((fail + 1))
    fi
    rm -rf "$W"
done < "$HERE/cases.txt"

if (( pass + fail == 0 )); then
    echo "No cases selected for: ${codes[*]}"
    exit 1
fi
echo "$pass passed, $fail failed"
(( fail == 0 ))
