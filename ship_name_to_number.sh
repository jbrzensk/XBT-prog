#!/usr/bin/env bash
# Return the number given a string for a ship name
# 
# Using extract_shipname.sh, we can get the value for shipname.
# This correlates that to a number string, which we
# can feed into
#   Ship name is (enter number):
#   1 - Argentina Star      (p09)                      |   34 - Marine Columbia (p38)
#   2 - Astrolabe           (p28)                      |   35 - MSC Federica    (i15)
#   3 - Fua Kavenga         (p31)                      |   36 - Horizon Enterprise(p37)
#   4 - Iron Dampier        (p34)                      |   37 - Forestal Diamante (p81)
#   5 - Rangitane           (p34)                      |   38 - Nedlloyd Wellington (p34)
#   6 - Rangitata           (p34)                      |   39 - Seabulk Pride (p38)
#   7 - Ranginui            (p34)                      |   40 - Maersk Auckland (p09)
#   8 - Sealand Enterprise  (p37)                      |   41 - Direct Condor   (p09)
#   9 - Tonsina             (p38)                      |   42 - USCG Hickory    (p38)
#  10 - Chevron Mississippi (p38)                      |   43 - Maersk Denton   (p08)
#  11 - Asian Challenger    (p50)                      |   44 - Polar Endeavour (p38)
#  12 - NYK Nacre           (p81)                      |   45 - Vega Gotland    (p34)
#  13 - Rangiora            (p34)                      |   46 - Nora Maersk     (p08)
#  14 - Lydia Oldendorff    (p50)                      |   47 - Safmarine Meru  (i21)
#  15 - CSX Enterprise      (p37) (p370005 & beyond)
#  16 - Columbus Coromandel (p09)                      |   48 - Horizon Hawk    (p37)
#  17 - LMGould             (p22)                      |   49 - CMA CGM Lavender(p15)
#  18 - Wellington Express  (p34)                      |   50 - E.R.Wilhelmshaven(09)
#  19 - Kakapo Chief        (p30)                      |   51 - R/V Melville
#  20 - Columbus Florida    (p09)                      |   52 - Josephine Maersk(p08)
#  21 - MOL Kauri           (p50)                      |   53 - Horizon Spirit (p37s)
#  22 - Forum Samoa 2       (p31)                      |   54 - Southern Surveyor(p34)
#  23 - M/V Polar Duke      (p22)                      |   55 - USCG Spar (p38) 
#  24 - Nathaniel B. Palmer (p22)                      |   56 - MSC Hobart (p34)
#  25 - Overseas Boston     (p38)                      |   57 - Maersk Phuket (p09)
#  26 - Capitaine Tasman    (p31)                      |   58 - Maersk Fuji (p06)
#  27 - Coral Chief         (p34)                      |   59 - Cap Reinga (p09) 
#  28 - Conti Asia          (p50)                      |   60 - JPO Scorpius (p09)
#  29 - Nedlloyd Nelson     (p34)                      |   61 - Maersk Fukuoka (p06)
#  30 - New Plymouth        (p34)                      |   62 - BC San Francisco (p06)
#  31 - PONL  Mairangi      (p08)                      |   63 - JRS Canis  (p40) 
#  32 - ANL  Progress       (p34)                      |   64 - Shengking (p31)  
#  33 - Direct Tui          (p09)                      |   65 - Maersk Senang (i21)
#   0 - leave blank!                                   |   66 - MELL Springwood (p44)
#                                                      |   67 - MSC Vienna (i21)     
#                                                      |   68 - MSC Damla  (i21)     
#                                                      |   69 - Safmarine Mulanje (p05)     
# Determine control file
if [[ $# -eq 1 ]]; then
    ship_name="$1"
else
    echo "Error: '$ship_name' not found!" >&2
    return 1 2>/dev/null || exit 1
fi

if [[ $ship_name == 'Argentina Star' ]]; then
   iship=1
elif [[ $ship_name == 'Astrolabe' ]]; then
   iship=2
elif [[ $ship_name == 'Fua Kavenga' ]]; then
   iship=3
elif [[ $ship_name == 'Iron Dampier' ]]; then
   iship=4
elif [[ $ship_name == 'Rangitane' ]]; then
   iship=5
elif [[ $ship_name == 'Rangitata' ]]; then
   iship=6
elif [[ $ship_name == 'Ranginui' ]]; then
   iship=7
elif [[ $ship_name == 'Sea-Land Enterprise' ]]; then
   iship=8
elif [[ $ship_name == 'Tonsina' ]]; then
   iship=9
elif [[ $ship_name == 'Chevron Mississippi' ]]; then
   iship=10
elif [[ $ship_name == 'Asian Challenger' ]]; then
    iship=11
elif [[ $ship_name == 'NYK Nacre' ]]; then
    iship=12
elif [[ $ship_name == 'Rangiora' ]]; then
    iship=13
elif [[ $ship_name == 'Lydia Oldendorff' ]]; then
    iship=14
elif [[ $ship_name == 'CSX Enterprise' ]]; then
    iship=15
elif [[ $ship_name == 'Columbus Coromandel' ]]; then
    iship=16
elif [[ $ship_name == 'LMGould' ]]; then
    iship=17
elif [[ $ship_name == 'Wellington Express' ]]; then
    iship=18
elif [[ $ship_name == 'Kakapo Chief' ]]; then
    iship=19
elif [[ $ship_name == 'Columbus Florida' ]]; then
    iship=20
elif [[ $ship_name == 'MOL Kauri' ]]; then
    iship=21
elif [[ $ship_name == 'Forum Samoa 2' ]]; then
    iship=22
elif [[ $ship_name == 'M/V Polar Duke' ]]; then
    iship=23
elif [[ $ship_name == 'Nathaniel B. Palmer' ]]; then
    iship=24
elif [[ $ship_name == 'Overseas Boston' ]]; then
    iship=25
elif [[ $ship_name == 'Capitaine Tasman' ]]; then
    iship=26
elif [[ $ship_name == 'Coral Chief' ]]; then
    iship=27
elif [[ $ship_name == 'Conti Asia' ]]; then
    iship=28
elif [[ $ship_name == 'Nedlloyd Nelson' ]]; then
    iship=29
elif [[ $ship_name == 'New Plymouth' ]]; then
    iship=30
elif [[ $ship_name == 'PONL Mairangi' ]]; then
    iship=31
elif [[ $ship_name == 'ANL Progress' ]]; then
    iship=32
elif [[ $ship_name == 'Direct Tui' ]]; then
    iship=33
elif [[ $ship_name == 'Marine Columbia' ]]; then
    iship=34
elif [[ $ship_name == 'MSC Federica' ]]; then
    iship=35
elif [[ $ship_name == 'Horizon Enterprise' ]]; then
    iship=36
elif [[ $ship_name == 'Forestal Diamante' ]]; then
    iship=37
elif [[ $ship_name == 'Nedlloyd Wellington' ]]; then
    iship=38
elif [[ $ship_name == 'Seabulk Pride' ]]; then
    iship=39
elif [[ $ship_name == 'Maersk Auckland' ]]; then
    iship=40
elif [[ $ship_name == 'Direct Condor' ]]; then
    iship=41
elif [[ $ship_name == 'USCG Hickory' ]]; then
    iship=42
elif [[ $ship_name == 'Maersk Denton' ]]; then
    iship=43
elif [[ $ship_name == 'Polar Endeavour' ]]; then
    iship=44
elif [[ $ship_name == 'Vega Gotland' ]]; then
    iship=45
elif [[ $ship_name == 'Nora Maersk' ]]; then
    iship=46
elif [[ $ship_name == 'Safmarine Meru' ]]; then
    iship=47
elif [[ $ship_name == 'Horizon Hawk' ]]; then
    iship=48
elif [[ $ship_name == 'CMA CGM Lavender' ]]; then
    iship=49
elif [[ $ship_name == 'E.R.Wilhelmshaven' ]]; then
    iship=50
elif [[ $ship_name == 'R/V Melville' ]]; then
    iship=51
elif [[ $ship_name == 'Josephine Maersk' ]]; then
    iship=52
elif [[ $ship_name == 'Horizon Spirit' ]]; then
    iship=53
elif [[ $ship_name == 'Southern Surveyor' ]]; then
    iship=54
elif [[ $ship_name == 'USCG Spar' ]]; then
    iship=55
elif [[ $ship_name == 'MSC Hobart' ]]; then
    iship=56
elif [[ $ship_name == 'Maersk Phuket' ]]; then
    iship=57
elif [[ $ship_name == 'Maersk Fuji' ]]; then
    iship=58
elif [[ $ship_name == 'Cap Reinga' ]]; then
    iship=59
elif [[ $ship_name == 'JPO Scorpius' ]]; then
    iship=60
elif [[ $ship_name == 'Maersk Fukuoka' ]]; then
    iship=61
elif [[ $ship_name == 'BC San Francisco' ]]; then
    iship=62
elif [[ $ship_name == 'JRS Canis' ]]; then
    iship=63
elif [[ $ship_name == 'Shengking' ]]; then
    iship=64
elif [[ $ship_name == 'Maersk Senang' ]]; then
    iship=65
elif [[ $ship_name == 'MELL Springwood' ]]; then
    iship=66
elif [[ $ship_name == 'MSC Vienna' ]]; then
    iship=67
elif [[ $ship_name == 'MSC Damla' ]]; then
    iship=68
elif [[ $ship_name == 'Safmarine Mulanje' ]]; then
    iship=69
else
    iship=0
fi
if [[ $iship -ne 0 ]]; then
    echo "Ship name found!!"
    echo " ${ship_name} is number : ${iship}"
    echo ""
else
    echo "Ship name NOT found!!"
    echo "Leaving blank"
    echo "Have to do crazy logic for ${ship_name}"
fi
