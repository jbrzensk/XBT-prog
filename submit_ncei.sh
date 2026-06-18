#!/usr/bin/env bash
#####################################################################
# submit_ncei.sh - Package and submit XBT cruise data to NODC
#
# Description:
#   Replaces the manual cpq.sh workflow. For each cruise, builds
#   the SIO submission package directory, auto-fills the README
#   template, tars/gzips, and deploys to the SFTP staging area.
#
# Usage:
#   submit_ncei.sh <line> <cruise_id> [cruise_id2 ...]
#
# Examples:
#   submit_ncei.sh p40 2508
#   submit_ncei.sh p40 2202 2206 2211
#
# Run from: /kakapo/data/xbt/ncei/
#
# Requires:
#   README_SIO_<line>.txt   template in current directory
#   format_nav.txt          nav format file in current directory
#   /kakapo/data/xbt/<line>/<cruise>/   source data for each cruise
#
# BRZENSKI June 2026
#####################################################################

set -o pipefail

DATA_ROOT="/kakapo/data/xbt"
SFTP_DIR="/argo-project/pub/sftp_hrx/for_nodc" # argo can't change nodc to ncei
SUBMITTED_DIR="submitted"   # relative to ncei/ working directory
CALLSIGN_FILE="/kakapo/data/xbt/callsign.txt"

# BRZENSKI Testing
#DATA_ROOT="/home/jbrzensk/XBT"
#CALLSIGN_FILE="/home/jbrzensk/XBT/callsign.txt"

# ---- Argument check -------------------------------------------------

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <line> <cruise_id> [cruise_id2 ...]"
    echo "Example: $0 p40 2508"
    echo "Example: $0 p40 2202 2206 2211"
    exit 1
fi

LINE="$1"
shift
CRUISES=("$@")
LINE_NUM="${LINE:1}"   # p40 → 40

# ---- Preflight checks -----------------------------------------------

if [[ ! -w "." ]]; then
    echo "Error: current directory is not writable."
    echo "Run from /kakapo/data/xbt/ncei/"
    exit 1
fi

if [[ ! -d "$SFTP_DIR" ]]; then
    echo "Error: SFTP staging directory not found: ${SFTP_DIR}"
    exit 1
fi

if [[ ! -f "README_SIO_${LINE}.txt" ]]; then
    echo "Error: README template 'README_SIO_${LINE}.txt' not found in current directory."
    exit 1
fi

# ---- Archive existing SIO packages (skip ones we are about to build) -------

for existing_pkg in SIO_* ; do
    [[ -d "$existing_pkg" ]] || continue
    # Skip any package that is part of this run — it may be a partial build
    is_current=false
    for c in "${CRUISES[@]}"; do
        [[ "$existing_pkg" == "SIO_${LINE}${c}" ]] && is_current=true && break
    done
    $is_current && continue
    mkdir -p "${SUBMITTED_DIR}"
    mv "$existing_pkg" "${SUBMITTED_DIR}/"
    echo "  Archived ${existing_pkg} to ${SUBMITTED_DIR}/"
done

# ---- Helper: extract field value from SRP files ---------------------
# Searches recursively in <dir> for lines containing <key>, returns the
# value after ': ' on the first matching line.
srp_field() {
    local key="$1"
    local dir="$2"
    grep -rhi "$key" "$dir" 2>/dev/null \
        | head -1 \
        | awk -F': ' '{gsub(/^[ \t]+|[ \t\r]+$/, "", $2); print $2}'
}

