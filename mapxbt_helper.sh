#!/usr/bin/env bash
# cruise_prompt.sh - Interactive prompt for cruise details based on prefix
#
# Description:
# This is the same logic within the mapxbt3.f file.
# This script prompts the user for specific cruise details based on the provided prefix.
# It is designed to be sourced by other scripts to set variables accordingly.
#
# Usage: source cruise_prompt.sh <prefix>
#
# Example: source cruise_prompt.sh p06
#
# Note: This script assumes it is being sourced, not executed directly.
# If executed directly, it will print a message and exit.
#
# Used by run_image_gen.sh for mapxbt3.x more complicated inputs.
prefix_short="$1"

case "$prefix_short" in
  p08)
    echo "Choose which track fits this cruise:"
    echo " 1) Auckland - Panama"
    echo " 2) Dunedin - Panama"
    read -p "Enter choice: " choice
    long_line="PX08"
    echo "long_line=$long_line, choice=$choice"
    ;;

  p06)
    echo "Choose which track fits this cruise:"
    echo " 1) PX06           : Auckland - Suva"
    echo " 2) PX06 loop A    : Auckland - Noumea"
    echo " 3) PX06 loop B    : Noumea - Suva"
    echo " 4) PX06 loop C    : Suva - Auckland"
    read -p "Enter choice: " choice
    case $choice in
      1) long_line="PX06"
      echo "long_line=$long_line, choice=$choice" ;;
      2) long_line="PX06 Loop A"
      echo "long_line=$long_line, choice=$choice" ;;
      3) long_line="PX06 Loop B"
      echo "long_line=$long_line, choice=$choice" ;;
      4) long_line="PX06 Loop C"
      echo "long_line=$long_line, choice=$choice" ;;
    esac
    ;;

  p09|p13)
    echo "Choose which track fits this cruise:"
    echo " 1) PX06           : Auckland - Suva"
    echo " 2) PX09           : Auckland - Hawaii"
    echo " 3) PX06/PX09      : Auckland - Suva - Hawaii"
    echo " 4) PX06/PX09/PX39 : Auckland - Suva - Hawaii - Seattle"
    echo " 5) PX06/PX31      : Auckland - Suva - Los Angeles"
    echo " 6) PX06/PX12/PX18 : Auckland - Suva - Tahiti - Los Angeles"
    echo " 7) PX06/PX31      : Tauranga - Suva - Los Angeles"
    echo " 8) PX13           : Auckland - Los Angeles"
    echo " 9) PX13           : Auckland - San Francisco"
    echo "10) PX13           : Tauranga - Los Angeles"
    read -p "Enter choice: " choice
    case $choice in
      1) 
      long_line="PX06"
      echo "long_line=$long_line, choice=$choice" ;;
      2) long_line="PX09"
      echo "long_line=$long_line, choice=$choice" ;;
      3) long_line="PX06/PX09"
      echo "long_line=$long_line, choice=$choice" ;;
      4) long_line="PX06/PX09/PX39"
      echo "long_line=$long_line, choice=$choice" ;;
      5) long_line="PX06/PX31"
      echo "long_line=$long_line, choice=$choice" ;;
      6) long_line="PX06/PX12/PX18"
      echo "long_line=$long_line, choice=$choice" ;;
      7) long_line="PX06/PX31"
      echo "long_line=$long_line, choice=$choice" ;;
      8|9|10) long_line="PX13"
      echo "long_line=$long_line, choice=$choice" ;;
    esac
    ;;

  p15)
    echo "Choose which track fits this cruise:"
    echo " 1) IX21/IX15: Cape of Good Hope - Mauritius - Fremantle"
    echo " 2) IX02: Cape of Good Hope - Fremantle"
    echo " 3) IX21/IX15/IX31: Durban - Mauritius - Melbourne"
    echo " 4) IX21/IX06: Durban - Mauritius - Banda Aceh, Sumatra"
    read -p "Enter choice: " choice
    case $choice in
      1) long_line="IX21/IX15"
      echo "long_line=$long_line, choice=$choice" ;;
      2) long_line="IX02"
      echo "long_line=$long_line, choice=$choice" ;;
      3) long_line="IX21/IX15/IX31"
      echo "long_line=$long_line, choice=$choice" ;;
      4) long_line="IX21/IX06"
      echo "long_line=$long_line, choice=$choice" ;;
    esac
    ;;

  p22)
    echo "Choose which endpoint fits this cruise:"
    echo " 1) Palmer Station"
    echo " 2) Smith Island"
    echo " 3) King George Island"
    read -p "Enter choice: " choice
    long_line="AX22"
    echo "long_line=$long_line, choice=$choice"
    ;;

  p31)
    echo "Choose which track fits this cruise:"
    echo " 1) b1  Brisbane - Noumea - Lautoka"
    echo " 2) b2  Brisbane - Noumea - Suva"
    echo " 3) b3  Brisbane - Lautoka"
    echo " 4) b4  Brisbane - Suva"
    read -p "Enter choice: " choice
    long_line="PX30/PX31"
    echo "long_line=$long_line, choice=$choice"
    ;;

  p37)
    echo "Did this cruise go to:"
    echo " 1) Hong Kong"
    echo " 2) Taiwan"
    echo " 3) P37S: Los Angeles to Honolulu"
    read -p "Enter choice: " choice
    long_line="PX37"
    echo "long_line=$long_line, choice=$choice"
    ;;

  p50)
    echo "Did this cruise go to:"
    echo " 1) Auckland, NZ"
    echo " 2) Lyttelton, NZ"
    read -p "Enter startpoint: " start
    echo "Did this cruise go to:"
    echo " 1) Valpariso, Chile"
    echo " 2) Callao, Peru"
    read -p "Enter endpoint: " end
    long_line="PX50"
    echo "long_line=$long_line, start=$start, end=$end"
    ;;

  *)
    echo "No choices needed for $prefix_string"
    ;;
esac