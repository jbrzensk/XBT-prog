#!/bin/bash
#=============================================================================#
# cruisehtml.sh
#
# Writes the HRX website page for one XBT cruise into the current directory.
# Replaces the Fortran cruisehtml.f / cruisehtml.x, and writes the same page
# byte for byte, except for the "3" misprint.
#
# It reads the previous and next cruise, and the track letters, from
# xbtinfo.<code> in the current directory (the same rules as rdxbtinfo1.f).
# IX21 cruises read xbtinfo.i21, which should be a link to xbtinfo.p15.
#
# IX21 cruises up to I21_LAST_OLD keep the old names: an i15 page and data in
# ix15. Later IX21 cruises get i21 pages and data in ix21. Previous and next
# links use the name of the cruise they point to.
#
# Usage:
#   cruisehtml.sh <cruise>
#
# Examples:
#   cruisehtml.sh p402508      # PX40 cruise 2508 -> p402508.html
#   cruisehtml.sh i212507      # IX21 cruise 2507 (old names) -> i152507.html
#   cruisehtml.sh i212602      # IX21 cruise 2602 (new names) -> i212602.html
#   cruisehtml.sh p282402a     # IX28 needs the leg letter -> i282402a.html
#
# Brzenski: Oct 2026
#=============================================================================#

SUPPORTED_CODES="p22 p15 i15 i21 p28 p05 p06 p09 p13 p31 p34 p37 s37 p40"

# Last IX21 cruise (YYMM) with the old i15 page name and ix15 data folder.
I21_LAST_OLD=2511

usage() {
    echo "Usage: cruisehtml.sh <cruise>  (e.g. p402508, or p282402a for IX28)" >&2
}

###############################################################################
# read_xbtinfo FILE ID
###############################################################################
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

###############################################################################
# line_settings CODE
###############################################################################
# Sets the per-line page settings as globals. Returns 1 for an unsupported code.
#   PAGE_PREFIX   page file name, include files, previous/next links
#   IMG_PREFIX    station map and temperature plot images
#   DATA_FOLDER, DATA_PREFIX   the .10.gz download link
#   FIXED_LABEL   page label; empty means it's built from the track letters
#   STN_W, STN_H  station map size (exact strings, some padded with a space)
#   TEM_H         temperature plot height
#   SPACER        width of the first spacer cell
line_settings() {
    #               1          2          3           4            5
    # set_line PAGE_PREFIX IMG_PREFIX DATA_FOLDER DATA_PREFIX FIXED_LABEL
    #            6     7     8     9
    #          STN_W STN_H TEM_H SPACER
    case $1 in          #  1   2   3    4    5           6     7    8   9
        p22)     set_line a22 a22 ax22 a22 "AX22"      "155" "152" 244 50 ;;
        p15|i15) set_line i15 i15 ix15 i15 "IX21/IX15" "300" "152" 250 20 ;;
        i21)     set_line i21 i21 ix21 i21 "IX21"      "200" "113" 250 20 ;;
        p28)     set_line i28 i28 ix28 i28 "IX28"      " 90" "155" 250 50 ;;
        p05)     set_line p05 p05 px05 p05 "PX05"      " 78" "152" 250 50 ;;
        p06)     set_line p06 p06 px06 p06 "PX06"      " 95" "152" 251 50 ;;
        p09)     set_line p09 p09 px09 p09 ""          " 95" "152" 251 50 ;;
        p13)     set_line p13 p13 px13 p13 "PX13"      " 95" "152" 251 50 ;;
        p31)     set_line p31 p31 px31 p31 "PX30/31"   "225" "103" 250 50 ;;
        p34)     set_line p34 p34 px34 p34 "PX34"      "240" " 87" 250 50 ;;
        p37)     set_line p37 p37 px37 p37 ""          "187" "115" 252 20 ;;
        s37)     set_line p37 p37 p37s s37 ""          "325" "114" 250 20 ;;
        p40)     set_line p40 p40 px40 p40 "PX40"      "325" "142" 244 20 ;;
        *)       return 1 ;;
    esac
}

