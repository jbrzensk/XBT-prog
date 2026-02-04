#!/bin/bash
#=============================================================================#
## LINE_2025.sh
# This script does all of the output files for the html,
# adjusts the plots, and, using ImageMagick makes the images
# for the website.
#
# This file, like all 2025 files, is meant to be run from the directory you are
# processing. It reads the local files to figure out what line transect you
# are doing. 
# For Example, this should be run from /data/xpt/p40/2502, or something 
# equivalent.
# Be sure you have already processed cruise and created the "ferret.tem.a(b or c)"
# and the fer.stn.
#
# Brzenski: Oct 2025
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
##
# Below are notes from the original line2.bat file
#
# 16aug2022 copies output files to /argo-project/pub/html/www-hrx
#
# search for "MODIFY (/MODIFY)"
# Needs to plot to screen.
# Make sure you have a /data/xbt/p??/input.ferret file!
# Make sure you have a /data/xbt/p??/input.stn_ferret file!
# 2) make into gif file and put in our www-hrx.ucsd.edu web page area
# 3) runs stnfer.f to create a ferret station plot and does like 2)
# Be sure you have already processed cruise and created the "ferret.tem.a(b or c)"
# and the fer.stn.
#=============================================================================#
#
# Get ferret paths: 
#
# Function: append a line to a file if it doesn't already exist
append_if_missing() {
    local line="$1"
    local file="$2"
    
    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

# Ferret paths is sourced if ferret environmenet is loaded
# Both these commands are taken care of
# source /usr/local/bin/ferret_paths
# Actual source for this is /kakapo/home/llehmann/ferret
# setenv FER_PALETTE     "/home/llehmann/ferret . $FER_DIR/ppl"

set -e  # Exit on first error
set -o pipefail  # Propagate errors through pipes

LOGFILE="line.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===================================================="
echo " Starting line bat html processing at $(date)"
echo " Log: $LOGFILE"
echo "===================================================="

# Set standard directory for outputting argo
ARGO_DIR="/home/jbrzensk/argo-project/pub/html/www-hrx"
echo "Argo directory is set to $ARGO_DIR"
echo ""

# Make sure the argo drive is loaded, and accessible
if [[ -d $ARGO_DIR ]]; then
    echo "Directory ${ARGO_DIR} exists"
else
    echo "Directory ${ARGO_DIR} does NOT exist"
    echo "Are you sure the argo drive is mounted?"
    echo "Exiting..."
    echo ""
    exit 1
fi

# Find what the prefix and line number is in our folder
read line_number prefix < <(extract_prefix.sh)

echo "Prefix from extract_prefix.sh: $prefix"
echo "Line number: $line_number"
echo "we are currently in $PWD"
echo ""

ch=${line_number:0:1}
line=${line_number:1:2}
i=${prefix:3:4}
echo "Prefix letter: $ch"
echo "Line extracted: $line"
echo "I extracted: $i"

# Link the input.ferret files here!
echo ""
ferret_info_file="input.ferret"
if [[ ! -e "../${ferret_info_file}" ]]; then
    echo "Error: ${ferret_info_file} does not exist."
    echo "Are you running this from the correct directory?"
    echo "Should be run from /data/xbt/p??/XXXX"
    echo "Exiting..."
    exit 1
fi

if [[ -L "${ferret_info_file}" || -e "${ferret_info_file}" ]]; then
    echo "Link or file ${ferret_info_file} already exists — skipping link."
else
    echo "Linking now..."
    ln -s "../${ferret_info_file}" .
    echo "Ferret info linked here"
fi

# Link the input.stn_ferret files here!
ferret_stn_info_file="input.stn_ferret"
if [[ ! -e "../${ferret_stn_info_file}" ]]; then
    echo "Error: ${ferret_stn_info_file} does not exist."
    echo "Are you running this from the correct directory?"
    echo "Should be run from /data/xbt/p??/XXXX"
    echo "Exiting..."
    exit 1
fi

if [[ -L "${ferret_stn_info_file}" || -e "${ferret_stn_info_file}" ]]; then
    echo "Link or file ${ferret_stn_info_file} already exists — skipping link."
    echo ""
else
    echo "Linking now..."
    ln -s "../${ferret_stn_info_file}" .
    echo "Ferret station info linked here"
fi

# run mapxbt3.x for p81 only!
# Currently inactive as of 2025 BRZENSKI
echo "Running mapxbt3.x for line $ch$line,  using input.ferret, putting to web.out"
if [[ "$line" == 81 ]]; then
    mapxbt3.x << EOF6
$ch$line$i
tem
EOF6
fi

# run ferret to create temperature plot (metafile.plt)
# p28 - 4 different ferret input files because of naming with a, b, c, d
# Append the ferret.tem.a file to output to PDF.

echo "Running ferret for line $line,  using input.ferret, putting to web.out"
echo "This is creating the temperature plot."
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "This is a slow process, due to the PDF format of the output"
echo "Working....."
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo "The NOTE below is legacy,the local ferret.tem.X and stn.fer files"
echo "have been updated with FRAME/FILE=\"fer.pdf\"/FORMAT=PDF to "
echo "reflect the updated QT format and newer Ferret and pyFerret standards."
echo ""
if [[ "$line" == 28 ]]; then
    if [[ -e ferret.tem.a ]]; then
        append_if_missing 'FRAME/FILE="fer.pdf"/FORMAT=PDF' ferret.tem.a
        ferret < "input.ferret" > web.out
    elif [[ -e ferret.tem.b ]]; then
        append_if_missing 'FRAME/FILE="fer.pdf"/FORMAT=PDF' ferret.tem.b
        ferret < "inputb.ferret" > web.out
    elif [[ -e ferret.tem.c ]]; then
        append_if_missing 'FRAME/FILE="fer.pdf"/FORMAT=PDF' ferret.tem.c
        ferret < "inputc.ferret" > web.out
    elif [[ -e ferret.tem.d ]]; then
        append_if_missing 'FRAME/FILE="fer.pdf"/FORMAT=PDF' ferret.tem.d
        ferret < "inputd.ferret" > web.out
    fi
else
    append_if_missing 'FRAME/FILE="fer.pdf"/FORMAT=PDF' ferret.tem.a
    ferret < "input.ferret" > web.out
fi

#
echo ""
echo "Finished temperature ferret to PDF"
echo ""

# create postscript file:
# These are for vintage ferret files
# Maybe update fro newer pyferret supported.
# see line_2025_update.sh

#15apr2015 LL convert changes/additions:
# convert -density 600 -trim +repage -rotate -90 -geometry XXXXxYYYY! -flatten file.ps file.gif
# the -flatten helps keep the background white (vs light gray)

#full (same for all):
echo "Making big temperature gif file..."
convert -density 600 -trim +repage -flatten fer.pdf t-f.gif

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Directory Filenames on argo web page:
#
# PX's: 05, 06, 08, 09, 31, 34, [37], 38, 40, 44, 50, 81
# IX's: 15, 21, 28
# AX's: 22
# P37s: [37]
#
# This section moves the scaled versions to the correct directories
# names them correctly, and resizes them correctly.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
echo "Making [big, small, thumbnail] temperature gifs"
echo ""

#####################################
#   IX Lines (15,21,28)
#####################################
if [[ "$line" == 15 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 3022x1510! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/ix15/img/i${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/ix15/img/i${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/ix15/img/i${line}${i}t-t.gif"

elif [[ "$line" == 21 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x500! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/ix21/img/i${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/ix21/img/i${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/ix21/img/i${line}${i}t-t.gif"

elif [[ "$line" == 28 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x494! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/ix${line}/img/i${prefix}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}t-t.gif"

#####################################
#   AX Lines (22)
#####################################
elif [[ "$line" == 22 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x487! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x244! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/ax22/img/a${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/ax22/img/a${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/ax22/img/a${line}${i}t-t.gif"

#####################################
#   PX Lines (05, 06, 08, 09, 31, 34, 38, 40, 44, 50, 81)
#####################################

elif [[ "$line" == 05 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1500x750! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 08 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x502! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 09 ]]; then
    convert -density 600 -trim +repage -geometry 1000x502! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -geometry 500x251! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 13 ]]; then
    convert -density 600 -trim +repage -geometry 1000x502! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -geometry 500x251! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px13/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px13/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px13/img/p${line}${i}t-t.gif"

elif [[ "$line" == 31 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 34 ]]; then
    convert -density 600 -trim +repage -geometry 1000x505! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -geometry 100x50!  -flatten fer.pdf t-t.gif
    convert -density 600 -trim +repage -geometry 500x252! -flatten fer.pdf t-s.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 38 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x503! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 40 ]]; then
    convert -density 600 -trim +repage -geometry 1000x504! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -geometry 500x252! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 44 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x51!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 50 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x494! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x247! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x49!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

elif [[ "$line" == 81 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x502! -flatten fer.pdf t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer.pdf t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
    mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
    mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
    mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

#####################################
#   PX(s) Line 37
#####################################
elif [[ "$line" == 37 ]]; then
    if [[ $ch == p ]]; then
        # old largeconvert -density 600 -trim +repage -rotate -90 -geometry 1000x501! fer.pdf t-b.gif
        # old largeconvert -density 600 -trim +repage -rotate -90 -geometry 500x251! fer.pdf t-s.gif
        # old largeconvert -density 600 -trim +repage -rotate -90 -geometry 100x50!  fer.pdf t-t.gif
        echo "Line p37 detected, using custom grid conversions"
        convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer.pdf t-b.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer.pdf t-s.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer.pdf t-t.gif
        mv t-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-b.gif"
        mv t-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-s.gif"
        mv t-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}t-t.gif"

    elif [[ $ch == s ]]; then
        echo "Line s37 detected, using custom grid conversions"
        convert -density 600 -trim +repage -geometry 1000x501! -flatten fer.pdf t-b.gif
        convert -density 600 -trim +repage -geometry 500x251! -flatten fer.pdf t-s.gif
        convert -density 600 -trim +repage -geometry 100x50!  -flatten fer.pdf t-t.gif
        mv t-b.gif "${ARGO_DIR}/p${line}s/img/p${line}${i}t-b.gif"
        mv t-s.gif "${ARGO_DIR}/p${line}s/img/p${line}${i}t-s.gif"
        mv t-t.gif "${ARGO_DIR}/p${line}s/img/p${line}${i}t-t.gif"

    fi

else
    echo "Could not find predefined conversion sizes for line $line"
    echo "Using default conversion sizes for line $line"
    mv p{$line}{$i}t.gif "${ARGO_DIR}/px${line}/p${line}${i}t.gif"

fi

echo "Finished temperature plot move"
echo ""

## Do the stn plot
echo "Doing stn_ferret plot"
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "This is a slow process, due to the PDF format of the output"
echo "Working....."
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

# append file writing script
append_if_missing 'FRAME/FILE="fer.pdf"/FORMAT=PDF' stn.fer

ferret  < input.stn_ferret >& web.out

# "full"
echo "Making big stn_fer gif file..."
convert -density 600 -trim +repage fer.pdf s-f.gif
#LL these will be different for each cruise:

echo "Making [big, small, thumbnail] stn_fer gifs"
echo ""
#####################################
#   IX Lines (15,21,28) stn_fer
#####################################
if [[ "$line" == 15 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x507! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 300x152! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x51!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-b.gif"
    mv  s-s.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-s.gif"
    mv  s-t.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-t.gif"
    echo 'finish stn move'

elif [[ "$line" == 21 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 500x283! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 200x113! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x57!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-b.gif"
    mv  s-s.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-s.gif"
    mv  s-t.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-t.gif"
    echo 'finish stn move'

elif [[ "$line" == 28 ]]; then
    convert -density 600 -trim +repage -geometry 464x800! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 90x155! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 58x100!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/ix${line}/img/i${line}${i}s-t.gif"


#####################################
#   AX Lines (22)
#####################################
elif [[ "$line" == 22 ]]; then
    convert -density 600 -trim +repage -geometry 525x515! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 155x152! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 90x88!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif "${ARGO_DIR}/ax${line}/img/a${line}${i}s-b.gif"
    mv  s-s.gif "${ARGO_DIR}/ax${line}/img/a${line}${i}s-s.gif"
    mv  s-t.gif "${ARGO_DIR}/ax${line}/img/a${line}${i}s-t.gif"

#####################################
#   PX Lines (05, 06, 08, 09, 31, 34, 38, 40, 44, 50, 81)
#####################################

elif [[ "$line" == 05 ]]; then
    convert -density 600 -trim +repage -geometry 538x1045! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 78x152! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 52x100!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 08 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 650x335! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 240x124! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x41!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 09 ]]; then
    convert -density 600 -trim +repage -geometry 650x1045! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 95x152! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 63x100!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 13 ]]; then
    convert -density 600 -trim +repage -geometry 650x1045! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 95x152! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 63x100!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 31 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x456! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 225x103! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x46!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv  s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv  s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 34 ]]; then
    convert -density 600 -trim +repage -geometry 1000x362! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 240x87! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 115x42!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 38 ]]; then
    convert -density 600 -trim +repage -geometry 486x900! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -geometry 84x155! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -geometry 54x100!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 40 ]]; then
    convert -density 600 -trim +repage  -geometry 1000x436! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage  -geometry 325x142! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage  -geometry 115x50!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 44 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x565! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 225x127! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x56!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 50 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 850x348! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 260x106! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x41!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

elif [[ "$line" == 81 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x667! -flatten fer.pdf s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 227x152! -flatten fer.pdf s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x67!  -flatten fer.pdf s-t.gif
    echo 'finish stn convert'
    mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
    mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
    mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"

#####################################
#   PX(s) Line 37 stn_fer
#####################################
elif [[ "$line" == 37 ]]; then
    echo  "ch line: ${ch} ${line}"
    if [[ $ch == p ]]; then
        echo "Line p37 detected, using custom grid conversions"
        # old large convert -density 600 -trim +repage -rotate -90 -geometry 850x230! fer.pdf s-b.gif
        # old large convert -density 600 -trim +repage -rotate -90 -geometry 320x87! fer.pdf s-s.gif
        # old large convert -density 600 -trim +repage -rotate -90 -geometry 100x28!  fer.pdf s-t.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 500x308! -flatten fer.pdf s-b.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 187x115! -flatten fer.pdf s-s.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 100x62!  -flatten fer.pdf s-t.gif
        echo 'finish stn convert'
        mv s-b.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-b.gif"
        mv s-s.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-s.gif"
        mv s-t.gif "${ARGO_DIR}/px${line}/img/p${line}${i}s-t.gif"
        #dunno why this check for s does not work:
        # elseif ( $ch == s ) then
    else
        echo "Line s37 detected, using custom grid conversions"
        convert -density 600 -trim +repage -geometry 1000x350! -flatten fer.pdf s-b.gif
        convert -density 600 -trim +repage -geometry 325x114! -flatten fer.pdf s-s.gif
        convert -density 600 -trim +repage -geometry 100x35!  -flatten fer.pdf s-t.gif
        echo 'finish stn convert'
        mv s-b.gif "${ARGO_DIR}/p${line}s/img/p${line}${i}s-b.gif"
        mv s-s.gif "${ARGO_DIR}/p${line}s/img/p${line}${i}s-s.gif"
        mv s-t.gif "${ARGO_DIR}/p${line}s/img/p${line}${i}s-t.gif"
    fi

else
    echo "Nothing happened in the convert step!?!"
    #LL \mv p{$line}{$i}s.gif /argo-project/pub/html/www-hrx/px{$line}/p{$line}{$i}s.gif
fi

#clean up
rm ferret.jnl*
#\rm web.out
#rm meta*
#rm fer.ps
rm fer.pdf
rm t-f.gif
rm s-f.gif

# html file:
if [[ "$line" == 28 ]]; then
    echo "Running cruisehtml for P28."
    cruisehtml.x << EOF5
p$line$i
p$line$i
EOF5

elif [[ "$line" == 21 ]]; then
    echo "Skip creating html for i21 - you must edit it, mv previous cruise then modify"
else
    echo "Running cruisehtml.x for ${prefix}."
    # this is backwards from the other files.
    cruisehtml.x << EOF3
$ch$line$i
EOF3
fi


echo "cruisehtml ${ch}${line}${i}"

chmod a+x *html
if [[ "$line" == 22 ]]; then
    mv *html "${ARGO_DIR}/ax${line}/."
elif [[ "$line" == 15 ]]; then
    mv *html "${ARGO_DIR}/ix${line}/."
    echo "moving line 15"
elif [[ "$line" == 28 ]]; then
    mv *html "${ARGO_DIR}/ix${line}/."
elif [[ "$line" == 37 ]]; then
    if [[ $ch == p ]]; then
        mv *html "${ARGO_DIR}/px${line}/."
    else
        mv *html "${ARGO_DIR}/p${line}s/."
    fi
elif [[ "$line" == 21 ]]; then
    echo "No move html"
else
    mv *html "${ARGO_DIR}/px${line}/."
fi

echo "All done!"
