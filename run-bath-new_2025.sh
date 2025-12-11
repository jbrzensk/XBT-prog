#!/bin/bash
#======================================================================
# modification of the run-bathy original script
#
# Still a csh file
# But now a TCLSH file!!
#
# Set prefix by the files in the directory!
# Get the first matching file
# Run the script and capture its output
# set output = ( `extract_prefix.sh` )
# More complicated for tclsh

# Find what the prefix and line number is in our folder
read line_number prefix < <(extract_prefix.sh)

# The script should output "line_number prefix" separated by a space
# Split it into two variables
#set line_number = $output[1]
#set prefix = $output[2]

echo "Prefix from extract_prefix.sh: $prefix"
echo "Line number: $line_number"
echo "we are currently in $PWD"
echo ""


# get *a.10 filename for input to programs:
# Is there ever more than 1? ( BRZENSKI ) 
for filename in *a.10; do
    [[ "$filename" == "*a.10" ]] && continue
    
    echo "Found an a.10 file:"
    echo $filename
    ls -l "$filename"
    head -5 "$filename"

    echo -e "\033[1m **Running mapxbt_helper.sh again to get complicated inputs** \033[0m"
    . mapxbt_helper.sh $line_number
    echo "line = $long_line"
    echo "Choice = $choice"
    echo "start = $start"
    echo "end = $end"


    ## mkgridlat.x OR mkgridlon.x
    echo "Running mkgridlat.x or mkgridlon.x"

    if [[ "$line_number" =~ ^(p34|p37|p40|p44|p50|s37|a07|a18)$ ]]; then

        echo "Running mkgridlat.x"
        echo "$filename" | mkgridlat.x

    elif [[ "$line_number" =~ ^(p05|p38|a08|a10|p09|p13)$ ]]; then
        
        echo "Line detected with multiple possible bathy files."
        echo "Running link_bathy.sh to link P05, P06, P09 bathy files."
        link_bathy.sh p05
        link_bathy.sh p06
        link_bathy.sh p09

        # if [[ "$long_line" == "PX06" ]]; then
        #         echo "Line p06 detected, using mkgridlon.x"
        #         echo "Also detected A line, using short track."
        #         echo "Moving px06-cgi"
        #         link_bathy.sh p06
        
        # elif [[ "$long_line" == "PX09" ]]; then
        #         echo "Line p09 detected, using mkgridlon.x"
        #         echo "Also detected A line, using short track."
        #         echo "Moving px09-cgi"
        #         link_bathy.sh p09
        
        # elif [[ "$long_line" == "P06/PX09" ]]; then
        #         echo "Line p06/p09 detected, using mkgridlon.x"
        #         echo "Also detected A line, using short track."
        #         echo "Moving px06-cgi and px09-cgi"
        #         link_bathy.sh p06
        #         link_bathy.sh p09
        # fi

        echo "Running mkgridlon.x"
        echo "$filename" | mkgridlon.x

        mkgridlon.x << EOF
$filename
1
EOF

    else
        echo "Unknown line for grid generation: $line_number"
        echo "Skipping mkgridlat.x or mkgridlon.x"

    fi

    ## mktrackvel.x
    echo "Running mktrackvel.x"
    echo "$filename" | mktrackvel.x

    #  find-e-dep.c requires two inputs, best with EOF style
    echo "Running find-e-dep.x"
    find-e-dep.x << EOF7
$filename
y
EOF7

    # mkcruisebath_2025 Needs testing. So far onlt will work if it 
    # is the px40 line. May need to test all others. Which are being used?
    # The linking of the bath file to this location has to be done!!
    # BRZENSKI
    
    echo "Running mkcruisebath_2025.x"
    echo "$filename" | mkcruisebath_2025.x
    #
    echo "Running mkbotgrd.x"
    echo "$filename" | mkbotgrd.x
    #
    echo "Running mkgridbath.x"
    echo "$filename" | mkgridbath.x

done


