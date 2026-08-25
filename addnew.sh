#!/bin/bash
# addnew.sh
# For adding new lines for the BUDDIES script.
# 
# Try the new simpler, automated add_to_buddies.sh.
# 
# UPDATED: To work using the /kakopo folder structure on savu
# Jared Brzenski : August 2026
#

set -euo pipefail

# CHANGE:
# Replace with the line number
line="s37"

# CHANGE:
# Replace the list with the cruises you want. Can do a single cruise 
# or multiple cruises. 
cruises=(2410 2502)


source_root="/kakopo/data/xbt"
archive_root="/kakopo/data1/xbt-archive"

#################################################################
## DO NOT CHANGE BELOW THIS LINE                               ##
#################################################################

for cruise in "${cruises[@]}"; do
    # Set some values based on cruise and line
    line_cruise="${line}${cruise}"
    source_dir="${source_root}/${line}/${cruise}"
    archive_dir="${archive_root}/${line}/${cruise}"

    echo "Processing {$line_cruise}..."

    mkdir -p "${archive_dir}"
    cd "${source_dir}"

    # Copy the e files.
    cp -a "${line_cruise}"e.* "${archive_dir}/"

    # Custom for a-lines only:
    # Skip s files for Atlantic lines:
    # cp -a "${line_cruise}"s.* "${archive_dir}/"

    # Normal:
    # cp stations.dat "${archive_dir}/stations.dat"
    #
    # p09 and p38 do not have stations.dat:
    cp -a "${line_cruise}.dat" "${archive_dir}/stations.dat"

    # Create a fake control.dat.
    "${archive_root}/fakecontrol.x" <<EOF
${line_cruise}
EOF

    # If a real control.dat exists, it replaces the fake one.
    if [[ -f control.dat ]]; then
        cp -a control.dat "${archive_dir}/control.dat"
    fi

    cd "${archive_dir}"

    # Run mklinedat.x to generate line.dat.
    "${archive_root}/mklinedat.x" <<EOF
${line_cruise}
EOF

    # Put the recent cruise at the beginning of the line file.
    # Note: i21 cruises are added to p15.dat.
    if [[ "${line}" == "i21" ]]; then
        master_file="${archive_root}/p15.dat"
    else
        master_file="${archive_root}/${line}.dat"
    fi

    cat "${master_file}" >> "${archive_root}/line.dat"
    cp "${archive_root}/line.dat" "${master_file}"

    echo "Finished ${line_cruise}"
done
