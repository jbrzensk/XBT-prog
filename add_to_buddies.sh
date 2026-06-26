#!/usr/bin/env bash
# add_to_buddies.sh
# Add a new XBT cruise to the BUDDIES archive and prepend its drop records
# to the master line file.
#
# Run from inside the cruise source directory, e.g.:
#   cd /data/xbt/s37/2410
#   add_to_buddies.sh
#
# LINE and cruise ID are inferred from the .dat file in the current directory.
# If detection fails, the script will prompt for input.
#
# REQUIRES:
#     mklinedat.x
#     **fakecontrol.x - NOT NEEDED, uses function write_fake_control() instead**
#
# Jared Brzenski : June 2026
set -euo pipefail

# =============================================================================
# FIXED CONFIGURATION — do not edit, these are just placeholders
# =============================================================================
readonly ARCHIVE_ROOT="/data1/xbt-archive"
readonly I21_LINE="i21"
readonly I21_TARGET="p15"
# =============================================================================

# Write a minimal control.dat into a destination directory.
# Replaces fakecontrol.x — only called when no real control.dat is present.
# Writes to the archive dir so the source folder is never touched.
write_fake_control() {
    local cruise="$1"
    local dest="$2"
    cat > "${dest}/control.dat" <<EOF
${cruise}
 912 800
15000    0  ega
  90.  -1.  10.   0.
  300.  100.  -.00060   .00050  3.5
 1 0.0 30.0
UNKNOWN
Unknown
 4 1
 10.0 25.0
C: AUTOXBT DATA
C: AUTOXBT
 -1 -2 -3 -4 -5 -6
EOF
}

# =============================================================================
# AUTO-DETECT CRUISE FROM CURRENT DIRECTORY
# =============================================================================
SRC_DIR="$(pwd)"

# Look for a file matching {line}{4-digit-id}.dat (e.g. s372410.dat).
# The pattern requires letters first, then exactly 4 digits before .dat,
# which excludes control.dat, stations.dat, old_* backups, and *a.dat variants.
datfile=$(ls [a-z]*[0-9][0-9][0-9][0-9].dat 2>/dev/null | head -n 1)

if [[ -n "$datfile" ]]; then
    CRUISE="${datfile%.dat}"
    ID="${CRUISE: -4}"
    LINE="${CRUISE:0:${#CRUISE}-4}"
    echo "Detected: cruise=${CRUISE}  line=${LINE}  id=${ID}"
else
    echo "Could not detect cruise from files in ${SRC_DIR}."
    read -rp "Enter cruise name (e.g. s372410): " CRUISE
    if [[ ! "$CRUISE" =~ ^[a-z]+[0-9]{4}$ ]]; then
        echo "Error: cruise name must be letters followed by exactly 4 digits."
        exit 1
    fi
    ID="${CRUISE: -4}"
    LINE="${CRUISE:0:${#CRUISE}-4}"
fi

# Verify required source files are present; warn and offer to abort if not.
if ! ls "${SRC_DIR}/${CRUISE}e."* &>/dev/null; then
    echo "Warning: no e-files found for ${CRUISE} in ${SRC_DIR}."
    read -rp "Continue anyway? [y/N]: " yn
    [[ "${yn,,}" == "y" ]] || exit 1
fi

if [[ ! -f "${SRC_DIR}/${CRUISE}.dat" ]]; then
    echo "Error: ${CRUISE}.dat not found in ${SRC_DIR}."
    exit 1
fi

# =============================================================================
# ARCHIVE
# =============================================================================
ARCH_DIR="${ARCHIVE_ROOT}/${LINE}/${ID}"

echo "=== Processing ${CRUISE} ==="
echo "  Source : ${SRC_DIR}"
echo "  Archive: ${ARCH_DIR}"

mkdir -p "${ARCH_DIR}"

# Copy raw XBT e-files to archive
cp -a "${SRC_DIR}/${CRUISE}e."* "${ARCH_DIR}/"

# For a-lines only: also copy s-files
# cp -a "${SRC_DIR}/${CRUISE}s."* "${ARCH_DIR}/"

# Copy cruise .dat as stations.dat (p09/p38 convention — no separate stations.dat)
cp -a "${SRC_DIR}/${CRUISE}.dat" "${ARCH_DIR}/stations.dat"

# Use real control.dat if present; otherwise write a minimal fake into the
# archive dir only — the source folder is never modified.
if [[ -f "${SRC_DIR}/control.dat" ]]; then
    cp -a "${SRC_DIR}/control.dat" "${ARCH_DIR}/control.dat"
else
    echo "  No control.dat found — writing fake for ${CRUISE}"
    write_fake_control "${CRUISE}" "${ARCH_DIR}"
fi

# mklinedat.x hardcodes its output to ${ARCHIVE_ROOT}/line.dat and reads
# stations.dat from CWD, so clear any stale line.dat and run from ARCH_DIR.
rm -f "${ARCHIVE_ROOT}/line.dat"
(
    cd "${ARCH_DIR}"
    "${ARCHIVE_ROOT}/mklinedat.x" <<EOF
${CRUISE}
EOF
)

# Prepend new cruise records to the master file (new data at top).
# i21 cruises route into p15.dat rather than i21.dat.
if [[ "${LINE}" == "${I21_LINE}" ]]; then
    TARGET_DAT="${ARCHIVE_ROOT}/${I21_TARGET}.dat"
else
    TARGET_DAT="${ARCHIVE_ROOT}/${LINE}.dat"
fi

# Atomic prepend: write new+old into a temp file, then rename over master.
# A plain cp would corrupt TARGET_DAT if interrupted mid-write.
TMPFILE=$(mktemp "${ARCHIVE_ROOT}/line.dat.XXXXXX")
cat "${ARCHIVE_ROOT}/line.dat" "${TARGET_DAT}" > "${TMPFILE}"
mv "${TMPFILE}" "${TARGET_DAT}"
rm -f "${ARCHIVE_ROOT}/line.dat"

echo "=== Done: ${CRUISE} — updated ${TARGET_DAT} ==="
