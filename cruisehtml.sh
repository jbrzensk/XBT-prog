#!/bin/bash
#=============================================================================#
# cruisehtml.sh
#
# Writes the HRX website page for one XBT cruise into the current directory.
# Replaces the Fortran cruisehtml.f / cruisehtml.x, and writes the same page
# byte for byte, with one deliberate fix that is the same on every page:
#
#   - The Next link's <font size=3"> is written as <font size="3">.
#
# It reads the previous and next cruise, and the track letters, from
# xbtinfo.<code> in the current directory (the same rules as rdxbtinfo1.f).
# IX21 cruises read xbtinfo.i21, which should be a link to xbtinfo.p15.
#
# Usage:
#   cruisehtml.sh <cruise>
#
# Examples:
#   cruisehtml.sh p402508      # PX40 cruise 2508 -> p402508.html
#   cruisehtml.sh i212507      # IX21 cruise 2507 -> i152507.html
#   cruisehtml.sh p282402a     # IX28 needs the leg letter -> i282402a.html
#
# Brzenski: Oct 2026
#=============================================================================#

SUPPORTED_CODES="p22 p15 i15 i21 p28 p05 p09 p13 p31 p34 p37 s37 p40"

usage() {
    echo "Usage: cruisehtml.sh <cruise>  (e.g. p402508, or p282402a for IX28)" >&2
}

# read_xbtinfo FILE ID
# Prints "PREV|NEXT|TRACK" for cruise ID (YYMM, or YYMML for p28), each field
# padded to 5 characters. Returns 1, printing nothing, if ID isn't found.
#   - Lines 1-3 are headers; only lines 4-303 are searched (as rdxbtinfo1.f).
#   - Lines starting with ----- are skipped.
#   - PREV is the line before the match, or the cruise itself if it's first.
#   - NEXT is the line after the match, or the cruise itself if that line is
#     blank or the file ends.
read_xbtinfo() {
    LC_ALL=C awk -v id="$2" '
        function id5(s) { return sprintf("%-5s", substr(s, 1, 5)) }
        { sub(/\r$/, "") }
        NR <= 3 { next }
        !found {
            if (NR > 303) exit 1
            if (substr($0, 1, 5) == "-----") next
            if (substr($0, 1, length(id)) == id) {
                found = 1
                me = id5($0)
                prev = seen ? last : me
                track = sprintf("%-5s", substr($0, 25, 5))
                next
            }
            last = id5($0)
            seen = 1
            next
        }
        {
            if (substr($0, 1, 5) == "-----") next
            nxt = id5($0)
            if (substr(nxt, 1, 4) == "    ") nxt = me
            exit
        }
        END {
            if (!found) exit 1
            if (nxt == "") nxt = me
            printf "%s|%s|%s\n", prev, nxt, track
        }
    ' "$1"
}

main() {
    if [[ $# -ne 1 ]]; then
        usage
        return 1
    fi
    local cruise=$1
    local code=${cruise:0:3}

    if [[ $cruise =~ ^p28[0-9]{4}$ ]]; then
        echo "Error: IX28 cruise names need the leg letter, e.g. p282402a (got $cruise)." >&2
        return 1
    fi
    if ! [[ $cruise =~ ^[psi][0-9]{6}$ || $cruise =~ ^p28[0-9]{4}[a-z]$ ]]; then
        usage
        return 1
    fi
    if [[ " $SUPPORTED_CODES " != *" $code "* ]]; then
        echo "Error: unsupported cruise code $code. Supported: $SUPPORTED_CODES" >&2
        return 1
    fi

    local xbtinfo="xbtinfo.$code"
    if [[ ! -r "$xbtinfo" ]]; then
        echo "Error: $xbtinfo not found in $PWD." >&2
        if [[ $code == i21 ]]; then
            echo "IX21 uses xbtinfo.p15. Create the link next to xbtinfo.p15 with:" >&2
            echo "  ln -s xbtinfo.p15 xbtinfo.i21" >&2
        fi
        return 1
    fi

    local id=${cruise:3}
    local info
    if ! info=$(read_xbtinfo "$xbtinfo" "$id"); then
        echo "Error: cruise $id not found in $xbtinfo (searched lines 4-303)." >&2
        echo "Add the cruise to the xbtinfo file and run this again." >&2
        return 1
    fi

    echo "Error: page writing not implemented yet." >&2
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
    exit $?
fi
