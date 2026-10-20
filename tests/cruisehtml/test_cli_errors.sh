#!/bin/bash
#=============================================================================#
# test_cli_errors.sh
#
# Checks that cruisehtml.sh fails cleanly: exit status 1, no .html file
# written, and a helpful message on stderr.
#
# Usage:
#   test_cli_errors.sh
#=============================================================================#

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)

fails=0
# expect_error NAME SETUP STDERR_SUBSTRING [ARG]
#   SETUP is "empty" (no files) or an xbtinfo code to link from the fixtures.
expect_error() {
    local name=$1 setup=$2 want=$3
    shift 3
    local W
    W=$(mktemp -d)
    mkdir "$W/run"
    if [[ "$setup" != "empty" ]]; then
        ln -s "$HERE/xbtinfo/xbtinfo.$setup" "$W/run/xbtinfo.$setup"
    fi
    (cd "$W/run" && "$REPO/cruisehtml.sh" "$@") > "$W/out.txt" 2> "$W/err.txt"
    local rc=$?
    local pages
    pages=$(ls "$W"/run/*.html 2>/dev/null | wc -l)

    if [[ $rc -ne 1 ]]; then
        echo "FAIL $name: exit status $rc, expected 1 ($(head -1 "$W/err.txt"))"
        fails=$((fails + 1))
    elif [[ $pages -ne 0 ]]; then
        echo "FAIL $name: $pages html file(s) written"
        fails=$((fails + 1))
    elif ! grep -qF -- "$want" "$W/err.txt"; then
        echo "FAIL $name: stderr lacks [$want]: $(head -1 "$W/err.txt")"
        fails=$((fails + 1))
    else
        echo "ok   $name"
    fi
    rm -rf "$W"
}

expect_error no_args          empty "Usage"
expect_error too_short        empty "Usage"                          p40
expect_error unsupported_code empty "unsupported"                    p812401
expect_error p28_needs_leg    empty "leg letter"                     p282402
expect_error missing_xbtinfo  empty "xbtinfo.p40"                    p402206
expect_error missing_i21_link empty "ln -s xbtinfo.p15 xbtinfo.i21"  i212507
expect_error cruise_not_found p40   "9999"                           p409999

echo "$fails failed"
(( fails == 0 ))
