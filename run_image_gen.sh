#!/usr/bin/env bash
#####################################################################
# run_image_gen.sh - Generate XBT image products
#
# Description:
#   This script runs all image generation steps for the XBT dataset.
#   It must be executed from the directory *above* `raw/`, inside the
#   folder where image generation should take place.
#
# Prerequisites:
#   1. The analysis has been completed by running `run_analysis.sh`.
#   2. If renaming of files is needed, do that *before* running this script.
#
# Output:
#   - All generated images will be written to the current folder.
#   - A detailed log is written to `image_gen.log`.
#
# Behavior:
#   - The script will exit immediately if any command fails (`set -e`).
#
# Also: This uses the original XBT scripts, which have locations of files
# hard coded in the output. This uses the fix_paths.sh script to make all
# of the paths in the ferret files relative. AKA they must be run from this
# directory.
#
# Depends on:
# maketic.x
# link_bathy.sh
# ferstn.x - with fix for relative path in stn.fer
# mapxbt3.x
# fix_paths.sh
# run-bath-new_2025.sh 
#####################################################################

set -e  # Exit on first error
set -o pipefail  # Propagate errors through pipes

LOGFILE="image_gen.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===================================================="
echo " Starting image generation at $(date)"
echo " Log: $LOGFILE"
echo "===================================================="

# Find what the prefix and line number is in our folder
echo -e "\033[1m **Extracting prefix with extract_prefix.sh** \033[0m"
read line_number prefix < <(extract_prefix.sh)

echo "Prefix from extract_prefix.sh: $prefix"
echo "Line number: $line_number"
echo "we are currently in $PWD"
echo ""

# Get all of the ship information
# Source control file parser (either explicit or auto)
echo -e "\033[1m **Running extract_shipname.sh** \033[0m"
source extract_shipname.sh

# Now variables are available
echo "Ship Name: $Ship_Name"
echo "Cruise Name: $Cruise_Name"
echo "Max Ship Speed: $Max_Ship_Speed"

# link XBTinfo file from a few folders above us!
echo ""
xbtinfo_file="../../xbtinfo.${line_number}"
if [[ -L "xbtinfo.${line_number}" || -e "xbtinfo.${line_number}" ]]; then
    echo "Link or file xbtinfo.${line_number} already exists — skipping link."
else
    echo "Linking xbtinfo file here now..."
    ln -s "$xbtinfo_file" .
    echo "XBT line info linked here"
    echo ""
fi
# Special case, P13 links with P09!
if [[ $line_number == 'p13' ]]; then
    echo ""
    xbtinfo_file="../../xbtinfo.p09"
    if [[ -L "xbtinfo.p09" || -e "xbtinfo.p09" ]]; then
        echo "Link or file xbtinfo.p09 already exists — skipping link."
    else
        echo "Linking xbtinfo.p09 file here now..."
        ln -s "$xbtinfo_file" .
        echo "XBT line info p09 linked here for p13"
        echo ""
    fi
fi



# Link bathymetry here as well
echo -e "\033[1m **Linking bathymetry file with link_bathy.sh for $line_number** \033[0m"
link_bathy.sh "$line_number"

#################################################
# Run maketic.x
#################################################
echo ""
echo -e "\033[1m **Running maketic.x with $prefix** \033[0m"
maketic.x << EOF1
$prefix
n
EOF1

#################################################
# Run ferstn.x
#################################################
echo -e "\033[1m **Running ferstn.x for $prefix** \033[0m"
echo "$prefix" | ferstn.x
echo ""
echo "May need to edit etopo5.nc relative link? Maybe not"
echo -e "\033[1m **Fixing relative paths for stnpos.fer with fix_paths.sh** \033[0m"
fix_paths.sh stn.fer
sed -i.bak 's|^set data "/drua/etopo/etopo5\.nc"|set data "../../bathy/etopo5.nc"|' stn.fer

#################################################################################################
# Run mapxbt for tem, sal, and del
#################################################################################################
# Needs 8 chars for filename, then "tem", or "sal", or "del"
# then ship name!@!
# It also has different requirements based on the ship.