set_line() {
    PAGE_PREFIX=$1 IMG_PREFIX=$2 DATA_FOLDER=$3 DATA_PREFIX=$4 FIXED_LABEL=$5
    STN_W=$6 STN_H=$7 TEM_H=$8 SPACER=$9
}

###############################################################################
# i21_old YYMM
###############################################################################
# True if IX21 cruise YYMM is at or before I21_LAST_OLD, so it keeps the old
# names. Years 50-99 are 1900s and 00-49 are 2000s, so 9409 counts as old.
i21_old() {
    local yy=$((10#${1:0:2})) last=$((10#${I21_LAST_OLD:0:2}))
    (( yy >= 50 )) && yy=$((yy - 100))
    (( last >= 50 )) && last=$((last - 100))
    (( yy * 100 + 10#${1:2:2} <= last * 100 + 10#${I21_LAST_OLD:2:2} ))
}

###############################################################################
# page_name CODE ID
###############################################################################
# Prints the page file name for cruise ID on line CODE. Uses PAGE_PREFIX from
# line_settings, except IX21 cruises with old names, which are i15 pages.
page_name() {
    if [[ $1 == i21 ]] && i21_old "$2"; then
        echo "i15$2.html"
    else
        echo "${PAGE_PREFIX}$2.html"
    fi
}

###############################################################################
# track_label CODE TRACK YYMM
###############################################################################
# Prints the page label for lines whose label depends on the ports of call in
# the xbtinfo Track column (rdtrack in rdxbtinfo1.f, nameit in cruisehtml.f).
# Only the first 4 track characters count. With no line names the label is
# just " YYMM", as in the Fortran.
#   p09 ports: A Auckland, E East Cape, H Honolulu, S Suva, W Seattle,
#              F San Francisco, L Los Angeles, T Tahiti, U Tauranga
#   p37 ports: S San Francisco, H Honolulu, G Guam, T Taiwan, K Hong Kong
track_label() {
    local code=$1 ports=${2:0:4} yymm=$3
    local A=0 E=0 H=0 S=0 W=0 F=0 L=0 T=0 U=0 G=0 K=0
    local i c
    for (( i = 0; i < ${#ports}; i++ )); do
        c=${ports:i:1}
        case $c in
            A|E|H|S|W|F|L|T|U|G|K) printf -v "$c" 1 ;;
        esac
    done

    local names=()
    case $code in
        p09)
            local px12=$(( S && T ))
            (( (A || E || U) && S ))       && names+=(PX06)
            (( (A || S) && H || W ))       && names+=(PX09)   # Seattle means PX09/PX39
            (( W ))                        && names+=(PX39)
            (( S && (F || L) && !px12 ))   && names+=(PX31)   # PX12 cancels PX31
            (( px12 ))                     && names+=(PX12)
            (( T && L ))                   && names+=(PX18)
            ;;
        p37)
            (( S && H ))                   && names+=(PX37)
            (( G && H ))                   && names+=(PX10)
            (( (T || K) && G ))            && names+=(PX37)   # the PX44 flag, printed as PX37
            ;;
        s37)
            echo "PX37 South $yymm"
            return 0
            ;;
    esac

    local IFS=/
    if (( ${#names[@]} )); then
        echo "${names[*]} $yymm"
    else
        echo " $yymm"
    fi
}

###############################################################################
# write_page FILE LABEL PREV_PAGE NEXT_PAGE
###############################################################################
# Writes the page from the template below, using the line_settings globals
# plus ID and YYMM. Copied from cruisehtml.x output, trailing spaces included.
# The temperature plot line is padded with 7 spaces, or 3 for IX28 (whose
# 5-character IDs make that line 2 characters longer in the Fortran).
write_page() {
    local LABEL=$2 PREV_PAGE=$3 NEXT_PAGE=$4
    local TEM_PAD="       "
    (( ${#ID} == 5 )) && TEM_PAD="   "
    cat > "$1" <<EOF
<html>
<head>
  <title>Scripps High Resolution XBT/XCTD Network Site</title>
  <link rel=stylesheet href="../style.css" TYPE="text/css" MEDIA=screen>
</head>
<BODY bgcolor="FFFFFF" topmargin="0" leftmargin="0">
<TABLE width="780" border="0" cellpadding="0" cellspacing="0" align="left" valign="top">
  <TR align="left" valign="top">
    <TD align="left" colspan="4">
    <!--#include file="${PAGE_PREFIX}head.html"-->
    </TD>
  </TR>
  
<tr>
    <td valign="top" align="left" rowspan="2" width="3"><img src="../img/blank.gif"></td> 
    <td valign="top" align="left" rowspan="2">
    <!--#include virtual="../nav.html"-->
    </TD>
<td width="7" height="570" align="left" valign="top" rowspan="2">
<img src="../img/linedrop2.jpg"></td>
<!-- right side top of table with station map -->
<td valign="top" align="center" width="660">
  <table width="660" border="0" col="2"  valign="top" align="center"> 
  <tr align="left">
    <td width=300 valign="top" align="center">
      <table width=300 align="center" valign="top" border="0">
      <tr>
        <td width="${SPACER}"> &nbsp;</td>
        <td align="left">
        <font size="4" color="red">${LABEL}</font></td>
        <td width="40"> &nbsp;</td></tr>
      <tr>
        <td width="20"> &nbsp;</td>
        <td align="left" colspan="2">
        <a href="../www-hrx/${DATA_FOLDER}/${DATA_PREFIX}${YYMM}a.10.gz">
        <font size="3">Download 10m average data</a>
        </TD>
      </TR>
      <tr>
      <td width="20"> &nbsp;</td>
        <td align="left">
        <a href="${PREV_PAGE}"><font size="3">Previous cruise</a></td>
        <td width="40"> &nbsp;</td></tr>
      <tr>
        <td width="20"> &nbsp;</td>
        <td align="left">
        <a href="${NEXT_PAGE}"><font size="3">Next cruise</a></td>
        <td width="40"> &nbsp;</td></tr>
      <tr>
        <td width="20"> &nbsp;</td>
        <td align="center">
        <font size="3" color="black"> &nbsp;</font></td>
        <td width="40"> &nbsp;</td></tr>
      </table>
    </TD>
<td width="350" valign="center" align="center">
  <a href="img/${IMG_PREFIX}${ID}s-b.gif"><img src="img/${IMG_PREFIX}${ID}s-s.gif"
  alt="station map" width="${STN_W}" height="${STN_H}"
  border="0"></a> </td></tr>
<tr align="center">
  <td colspan="2"><a href="img/${IMG_PREFIX}${ID}t-b.gif"><img src="img/${IMG_PREFIX}${ID}t-s.gif"${TEM_PAD}
  alt="temperature plot" width="500"
  height="${TEM_H}" border="0"></a></td></tr>
<tr>
<td colspan="2">
<!--#include file="${PAGE_PREFIX}table.html" -->
</TD>
</TR>
</table>
</TD>
</TR>
</table>
</body>
</html>
EOF
}

###############################################################################
# Main Script Launch
###############################################################################
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
    if ! line_settings "$code"; then
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

    local prev=${info%%|*}
    local rest=${info#*|}
    local next=${rest%%|*}
    local track=${rest#*|}

    ID=$id
    YYMM=${cruise:3:4}
    local label
    if [[ -n "$FIXED_LABEL" ]]; then
        label=" $FIXED_LABEL $ID"
    else
        label=$(track_label "$code" "$track" "$YYMM")
    fi

    local page prev_page next_page
    page=$(page_name "$code" "$ID")
    prev_page=$(page_name "$code" "${prev:0:${#ID}}")
    next_page=$(page_name "$code" "${next:0:${#ID}}")
    # Old-name IX21 cruises also keep the i15 include files and ix15 data.
    if [[ $code == i21 ]] && i21_old "$ID"; then
        PAGE_PREFIX=i15
        DATA_FOLDER=ix15
    fi
    if ! write_page "$page" "$label" "$prev_page" "$next_page"; then
        rm -f "$page"
        echo "Error: could not write $page in $PWD." >&2
        return 1
    fi
    echo "Wrote $page"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
    exit $?
fi
