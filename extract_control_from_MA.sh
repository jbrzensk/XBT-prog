#!/bin/bash
#=============================================================================#
# extract_control_from_MA.sh
# Extracts cruise metadata from a ma2txt.pl (MEDSASCII) output (.txt) file.
# Dynamically parses the first station header and surface code fields
# into bash variables, regardless of how many surface codes are present
# or what order they appear in.
#
# Usage: extract_control_from_MA.sh <input.txt>
#
# Brzenski: Feb 2026
#=============================================================================#

set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <input.txt>"
    exit 1
fi

INFILE="$1"

if [[ ! -f "$INFILE" ]]; then
    echo "Error: File '$INFILE' not found."
    exit 1
fi

# Read the first station header into an array
# Lines 1-7 are fixed, line 8 is NSURFC, then NSURFC surface code lines follow
mapfile -t lines < <(head -200 "$INFILE")

# Lines 1-7: fixed header fields (array is 0-indexed)
STATION_NUM=$(echo "${lines[0]}" | tr -d '[:space:]')
OBS_YEAR=$(echo "${lines[1]}" | tr -d '[:space:]')
OBS_MONTH=$(echo "${lines[2]}" | tr -d '[:space:]')
OBS_DAY=$(echo "${lines[3]}" | tr -d '[:space:]')
OBS_TIME=$(echo "${lines[4]}" | tr -d '[:space:]')
LATITUDE=$(echo "${lines[5]}" | tr -d '[:space:]')
LONGITUDE=$(echo "${lines[6]}" | tr -d '[:space:]')
NSURFC=$(echo "${lines[7]}" | tr -d '[:space:]')

# Dynamically parse surface code lines (lines 9 through 8+NSURFC)
# Each line is "CODE    value" — match by the 4-char code name
declare -A SURFC
for (( i=0; i<NSURFC; i++ )); do
    idx=$(( 8 + i ))
    code=$(echo "${lines[$idx]}" | awk '{print $1}')
    value=$(echo "${lines[$idx]}" | awk '{print $2}')
    SURFC["$code"]="$value"
done

# Map known surface codes to named variables for convenience
CSID="${SURFC[CSID]:-}"
GCLL="${SURFC[GCLL]:-}"
PEQS="${SURFC[PEQ\$]:-}"
RCTS="${SURFC[RCT\$]:-}"
OFFS="${SURFC[OFFS]:-}"
SCAL="${SURFC[SCAL]:-}"
SER_NUM="${SURFC[SER#]:-}"
MFD_NUM="${SURFC[MFD#]:-}"
HTLS="${SURFC[HTL\$]:-}"
CRCS="${SURFC[CRC\$]:-}"
TWI_NUM="${SURFC[TWI#]:-}"
SHP_NUM="${SURFC[SHP#]:-}"
VERS="${SURFC[VERS]:-}"
FVRS="${SURFC[FVRS]:-}"
HVRS="${SURFC[HVRS]:-}"
SER1="${SURFC[SER1]:-}"
UVRS="${SURFC[UVRS]:-}"

# Derived fields
CRUISE_YY="${OBS_YEAR:2:2}"
LINE_NUM=$(echo "$TWI_NUM" | sed 's/^[A-Z]*//')
CRUISE_NAME="p${LINE_NUM}${CRUISE_YY}${OBS_MONTH}"

# Count total drops
NUM_STATIONS=$(grep -c '^END$' "$INFILE")

# Extract the LAST station's header
# Find line numbers of all END markers, then the last station starts after
# the second-to-last END
mapfile -t end_lines < <(grep -n '^END$' "$INFILE" | cut -d: -f1)
num_ends=${#end_lines[@]}

if (( num_ends > 1 )); then
    # Last station starts on the line after the second-to-last END
    last_sta_start=$(( end_lines[num_ends - 2] + 1 ))
else
    # Only one station — first and last are the same
    last_sta_start=1
fi

# Read the last station header (up to 200 lines from that point)
mapfile -t last_lines < <(sed -n "${last_sta_start},$((last_sta_start + 199))p" "$INFILE")

LAST_STATION_NUM=$(echo "${last_lines[0]}" | tr -d '[:space:]')
LAST_OBS_YEAR=$(echo "${last_lines[1]}" | tr -d '[:space:]')
LAST_OBS_MONTH=$(echo "${last_lines[2]}" | tr -d '[:space:]')
LAST_OBS_DAY=$(echo "${last_lines[3]}" | tr -d '[:space:]')
LAST_OBS_TIME=$(echo "${last_lines[4]}" | tr -d '[:space:]')
LAST_LATITUDE=$(echo "${last_lines[5]}" | tr -d '[:space:]')
LAST_LONGITUDE=$(echo "${last_lines[6]}" | tr -d '[:space:]')
LAST_NSURFC=$(echo "${last_lines[7]}" | tr -d '[:space:]')

# Dynamically parse last station's surface codes
declare -A LAST_SURFC
for (( i=0; i<LAST_NSURFC; i++ )); do
    idx=$(( 8 + i ))
    code=$(echo "${last_lines[$idx]}" | awk '{print $1}')
    value=$(echo "${last_lines[$idx]}" | awk '{print $2}')
    LAST_SURFC["$code"]="$value"
done

# Output results
echo "============================================="
echo " Cruise Information extracted from:"
echo " $INFILE"
echo "============================================="
echo ""
echo "--- First Station Header ---"
echo "STATION_NUM  = ${STATION_NUM}"
echo "OBS_YEAR     = ${OBS_YEAR}"
echo "OBS_MONTH    = ${OBS_MONTH}"
echo "OBS_DAY      = ${OBS_DAY}"
echo "OBS_TIME     = ${OBS_TIME}"
echo "LATITUDE     = ${LATITUDE}"
echo "LONGITUDE    = ${LONGITUDE}"
echo "NSURFC       = ${NSURFC}"
echo ""
echo "--- First Station Surface Codes (${NSURFC} found) ---"
for code in "${!SURFC[@]}"; do
    printf "%-12s = %s\n" "$code" "${SURFC[$code]}"
done | sort
echo ""
echo "--- Last Station Header (station ${LAST_STATION_NUM}) ---"
echo "STATION_NUM  = ${LAST_STATION_NUM}"
echo "OBS_YEAR     = ${LAST_OBS_YEAR}"
echo "OBS_MONTH    = ${LAST_OBS_MONTH}"
echo "OBS_DAY      = ${LAST_OBS_DAY}"
echo "OBS_TIME     = ${LAST_OBS_TIME}"
echo "LATITUDE     = ${LAST_LATITUDE}"
echo "LONGITUDE    = ${LAST_LONGITUDE}"
echo "NSURFC       = ${LAST_NSURFC}"
echo ""
echo "--- Last Station Surface Codes (${LAST_NSURFC} found) ---"
for code in "${!LAST_SURFC[@]}"; do
    printf "%-12s = %s\n" "$code" "${LAST_SURFC[$code]}"
done | sort
echo ""
echo "--- Derived Fields ---"
echo "CRUISE_NAME  = ${CRUISE_NAME}"
echo "NUM_STATIONS = ${NUM_STATIONS}"
echo "============================================="