# echo -e "\033[1m **Running ship_name_to_number.sh to get ship number** \033[0m"
# source ship_name_to_number.sh  $Ship_Name
# Checking to see if we have complicated mapxbt3 logic
echo -e "\033[1m **Prefix right now is $prefix** \033[0m"
echo -e "\033[1m **Running mapxbt_helper.sh to get complicated mapxbt3 inputs** \033[0m"
. mapxbt_helper.sh $line_number
echo "line = $long_line"
echo "Choice = $choice"
echo "start = $start"
echo "end = $end"

# If Choice, start, or end have things, we add those to the mapxbt3 input
# Otherwise we just use the prefix
prefixa="${prefix}a"
echo -e "\033[1m **Prefix for mapxbt3 is $prefixa** \033[0m"
echo -e "\033[1m **Ship Name is $Ship_Name, but we choose Astrolabe (2), and replace later!** \033[0m"
echo ""

if [[ -n "$start" && -n "$end" ]]; then # p50 case
    # Eight digit prefix
    echo -e "\033[1m **Running mapxbt for temp for ${prefixa} with start=$start, and end=$end** \033[0m"
    mapxbt3.x << EOF20
$prefixa
tem
2
$start
$end
EOF20

elif [[ -n "$choice" ]]; then    # asst other cases
    # Eight digit prefix
    echo -e "\033[1m **Running mapxbt for temp for ${prefixa} with choice = $choice** \033[0m"
    mapxbt3.x << EOF21
$prefixa
tem
2
$choice
EOF21

else  # The other singular cases
    echo -e "\033[1m **Running mapxbt for temp for ${prefixa}** \033[0m"
    mapxbt3.x << EOF22
$prefixa
tem
2
EOF22
fi
#################################################################################################
#################################################################################################

# Edit the files, remove "Astrolabe", and replace with $ship_name!
echo -e "\033[1m **Editing fertem.web and ferret.tem.a to replace Astrolabe with $Ship_Name** \033[0m"
sed -i "s/Astrolabe/$Ship_Name/" fertem.web
sed -i "s/Astrolabe/$Ship_Name/" ferret.tem.a

echo ""
echo -e "\033[1m **Fixing relative paths for ferret.tem.a and fertem.web with fix_paths.sh** \033[0m"
fix_paths.sh ferret.tem.a
fix_paths.sh fertem.web

#################################################
# run-bath-new_2025.sh BRZENSKI -- GETS HERE
#################################################
echo -e "\033[1m **Running run-bath-new_2025.sh** \033[0m"
run-bath-new_2025.sh

#################################################
# interp_to_grid
#################################################
echo -e "\033[1m **Running interp_to_grid_2025.x for ${prefixa}** \033[0m"
if [[ $line_number == 'p37' ]]; then
    echo "Line 37 detected, using custom grid"
    echo -e "$prefixa\n2\n" | interp_to_grid_2025.x
else
    echo "Using default grid file grid.txt"
    echo "$prefixa" | interp_to_grid_2025.x 
fi
#################################################
# Run mapxbt for sal, and del
#################################################
# Shipname does not matter here
echo ""
echo -e "\033[1m **Running mapxbt for sal for ${prefixa} and option 1** \033[0m"
mapxbt3.x << EOF2
$prefixa
sal
1
EOF2

echo ""
echo -e "\033[1m **Running mapxbt for del for ${prefixa} and option 1** \033[0m"
mapxbt3.x << EOF2
$prefixa
del
1
EOF2

#################################################
# Run gvdel98.x, whatever that does!!
# ASK what does the custom level mean?!? Bottom bathymetry
#################################################
echo -e "\033[1m **Running gvdel98.x for ${prefixa} with option 1 then 2** \033[0m"
gvdel98.x << EOF3
$prefixa
1
2

EOF3

echo ""
echo "===================================================="
echo " Image generation completed successfully at $(date)"
echo "===================================================="
