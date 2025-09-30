#!/bin/bash
#======================================================================
# Gets the date, similar to the date fortran code.
# This is a little more robust becuase it uses built in Linux 
# programs
#======================================================================

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 YY MM DD"
    exit 1
fi

yy=$1
mm=$2
dd=$3

# Convert two-digit year to full year
# Assume YY >= 86 is 1986-1999, YY < 86 is 2000-2085
if [ "$yy" -ge 86 ]; then
    yyyy=$((1900 + yy))
else
    yyyy=$((2000 + yy))
fi

# Reference epoch (Dec 31, 1985), so 1986-01-01 is day #1
epoch="1985-12-31"

# Convert both dates to epoch seconds
date_secs=$(date -d "$yyyy-$mm-$dd" +%s)
epoch_secs=$(date -d "$epoch" +%s)

# Difference in days ( rounded to the nearest whole day )
seconds_diff=$((date_secs - epoch_secs))
days_since=$(( ((seconds_diff + (86400/2)) / 86400) ))

echo "Date: $yyyy-$mm-$dd"
echo "Days since $epoch: $days_since"