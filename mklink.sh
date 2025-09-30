#!/usr/bin/env bash
#======================================================================
# Create symbolic links for nav files in folder above raw
#======================================================================

echo "Creating symbolic links for nav files in folder above us"
# Check to see if linknav.sh already exists
if [ -f "../linknav.sh" ]; then
    echo "linknav.sh already exists, skipping creation"
else
    echo "#" > ../linknav.sh
    for f in *.nav; do
        echo "ln -s \"\$PWD/$f\" \"../$f\"" >> ../linknav.sh
    done
    chmod a+x ../linknav.sh
fi
#