# ---- Helper: escape string for use in sed replacement ---------------
sed_escape() {
    printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

# ====================================================================
# Process each cruise
# ====================================================================

for cruise in "${CRUISES[@]}"; do
    echo ""
    echo "========================================================"
    echo " Processing: ${LINE}${cruise}"
    echo "========================================================"

    pkg_dir="SIO_${LINE}${cruise}"
    src="${DATA_ROOT}/${LINE}/${cruise}"

    if [[ ! -d "${src}" ]]; then
        echo "Error: source data directory not found: ${src}"
        exit 1
    fi

    # ---- Build package (skip if already exists from a previous attempt) ----
    if [[ -d "${pkg_dir}" ]]; then
        echo "  '${pkg_dir}' already exists — skipping file copy, will redo README."
        # Restore execute on subdirectories in case a previous run corrupted them
        find "${pkg_dir}" -maxdepth 1 -type d -exec chmod u+x {} \;
    else
        mkdir "${pkg_dir}"

        # Copy data files (preserve timestamps)
        q_files=("${src}/raw/${LINE}${cruise}q."*)
        if [[ ! -e "${q_files[0]}" ]]; then
            echo "Error: no q-files found at ${src}/raw/${LINE}${cruise}q.*"
            exit 1
        fi
        cp -p "${q_files[@]}" "${pkg_dir}/"

        if [[ ! -f "${src}/${LINE}${cruise}.dat" ]]; then
            echo "Error: dat file not found: ${src}/${LINE}${cruise}.dat"
            exit 1
        fi
        cp -p "${src}/${LINE}${cruise}.dat" "${pkg_dir}/"

        cp -p "${src}/"*Met* "${pkg_dir}/" 2>/dev/null \
            || echo "  Note: no MetObs file found — skipping."

        # chmod only regular files — never directories (cals/ nav/ need execute)
        find "${pkg_dir}" -maxdepth 1 -type f -exec chmod a-x {} \;

        # Copy and clean cals
        mkdir "${pkg_dir}/cals"
        cals_src=""
        for cals_name in Cals Cal cal cals; do
            if [[ -d "${src}/${cals_name}" ]]; then
                cals_src="${src}/${cals_name}"
                break
            fi
        done

        if [[ -n "$cals_src" ]]; then
            cp -p -r "${cals_src}/"* "${pkg_dir}/cals/"
            echo "  Copied cals from ${cals_src}"

            # Remove known garbage files (keep stations.dat)
            # (
            #     cd "${pkg_dir}/cals" || exit 1
            #     rm -f -- */*.log          *.log                     \
            #               */*.log.txt     *.log.txt                  \
            #               */chkprof*      chkprof*                   \
            #               */control.dat                              \
            #               */sst.dat                                  \
            #               */navtrk.dat                               \
            #               */*.bmp         *.bmp                      \
            #               desk*           */desk*                    \
            #               *.png           *.PNG                      \
            #               */*.png         */*.PNG                    \
            #               */*.jpg         */*.JPG                    \
            #               */CallSequence.txt                         \
            #               */stationsExtension.dat                    \
            #               */*.nav                                    \
            #               */*.zip                                    \
            #               */p*s.*         2>/dev/null || true
            # )
        else
            echo "  Warning: no cals directory found in ${src}/ — cals/ will be empty."
        fi

        # Copy nav files
        mkdir "${pkg_dir}/nav"
        nav_count=$(ls "${src}/raw/"*.nav 2>/dev/null | wc -l)
        if (( nav_count > 0 )); then
            cp -p "${src}/raw/"*.nav "${pkg_dir}/nav/"
            chmod u+r "${pkg_dir}/nav/"*.nav  # source files may have restrictive permissions
            echo "  Copied ${nav_count} .nav file(s)."
        else
            echo "  Warning: no .nav files found in ${src}/raw/"
        fi
        [[ -f "format_nav.txt" ]] && cp "format_nav.txt" "${pkg_dir}/nav/"
    fi

    # ---- Auto-fill README template ----------------------------------
    readme="${pkg_dir}/README_SIO_${LINE}${cruise}.txt"
    cp "README_SIO_${LINE}.txt" "${readme}"

    # Derived fields
    yy="${cruise:0:2}"
    mm="${cruise:2:2}"
    month_name=$(date -d "20${yy}-${mm}-01" +"%B" 2>/dev/null || echo "Unknown")
    submit_date=$(date +"%d %B %Y")

    # Ship name from control.dat
    Ship_Name=$(awk -F'=' '/^Ship Name/{gsub(/^[ \t]+|[ \t\r]+$/, "", $2); print $2}' \
                    "${src}/control.dat" 2>/dev/null)
    if [[ -z "$Ship_Name" ]]; then
        read -rp "  Ship Name not found in control.dat. Enter ship name: " Ship_Name
    fi

    # Callsign from callsign.txt
    callsign=""
    if [[ -f "$CALLSIGN_FILE" && -n "$Ship_Name" ]]; then
        callsign=$(grep -i "$Ship_Name" "$CALLSIGN_FILE" 2>/dev/null | awk '{print $2}' | head -1)
    fi
    if [[ -z "$callsign" ]]; then
        read -rp "  Callsign for '${Ship_Name}' not found. Enter callsign: " callsign
    fi

    # Autolauncher height from SRP files
    al_height=$(srp_field "Launch Height" "${pkg_dir}/cals")
    if [[ -z "$al_height" ]]; then
        read -rp "  Autolauncher height (meters): " al_height
    fi

    # Recorder serial number from SRP files ("XBT Recorder Serial Number: 00760")
    recorder_sn=$(srp_field "XBT Recorder Serial Number" "${pkg_dir}/cals")
    recorder_sn=$(printf '%s' "$recorder_sn" | sed 's/^0*//')  # strip leading zeros
    if [[ -z "$recorder_sn" ]]; then
        read -rp "  Recorder (MK-21) Serial Number: " recorder_sn
    fi

    # SEAS version from SRP files ("SEAS Version: 9.30")
    seas_version=$(srp_field "SEAS Version" "${pkg_dir}/cals")
    if [[ -z "$seas_version" ]]; then
        read -rp "  SEAS Version: " seas_version
    fi

    echo "  Ship=${Ship_Name}  Callsign=${callsign}  AL=${al_height}m  SN=${recorder_sn}  SEAS=${seas_version}"

    # Escape values for safe sed replacement
    cruise_line="$(sed_escape "${LINE}${cruise} (PX${LINE_NUM}, ${month_name} 20${yy})")"
    Ship_Name_e="$(sed_escape "${Ship_Name}")"
    callsign_e="$(sed_escape "${callsign}")"
    al_height_e="$(sed_escape "${al_height}")"
    recorder_sn_e="$(sed_escape "${recorder_sn}")"
    seas_version_e="$(sed_escape "${seas_version}")"
    submit_date_e="$(sed_escape "${submit_date}")"

    sed -i "1s/.*/${submit_date_e}/"                                              "${readme}"
    sed -i "2s/.*/${cruise_line}/"                                                "${readme}"
    sed -i "s/\(Autolauncher height (meters)=\).*/\1 ${al_height_e}/"            "${readme}"
    sed -i "s/\(Ship Name=\).*/\1 ${Ship_Name_e}/"                               "${readme}"
    sed -i "s/\(Call Sign=\).*/\1 ${callsign_e}/"                                "${readme}"
    sed -i "s/\(Recorder Serial Number=\).*/\1   ${recorder_sn_e}/"              "${readme}"
    sed -i "s/\(SEAS Version=\).*/\1 ${seas_version_e}/"                         "${readme}"

    # Open for user review
    echo "  Opening README for review..."
    ${EDITOR:-vi} "${readme}"

done

# ====================================================================
# Package, deploy, and log
# ====================================================================

echo ""
echo "Packaging..."
for dir in SIO_${LINE}*; do
    [[ -d "$dir" ]] || continue
    tar cvf "${dir}.tar" "${dir}"
    gzip "${dir}.tar"
    echo "  Created ${dir}.tar.gz"
done

echo ""
echo "Deploying to ${SFTP_DIR}..."
if ! ls ./*.tar.gz &>/dev/null; then
    echo "Error: no .tar.gz files found to deploy."
    exit 1
fi
mv ./*.tar.gz "${SFTP_DIR}/"
echo "  Done."

echo ""
echo "Updating README-submitted..."
submit_log_date=$(date +"%d%b%Y" | tr '[:upper:]' '[:lower:]')
for cruise in "${CRUISES[@]}"; do
    year="20${cruise:0:2}"
    echo "${LINE} ${year} ${cruise}  ${submit_log_date}  all metadata-q+ht  +cals,nav,metobs,mk21sn" \
        >> README-submitted
    echo "  Logged: ${LINE} ${year} ${cruise}"
done

echo ""
echo "========================================================"
echo " Submission complete for: ${CRUISES[*]}"
echo "========================================================"
