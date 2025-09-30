#!/bin/bash
# check_renav.sh
# Checks if renav.dat exists and prompts user to quit
# If this is called from another bash, we can check the code returned,
# and if it is 1, we can exit that program too
#
# Jared Brzenski

FILE="renav.dat"

if [[ -s "$FILE" ]]; then
    echo "Contents of $FILE:"
    cat "$FILE"
    echo
    read -p "Do you want to exit? (y/N): " answer
    case "$answer" in
        [Yy]* )
            echo "User chose to exit."
            exit 1   # return non-zero exit code
            ;;
        * )
            echo "Continuing..."
            ;;
    esac
fi

exit 0