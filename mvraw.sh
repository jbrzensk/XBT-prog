#!/bin/bash
#======================================================================
# mvraw.sh
#
# This file moves the folders from Sio/data/etc... to raw
# and removes the folder SIO. 
#
# The file also makes the linknav.sh batch file with a bunch
# of symbolic links to the nav files, instead of making copies
#
# Update by Jared Brzenski
#
#======================================================================

# Check to see if the Sio folder exists, if not, skip this section
if [ -d "Sio" ]; then
    echo "Moving Sio folder contents to raw directory"
    mv -i Sio/Data/* .
    mv Sio/plan.dat .
    mv Sio/Reports_Shiprider .
    rm -r -f Sio
else
    echo "Sio folder does not exist!!"
    echo "This needs to be run from the raw directory"
    echo "OR files were already moved."
    echo ""
fi

# Check for Cals folder — may be in Sio/Data (moved to current dir) or in Reports_Shiprider.
# Move it to the directory above raw either way.
if [ -d "Cals" ]; then
    echo "Cals folder found in raw (from Sio/Data) — moving to directory above raw."
    mv Cals ..
elif [ -d "Reports_Shiprider/Cals" ]; then
    echo "Cals folder found in Reports_Shiprider — moving to directory above raw."
    mv Reports_Shiprider/Cals ..
else
    echo "WARNING: Cals folder not found in either expected location:"
    echo "  ./Cals                (from Sio/Data/Cals)"
    echo "  ./Reports_Shiprider/Cals"
fi

# Create symbolic links for nav files in folder above raw
echo "Creating symbolic links for nav files in folder above us"
for f in *.nav; do
    # skip if no .nav files exist
    [ -e "$f" ] || continue

    # skip if already exists in parent
    if [ -e "../$f" ]; then
        echo "Skipping $f (../$f already exists)"
        continue
    fi

    pushd .
    cd ..
    ln -sf "raw/$f" .
    popd
done

# Move the README.txt file to the directory above raw, if it exists
if [ -e "README.txt" ]; then
    echo "Moving README.txt to directory above raw"
    mv README.txt ..
else
    echo "README.txt not found in raw directory — skipping move."
fi

# Move the MetObs.XXXX file to the directory above raw, if it exists
if ls *MetObs.* &>/dev/null; then
    echo "Moving MetObs file to directory above raw"
    mv *MetObs.* ..
else
    echo "MetObs file not found in raw directory — skipping move."
fi

echo "Added symbolic links to directory above"
echo ""
echo "Finished mvraw script."
echo ""
