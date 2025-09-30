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
##
## Below are notes from the original line2.bat file
#16aug2022 copies output files to /argo-project/pub/html/www-hrx
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
# Is this necessary BRZENSKI
source /usr/local/bin/ferret_paths
setenv FER_PALETTE     "/home/llehmann/ferret . $FER_DIR/ppl"

set -e  # Exit on first error
set -o pipefail  # Propagate errors through pipes

LOGFILE="line.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===================================================="
echo " Starting line bat html processing at $(date)"
echo " Log: $LOGFILE"
echo "===================================================="

# Make sure the argo drive is loaded, and accessible
if [[ -d "/argo-project/pub/html/www-hrx/" ]]; then
    echo "Directory /argo-project/pub/html/www-hrx/ exists"
else
    echo "Directory /argo-project/pub/html/www-hrx/ does NOT exist"
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
else
    echo "Linking now..."
    ln -s "../${ferret_stn_info_file}" .
    echo "Ferret station info linked here"
fi

# run mapxbt3.x for p81 only!
# Currently inactive as of 2025 BRZENSKI
if [[ $line -eq 81 ]]; then
    mapxbt3.x << EOF6
$ch$line$i
tem
EOF6
fi

#echo before-tem
# run ferret to create temperature plot (metafile.plt)
# p28 - 4 different ferret input files because of naming with a, b, c, d

echo "Running ferret for line $line,  using input.ferret, putting to web.out"
echo "This is creating the temperature plot."
if [[ $line -eq 28 ]]; then
    if [[ -e ferret.tem.a ]]; then
        ferret < "input.ferret" > web.out
    elif [[ -e ferret.tem.b ]]; then
        ferret < "inputb.ferret" > web.out
    elif [[ -e ferret.tem.c ]]; then
        ferret < "inputc.ferret" > web.out
    elif [[ -e ferret.tem.d ]]; then
        ferret < "inputd.ferret" > web.out
    fi

elif [[ $line -eq 22 ]]; then
    ferret < "input.ferret" > web.out

elif [[ $line -eq 21 ]]; then
    ferret < "input.ferret" > web.out

else
    ferret < "input.ferret" > web.out
fi

#
echo ""
echo "Finish temperature ferret"
echo ""

# Pause for user interaction
echo ""
read -p "Press Enter to continue..."
echo ""

# create postscript file:
# These are for vintage ferret files
# Maybe update fro newer pyferret supported.
# see line_2025_update.sh
Fprint -o fer.ps  -l cps metafile.plt
sed '/BoundingBox/d' fer.ps > fer1.ps

#15apr2015 LL convert changes/additions:
# convert -density 600 -trim +repage -rotate -90 -geometry XXXXxYYYY! -flatten file.ps file.gif
# the -flatten helps keep the background white (vs light gray)

#full (same for all):
convert -density 600 -trim +repage -rotate -90 -flatten fer1.ps t-f.gif

# mv it to web page area:
# if p28, drop the leading p so 8 chars before dot

