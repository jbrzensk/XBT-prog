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

# Check to see if Cals folder is in shiprider
if [ -d "Reports_Shiprider/Cals" ]; then
    echo "Moving Cals folder contents to raw directory"
    mv Reports_Shiprider/Cals Cals/.
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

# mv p*e.* ..
# cp control.dat ..
# cp p*.dat ..


echo "Added symbolic links to directory above"
echo ""
echo "Finished mvraw script."
echo ""
