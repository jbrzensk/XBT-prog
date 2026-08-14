# addnew.sh
# For adding new lines for the BUDDIES script.
# 
# Try the new simpler, automated add_to_buddies.sh.
# 
# UPDATED: To work using the /kakopo folder structure on savu
# Jared Brzenski : August 2026
#
# CHANGE:
# Replace with the line number
set line="s37"

# CHANGE:
# Replace the list with the cruises you want. Can do a single cruise 
# or multiple cruises.
foreach i(2410 2502)

#################################################################
## DO NOT CHANGE BELOW THIS LINE                               ##
#################################################################
echo {$line}{$i}

cd /kakopo/data/xbt/$line

mkdir /kakopo/data1/xbt-archive/{$line}/{$i}

cd $i

\cp -a {$line}{$i}e.* /kakopo/data1/xbt-archive/{$line}/{$i}/.

# custom for a lines only:
# skip s files for atlantic: \cp -a {$line}{$i}s.* /kakopo/data1/xbt-archive/{$line}/{$i}/.
#---------------
# normal: cp stations.dat /kakopo/data1/xbt-archive/{$line}/{$i}/stations.dat
# p09 no stations.dat:
# try this for p38 too:

\cp -a {$line}{$i}.dat /kakopo/data1/xbt-archive/{$line}/{$i}/stations.dat

# make a fake control.dat:
/kakopo/data1/xbt-archive/fakecontrol.x << EOF
$line$i
EOF
# if a real one exists this will overwrite the fake one:
\cp -a control.dat /kakopo/data1/xbt-archive/{$line}/{$i}/control.dat


cd /kakopo/data1/xbt-archive/$line
cd $i
/kakopo/data1/xbt-archive/mklinedat.x << EOF
$line$i
EOF

# the output of mklinedat.x is called "line.dat"
# below here you are "catting" the existing pXX.dat to the end
# of line.dat, then copying your new line.dat over pXX.dat
# that way new data is at beginning of file.

#put recent cruise at top of pXX.dat:
# note i21 cruises are going into p15.dat...
#
set i21="i21"

if( $line == $i21 ) then
 cat /kakopo/data1/xbt-archive/p15.dat >> /kakopo/data1/xbt-archive/line.dat
 \cp /kakopo/data1/xbt-archive/line.dat /kakopo/data1/xbt-archive/p15.dat
else
 cat /kakopo/data1/xbt-archive/{$line}.dat >> /kakopo/data1/xbt-archive/line.dat
 \cp /kakopo/data1/xbt-archive/line.dat /kakopo/data1/xbt-archive/{$line}.dat
endif


end

