#!/bin/bash
#======================================================================
# This matches a bathy file with a prefix, the same as mkcruisebath.
# and symbolically links the file here. So no hard coding is necessary
# Usage: ./link_bathy.sh <prefix>
# Example: ./link_bathy.sh ABC
#======================================================================

PREFIX="$1"

if [ -z "$PREFIX" ]; then
    echo "Usage: $0 <three_letter_prefix>"
    exit 1
fi

if [[ $PREFIX == 's37' ]]; then
    bathname='ps37-sns-bath.cgi'
elif [[ $PREFIX == 'p40' || $PREFIX == 'p44' || $PREFIX == 'p37' ]]; then
     bathname='px37-sns-bath.cgi'
elif [[ $PREFIX == 'p13' ]]; then
     bathname='p09-sns-bath.cgi'
elif [[ $PREFIX == 'p05' ]]; then
     bathname='p05-sns-bath.cgi'
elif [[ $PREFIX == 'p06' ]]; then
     bathname='p06-sns-bath.cgi'
elif [[ $PREFIX == 'p09' ]]; then
     bathname='p09-sns-bath.cgi'
elif [[ $PREFIX == 'p31' ]]; then
     bathname='p31-sns-bath.cgi'
elif [[ $PREFIX == 'p34' ]]; then
     bathname='p34-sns-bath.cgi'
elif [[ $PREFIX == 'p50' ]]; then
     bathname='p50-sns-bath.cgi'
else
     echo "Error: Unsupported line number '$PREFIX'. Supported prefixes are p05, p06, p09, p31, p34, p37, p40, p44, p13, p50."
     echo "Please add the appropriate files into link_bathy.sh"
     exit 1
fi

SRC_BATHY="../../bathy/${bathname}"
DEST_BATHY="./${bathname}"

if [ ! -f "$SRC_BATHY" ]; then
    echo "Source bathy file not found: $SRC_BATHY"
    exit 2
fi

ln -sf "$SRC_BATHY" "$DEST_BATHY"
echo "Linked $SRC_BATHY to $DEST_BATHY"