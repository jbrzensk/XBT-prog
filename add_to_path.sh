#!/bin/bash
#
# Adds the current working directory to the PATH environment variable
# This needs to be sourced, not executed
# Usage: source add_to_path.sh
#    or: . add_to_path.sh
#
# Add current working directory to PATH
export PATH="$PWD:$PATH"

echo "Added $PWD to PATH"
echo "Current PATH: $PATH"