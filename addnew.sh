# addnew.sh
# For adding new lines for the BUDDIES script.
# 
# THIS IS NOT MEANT TO BE RUN BY ITSELF. It is called by add_to_buddies.sh.
# 
# Jared Brzenski : June 2026
#
#CHANGE:
set line="s37"

#CHANGE:
foreach i(2410 2502)

echo {$line}{$i}

cd /data/xbt/$line

mkdir /data1/xbt-archive/{$line}/{$i}

cd $i

\cp -a {$line}{$i}e.* /data1/xbt-archive/{$line}/{$i}/.

# custom for a lines only:
# skip s files for atlantic: \cp -a {$line}{$i}s.* /data1/xbt-archive/{$line}/{$i}/.
#---------------
# normal: cp stations.dat /data1/xbt-archive/{$line}/{$i}/stations.dat
# p09 no stations.dat:
# try this for p38 too:

\cp -a {$line}{$i}.dat /data1/xbt-archive/{$line}/{$i}/stations.dat

# make a fake control.dat:
/data1/xbt-archive/fakecontrol.x << EOF
$line$i
EOF
# if a real one exists this will overwrite the fake one:
\cp -a control.dat /data1/xbt-archive/{$line}/{$i}/control.dat


cd /data1/xbt-archive/$line
cd $i
/data1/xbt-archive/mklinedat.x << EOF
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
 cat /data1/xbt-archive/p15.dat >> /data1/xbt-archive/line.dat
 \cp /data1/xbt-archive/line.dat /data1/xbt-archive/p15.dat
else
 cat /data1/xbt-archive/{$line}.dat >> /data1/xbt-archive/line.dat
 \cp /data1/xbt-archive/line.dat /data1/xbt-archive/{$line}.dat
endif


end

