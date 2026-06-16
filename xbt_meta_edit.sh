#!/bin/bash
# xbt_meta_edit.sh - Interactive XBT SIO/SRP metadata editor
#
# Usage: xbt_meta_edit.sh [DATA_DIR]
#   DATA_DIR - directory containing p*e.* / p*q.* SIO profile files and *.SRP files
#
# "Metadata" = any field whose value is identical across every file in its set.
# The script discovers consistent fields automatically; only those appear in the menu.
# These values appear in the header of the sio and SRP files.
#
# If you want to change more than one value, just run the program again.
#
# SIO line 1 format:  seq  total_probes  ship_code  probe_type  lat  lon  quality
# SRP format:         " Label: value" key-value pairs
#
# Brzenski 06 Jun 2026
#

# Fail on all errors
set -euo pipefail

# Set the data driectory to the first argument, or current directory if not provided
DATA_DIR="${1:-.}"

# --- Locate pe and SRP files ---
mapfile -t SIO_FILES < <(find "$DATA_DIR" -maxdepth 1 \( -name "p*e.*" -o -name "p*q.*" \) -type f | sort)
mapfile -t SRP_FILES < <(find "$DATA_DIR" -maxdepth 1 -name "*.SRP"  -type f | sort)
SIO_COUNT=${#SIO_FILES[@]}
SRP_COUNT=${#SRP_FILES[@]}

[[ $SIO_COUNT -eq 0 && $SRP_COUNT -eq 0 ]] && {
    echo "No XBT profile or SRP files found in $DATA_DIR"
    exit 1
}

# --- Escape sed replacement string (handles / and &) ---
sed_escape() { printf '%s' "$1" | sed 's/[\/&]/\\&/g'; }

# ============================================================
# SIO candidate fields
# Parallel arrays: name | line# | awk-col | sed ERE pattern
# __NEW__ is substituted with the escaped user value at runtime.
# Patterns anchor to start of line and capture the prefix in \1
# so original whitespace layout is preserved.
# ============================================================
SIO_NAMES=("Probe Code"     "Recorder Code"                     "Callsign")
SIO_LINES=(1                 1                                   1                  )
SIO_COLS=( 2                 3                                   4                  )
SIO_SEDS=(
    '1s/^( *[0-9]+ )([0-9]+)/\1__NEW__/'
    '1s/^( *[0-9]+ +[0-9]+ )(\S+)/\1__NEW__/'
    '1s/^( *[0-9]+ +[0-9]+ +\S+ )(\S+)/\1__NEW__/'
)

# ============================================================
# SRP candidate fields
# Keys use literal-string matching (awk substr), not regex,
# so parens in "Launch Height (Meters):" are not an issue.
# The sed patterns use ERE with \( \) to escape the parens.
# ============================================================
SRP_NAMES=(
    "Ship Name"               "Call Sign"              "Lloyds Number"
    "Probe Type"              "Probe Code"             "Recorder Type"
    "Recorder Code"           "Dry Bulb Temp"          "Wind Instr Type"
    "Wind Speed"              "Wind Dir"               "Current Method"
    "Current Speed"           "Current Dir"            "SOOP Line"
    "XBT Launcher Type"       "Launch Height"          "XBT Recorder Serial No" "XBT Recorder Mfg Date"
    "Agency"                  "Ship Rider"             "Ship Rider Institution"
    "Ship Rider Email"        "Ship Rider Phone"
)
# Literal key labels as they appear in the file (without leading space, without trailing space)
SRP_KEYS=(
    "Ship Name:"                      "Call Sign:"                   "Lloyds Number:"
    "Probe Type:"                     "Probe Code:"                  "Recorder Type:"
    "Recorder Code:"                  "Dry Bulb Temp:"               "Wind Instr Type:"
    "Wind Speed:"                     "Wind Dir:"                    "Current Measurement Method:"
    "Current Speed:"                  "Current Dir:"                 "SOOP Line:"
    "XBT Launcher Type:"              "Launch Height (Meters):"      "XBT Recorder Serial Number:"  "XBT Recorder Manufacture Date:"
    "Agency in charge of Operation:"  "Ship Rider:"                  "Ship Rider Institution:"
    "Ship Rider Email:"               "Ship Rider Telephone Number:"
)
#
# Sed ERE patterns — capture spacing prefix in \1, replace value only.
# "* after colon" handles the variable number of spaces in the file.
# Individual SED patterns for each value. __NEW__ is the replaces value
SRP_SEDS=(
    's/^( *Ship Name: *)[^\r]*/\1__NEW__/'
    's/^( *Call Sign: *)[^\r]*/\1__NEW__/'
    's/^( *Lloyds Number: *)[^\r]*/\1__NEW__/'
    's/^( *Probe Type: *)[^\r]*/\1__NEW__/'
    's/^( *Probe Code: *)[^\r]*/\1__NEW__/'
    's/^( *Recorder Type: *)[^\r]*/\1__NEW__/'
    's/^( *Recorder Code: *)[^\r]*/\1__NEW__/'
    's/^( *Dry Bulb Temp: *)[^\r]*/\1__NEW__/'
    's/^( *Wind Instr Type: *)[^\r]*/\1__NEW__/'
    's/^( *Wind Speed: *)[^\r]*/\1__NEW__/'
    's/^( *Wind Dir: *)[^\r]*/\1__NEW__/'
    's/^( *Current Measurement Method: *)[^\r]*/\1__NEW__/'
    's/^( *Current Speed: *)[^\r]*/\1__NEW__/'
    's/^( *Current Dir: *)[^\r]*/\1__NEW__/'
    's/^( *SOOP Line: *)[^\r]*/\1__NEW__/'
    's/^( *XBT Launcher Type: *)[^\r]*/\1__NEW__/'
    's/^( *Launch Height \(Meters\): *)[^\r]*/\1__NEW__/'
    's/^( *XBT Recorder Serial Number: *)[^\r]*/\1__NEW__/'
    's/^( *XBT Recorder Manufacture Date: *)[^\r]*/\1__NEW__/'
    's/^( *Agency in charge of Operation: *)[^\r]*/\1__NEW__/'
    's/^( *Ship Rider: *)[^\r]*/\1__NEW__/'
    's/^( *Ship Rider Institution: *)[^\r]*/\1__NEW__/'
    's/^( *Ship Rider Email: *)[^\r]*/\1__NEW__/'
    's/^( *Ship Rider Telephone Number: *)[^\r]*/\1__NEW__/'
)

# ============================================================
# Discovery: find which candidate fields are actually metadata
# Unified parallel menu arrays:
#   META_NAMES  META_VALS  META_TYPES(SIO|SRP)  META_SEDS  META_KEYS
# ============================================================
declare -a META_NAMES=() META_VALS=() META_TYPES=() META_SEDS=() META_KEYS=()

# SIO fields
if [[ $SIO_COUNT -gt 0 ]]; then
    for i in "${!SIO_NAMES[@]}"; do
        vals=$(awk -v l="${SIO_LINES[$i]}" -v c="${SIO_COLS[$i]}" \
            'FNR==l { gsub(/\r/,""); print $c }' "${SIO_FILES[@]}" | sort -u)
        [[ -z "$vals" ]] && continue
        n=$(printf '%s\n' "$vals" | grep -c .)
        if [[ $n -eq 1 ]]; then
            META_NAMES+=("${SIO_NAMES[$i]}")
            META_VALS+=("$vals")
            META_TYPES+=("SIO")
            META_SEDS+=("${SIO_SEDS[$i]}")
            META_KEYS+=("")
        fi
    done
fi

# SRP fields — use awk substr() for literal key matching (no regex interpretation)
if [[ $SRP_COUNT -gt 0 ]]; then
    for i in "${!SRP_NAMES[@]}"; do
        key=" ${SRP_KEYS[$i]}"   # prepend space: " Ship Name:"
        klen=${#key}
        lines=$(awk -v key="$key" -v klen="$klen" '
            substr($0, 1, klen) == key {
                val = substr($0, klen + 1)
                gsub(/\r/, "", val)
                gsub(/^[[:space:]]+/, "", val)
                print val
            }
        ' "${SRP_FILES[@]}")
        [[ -z "$lines" ]] && continue
        total=$(printf '%s\n' "$lines" | wc -l | tr -d ' ')
        vals=$(printf '%s\n' "$lines" | sort -u)
        n=$(printf '%s\n' "$vals" | grep -c .)
        if [[ $total -eq $SRP_COUNT ]]; then
            [[ $n -eq 1 ]] && display_val="$vals" || display_val="(${n} different values)"
            META_NAMES+=("${SRP_NAMES[$i]}")
            META_VALS+=("$display_val")
            META_TYPES+=("SRP")
            META_SEDS+=("${SRP_SEDS[$i]}")
            META_KEYS+=("$key")
        fi
    done
fi

# ============================================================
# Show user what the options are
# ============================================================
echo ""
echo "XBT Metadata Editor"
echo "Directory : $DATA_DIR"
printf "SIO files : %d   SRP files : %d\n" "$SIO_COUNT" "$SRP_COUNT"
echo ""
echo "To edit multiple fields, run this code multiple times."
echo ""
echo "Fields:"
echo "[1-3] are ONLY for q and e files."
echo "[4-27] are ONLY for SRP files."
echo ""

if [[ ${#META_NAMES[@]} -eq 0 ]]; then
    echo "No metadata fields found (no field is consistent across all files of its type)."
    exit 0
fi

echo "Metadata:"
echo ""
prev_type=""
for i in "${!META_NAMES[@]}"; do
    if [[ "${META_TYPES[$i]}" != "$prev_type" ]]; then
        printf "  --- %s ---\n" "${META_TYPES[$i]}"
        prev_type="${META_TYPES[$i]}"
    fi
    printf "  [%2d]  %-28s  %s\n" "$((i+1))" "${META_NAMES[$i]}" "${META_VALS[$i]}"
done

echo ""
if [[ $SIO_COUNT -gt 0 ]]; then
    echo "Sample SIO header — $(basename "${SIO_FILES[0]}"):"
    printf "  Line 1: %s\n" "$(awk 'NR==1{gsub(/\r/,"");print}' "${SIO_FILES[0]}")"
    printf "  Line 2: %s\n" "$(awk 'NR==2{gsub(/\r/,"");print}' "${SIO_FILES[0]}")"
    echo ""
fi

# ============================================================
# Choice for user
# ============================================================
TOTAL=${#META_NAMES[@]}
while true; do
    read -rp "Field to edit [1-${TOTAL}], or q to quit: " choice
    [[ "$choice" =~ ^[qQ] ]] && { echo "Quitting."; exit 0; }
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice >= 1 && choice <= TOTAL )); then
        break
    fi
    echo "  Please enter 1-${TOTAL} or q."
done

idx=$((choice - 1))
FILE_TYPE="${META_TYPES[$idx]}"
if [[ "$FILE_TYPE" == "SIO" ]]; then
    TARGET_FILES=("${SIO_FILES[@]}")
    TARGET_COUNT=$SIO_COUNT
else
    TARGET_FILES=("${SRP_FILES[@]}")
    TARGET_COUNT=$SRP_COUNT
fi

echo ""
printf "Field  : %s  (%s)\n" "${META_NAMES[$idx]}" "$FILE_TYPE"
printf "Current: %s\n" "${META_VALS[$idx]}"
read -rp "New value: " NEW_VAL
[[ -z "$NEW_VAL" ]] && { echo "Empty value. Aborting."; exit 0; }

ESCAPED=$(sed_escape "$NEW_VAL")
SED_PATTERN="${META_SEDS[$idx]//__NEW__/$ESCAPED}"

echo ""
printf "Old : %s\n" "${META_VALS[$idx]}"
printf "New : %s\n" "$NEW_VAL"
echo ""
read -rp "Apply to all $TARGET_COUNT ${FILE_TYPE} files? [y/N]: " confirm
[[ "$confirm" != [yY] ]] && { echo "Aborted. No files changed."; exit 0; }

# ============================================================
# Apply the choice
# ============================================================
UPDATED=0
FAILED=0
for f in "${TARGET_FILES[@]}"; do
    if sed -E "$SED_PATTERN" "$f" > "${f}.tmp" 2>/dev/null && mv "${f}.tmp" "$f"; then
        UPDATED=$((UPDATED + 1))
    else
        rm -f "${f}.tmp"
        printf "ERROR: failed to update %s\n" "$f"
        FAILED=$((FAILED + 1))
    fi
done

printf "\nDone. Updated: %d  Failed: %d\n\n" "$UPDATED" "$FAILED"

# ============================================================
# Verify what was selected changed.
# ============================================================
echo "Verification (first file):"
if [[ "$FILE_TYPE" == "SIO" ]]; then
    printf "  Line 1: %s\n" "$(awk 'NR==1{gsub(/\r/,"");print}' "${SIO_FILES[0]}")"
    printf "  Line 2: %s\n" "$(awk 'NR==2{gsub(/\r/,"");print}' "${SIO_FILES[0]}")"
else
    key="${META_KEYS[$idx]}"
    klen=${#key}
    val=$(awk -v key="$key" -v klen="$klen" '
        substr($0, 1, klen) == key {
            val = substr($0, klen + 1)
            gsub(/\r/, "", val)
            gsub(/^[[:space:]]+/, "", val)
            print val
            exit
        }
    ' "${SRP_FILES[0]}")
    printf "  %s  %s\n" "${META_KEYS[$idx]}" "$val"
fi
