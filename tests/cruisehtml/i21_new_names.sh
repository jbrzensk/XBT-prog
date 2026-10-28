#!/bin/bash
#=============================================================================#
# i21_new_names.sh
#
# Copies a cruisehtml.x page into a folder, converting IX21 pages to the new
# names used after I21_LAST_OLD (cruisehtml.sh). cruisehtml.x only knows the
# old names, so this is how its pages are compared with cruisehtml.sh.
# For every IX21 page:
#   previous/next i15YYMM.html -> i21YYMM.html, for cruises after the cutoff
# and for an IX21 cruise after the cutoff, also:
#   page i15YYMM.html          -> i21YYMM.html
#   i15head/i15table includes  -> i21head/i21table
#   download folder ix15       -> ix21
# Pages for other lines are copied unchanged.
#
# Usage:
#   i21_new_names.sh <case> <cruisehtml.x page> <output dir>
#   i21_new_names.sh i212604 work/i152604.html expected/i212604
#=============================================================================#

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
source "$REPO/cruisehtml.sh"

if [[ $# -ne 3 || ! -f "$2" || ! -d "$3" ]]; then
    echo "Usage: $0 <case> <cruisehtml.x page> <output dir>" >&2
    exit 1
fi
c=$1 page=$2 out=$3
id=${c:3}

if [[ ${c:0:3} != i21 ]]; then
    cp "$page" "$out/"
    exit $?
fi

# Previous/next IDs in the page that are after the cutoff.
new_ids=()
for n in $(grep -o -E 'href="i15[0-9]{4}\.html"' "$page" | sed -E 's/href="i15([0-9]{4}).*/\1/'); do
    i21_old "$n" || new_ids+=("$n")
done

script=''
for n in "${new_ids[@]}"; do
    script+="s/href=\"i15$n\\.html\"/href=\"i21$n.html\"/;"
done
if i21_old "$id"; then
    name=$(basename "$page")
else
    name="i21$id.html"
    script+='s/include file="i15head\.html"/include file="i21head.html"/'
    script+=';s/include file="i15table\.html"/include file="i21table.html"/'
    script+=';s|\.\./www-hrx/ix15/|../www-hrx/ix21/|'
fi
sed "$script" "$page" > "$out/$name"