if [[ $line -eq 28 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x494! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}t-t.gif

elif [[ $line -eq 15 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 3022x1510! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}t-t.gif

elif [[ $line -eq 21 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x500! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}t-t.gif

elif [[ $line -eq 22 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x487! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x244! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/ax22/img/a{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/ax22/img/a{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/ax22/img/a{$line}{$i}t-t.gif

elif [[ $line -eq 31 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 34 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 40 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x504! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 44 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x51!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 37 ]]; then
    if [[ $ch == p ]]; then
        # old largeconvert -density 600 -trim +repage -rotate -90 -geometry 1000x501! fer1.ps t-b.gif
        # old largeconvert -density 600 -trim +repage -rotate -90 -geometry 500x251! fer1.ps t-s.gif
        # old largeconvert -density 600 -trim +repage -rotate -90 -geometry 100x50!  fer1.ps t-t.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 1000x505! -flatten fer1.ps t-b.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 500x252! -flatten fer1.ps t-s.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
        mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
        mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
        mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

    elif [[ $ch == s ]]; then
        convert -density 600 -trim +repage -rotate -90 -geometry 1000x501! -flatten fer1.ps t-b.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer1.ps t-s.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
        mv t-b.gif /argo-project/pub/html/www-hrx/p{$line}s/img/p{$line}{$i}t-b.gif
        mv t-s.gif /argo-project/pub/html/www-hrx/p{$line}s/img/p{$line}{$i}t-s.gif
        mv t-t.gif /argo-project/pub/html/www-hrx/p{$line}s/img/p{$line}{$i}t-t.gif

    fi

elif [[ $line -eq 50 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x494! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x247! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x49!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 05 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1500x750! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 08 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x502! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x250! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 09 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x502! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 13 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x502! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px09/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px09/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px09/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 38 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x503! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

elif [[ $line -eq 81 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x502! -flatten fer1.ps t-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 500x251! -flatten fer1.ps t-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x50!  -flatten fer1.ps t-t.gif
    mv t-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-b.gif
    mv t-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-s.gif
    mv t-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}t-t.gif

else
    mv p{$line}{$i}t.gif /argo-project/pub/html/www-hrx/px{$line}/p{$line}{$i}t.gif

fi

echo "finish tem move"

if [[ $line == 22 ]]; then
   ferret  < /data/xbt/{$ch}{$line}/input.stn_ferret >& web.out
elif [[ $line == 21 ]]; then
   ferret  < /data/xbt/p15/input.stn_ferret >& web.out
elif [[ $line == 28 ]]; then
   ferret  < /data/xbt/p28/input.stn_ferret >& web.out
else
   ferret  < /data/xbt/{$ch}{$line}/input.stn_ferret >& web.out
fi

Fprint -o fer.ps  -l cps metafile.plt
sed '/BoundingBox/d' fer.ps > fer1.ps

# "full"
#convert -density 600 -trim +repage -rotate -90 fer1.ps s-f.gif
#LL these will be different for each cruise:

# mv it to web page area:
# if p28, drop the leading p so 8 chars before dot
if [[ $line == 28 ]]; then
    convert -density 600 -trim +repage -geometry 464x800! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -geometry 90x155! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -geometry 58x100!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}s-t.gif

elif [[ $line == 05 ]]; then
    convert -density 600 -trim +repage -geometry 538x1045! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -geometry 78x152! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -geometry 52x100!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 08 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 650x335! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 240x124! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x41!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 15 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x507! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 300x152! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x51!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}s-b.gif
    mv  s-s.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}s-s.gif
    mv  s-t.gif /argo-project/pub/html/www-hrx/ix{$line}/img/i{$line}{$i}s-t.gif
    echo 'finish stn move'

elif [[ $line == 21 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 500x283! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 200x113! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x57!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}s-b.gif
    mv  s-s.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}s-s.gif
    mv  s-t.gif /argo-project/pub/html/www-hrx/ix15/img/i{$line}{$i}s-t.gif
    echo 'finish stn move'

elif [[ $line == 22 ]]; then
    convert -density 600 -trim +repage -geometry 525x515! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -geometry 155x152! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -geometry 90x88!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif /argo-project/pub/html/www-hrx/ax{$line}/img/a{$line}{$i}s-b.gif
    mv  s-s.gif /argo-project/pub/html/www-hrx/ax{$line}/img/a{$line}{$i}s-s.gif
    mv  s-t.gif /argo-project/pub/html/www-hrx/ax{$line}/img/a{$line}{$i}s-t.gif

elif [[ $line == 31 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x456! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 225x103! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x46!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv  s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv  s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv  s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 34 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x362! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 240x87! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 115x42!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 40 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x436! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 325x142! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 115x50!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 44 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x565! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 225x127! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x56!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 37 ]]; then
    echo  "ch line: ${ch} ${line}"
    if [[ $ch == p ]]; then
        echo $ch
        # old large convert -density 600 -trim +repage -rotate -90 -geometry 850x230! fer1.ps s-b.gif
        # old large convert -density 600 -trim +repage -rotate -90 -geometry 320x87! fer1.ps s-s.gif
        # old large convert -density 600 -trim +repage -rotate -90 -geometry 100x28!  fer1.ps s-t.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 500x308! -flatten fer1.ps s-b.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 187x115! -flatten fer1.ps s-s.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 100x62!  -flatten fer1.ps s-t.gif
        echo 'finish stn convert'
        mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
        mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
        mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif
        #dunno why this check for s does not work:
        # elseif ( $ch == s ) then
    else
        echo $ch
        convert -density 600 -trim +repage -rotate -90 -geometry 1000x350! -flatten fer1.ps s-b.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 325x114! -flatten fer1.ps s-s.gif
        convert -density 600 -trim +repage -rotate -90 -geometry 100x35!  -flatten fer1.ps s-t.gif
        echo 'finish stn convert'
        mv s-b.gif /argo-project/pub/html/www-hrx/p{$line}s/img/p{$line}{$i}s-b.gif
        mv s-s.gif /argo-project/pub/html/www-hrx/p{$line}s/img/p{$line}{$i}s-s.gif
        mv s-t.gif /argo-project/pub/html/www-hrx/p{$line}s/img/p{$line}{$i}s-t.gif
    fi

elif [[ $line == 38 ]]; then
    convert -density 600 -trim +repage -geometry 486x900! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -geometry 84x155! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -geometry 54x100!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 50 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 850x348! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 260x106! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x41!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 09 ]]; then
    convert -density 600 -trim +repage -geometry 650x1045! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -geometry 95x152! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -geometry 63x100!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif

elif [[ $line == 13 ]]; then
    convert -density 600 -trim +repage -geometry 650x1045! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -geometry 95x152! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -geometry 63x100!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px09/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px09/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px09/img/p{$line}{$i}s-t.gif

elif [[ $line == 81 ]]; then
    convert -density 600 -trim +repage -rotate -90 -geometry 1000x667! -flatten fer1.ps s-b.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 227x152! -flatten fer1.ps s-s.gif
    convert -density 600 -trim +repage -rotate -90 -geometry 100x67!  -flatten fer1.ps s-t.gif
    echo 'finish stn convert'
    mv s-b.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-b.gif
    mv s-s.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-s.gif
    mv s-t.gif /argo-project/pub/html/www-hrx/px{$line}/img/p{$line}{$i}s-t.gif
else
    echo "Nothing happened in the convert step!?!"
    #LL \mv p{$line}{$i}s.gif /argo-project/pub/html/www-hrx/px{$line}/p{$line}{$i}s.gif
endif

#clean up
rm ferret.jnl*
#\rm web.out
rm meta*
rm fer.ps
rm fer1.ps
rm t-f.gif
rm s-f.gif

# html file:

if [[ $line == 28 ]]; then
    echo "Running cruisehtml for P28."
    cruisehtml.x << EOF5
p$line$i
p$line$i
EOF5

elif [[ $line == 21 ]]; then
    echo "Skip creating html for i21 - you must edit it, mv previous cruise then modify"
else
    cruisehtml.x << EOF3
$ch$line$i
EOF3
fi


echo "cruisehtml ${ch}${line}${i}"

chmod a+x *html
if [[ $line == 22 ]]; then
    mv *html /argo-project/pub/html/www-hrx/ax{$line}/.
elif [[ $line == 15 ]]; then
    mv *html /argo-project/pub/html/www-hrx/ix{$line}/.
    echo "moving line 15"
elif [[ $line == 28 ]]; then
    mv *html /argo-project/pub/html/www-hrx/ix{$line}/.
elif [[ $line == 37 ]]; then
 if [[ $ch == p ]]; then
    mv *html /argo-project/pub/html/www-hrx/px{$line}/.
 else
    mv *html /argo-project/pub/html/www-hrx/p{$line}s/.
 fi
elif [[ $line == 21 ]]; then
    echo "No move html"
else
    mv *html /argo-project/pub/html/www-hrx/px{$line}/.
fi

end