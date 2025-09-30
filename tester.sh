line_number=$1

echo -e "\033[1m **Running mapxbt_helper.sh to get complicated mapxbt3 inputs** \033[0m"
. mapxbt_helper.sh $line_number
echo "line = $long_line"
echo "Choice = $choice"
echo "start = $start"
echo "end = $end"
