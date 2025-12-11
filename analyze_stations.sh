#!/bin/bash

file="stations.dat"

# Define column names in an associative array
declare -A colname
colname=( ["drop_num"]=0 ["tube"]=1 ["unnk"]=2 ["date"]=3 ["time"]=4 ["lat"]=5 ["lon"]=6 ["param1"]=7 ["param2"]=8 ["param3"]=9 ["flag"]=10 )

# Read first row into array
first=($(awk 'NR==1 {for(i=1;i<=NF;i++) print $i}' "$file"))

# Read penultimate row into array
penultimate=($(awk '{line[NR]=$0} END {split(line[NR-1],a); for(i in a) print a[i]}' "$file"))

# Find Julian date of first drop
epoch="1985-12-31"
epoch_secs=$(date -d "$epoch" +%s)
dd=${first[${colname[date]}]:0:2}
mm=${first[${colname[date]}]:3:2}
yy=${first[${colname[date]}]:6:2}
yyyy="20$yy"
date_secs=$(date -d "$yyyy-$mm-$dd" +%s)
seconds_diff=$((date_secs - epoch_secs))
days_since=$(( ((seconds_diff + (86400/2)) / 86400) ))

# Example access by name:
echo "Summarized output:"
echo "**********************************************************************"
echo "First row       - drop: ${first[${colname[drop_num]}]}, date: ${first[${colname[date]}]}, lat: ${first[${colname[lat]}]}, lon: ${first[${colname[lon]}]}"
echo "Penultimate row - drop: ${penultimate[${colname[drop_num]}]}, date: ${penultimate[${colname[date]}]}, lat: ${penultimate[${colname[lat]}]}, lon: ${penultimate[${colname[lon]}]}"
echo "**********************************************************************"
echo -e "\e[1mJulian days for ${first[${colname[date]}]}: $days_since\e[0m"
echo ""
echo "For sanity, checking the last row"
# Last row, for sanity check
last=($(awk 'END {for(i=1;i<=NF;i++) print $i}' "$file"))
echo "LAST ROW (should be ENDDATA or EOF): ${last[*]}"
echo ""
echo ""
echo "The raw first, penultimate, and last rows are:"
echo ${first[@]}
echo ${penultimate[@]}
echo ${last[@]} 